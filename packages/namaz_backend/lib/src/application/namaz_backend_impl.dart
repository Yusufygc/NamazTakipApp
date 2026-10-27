import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../data/dhikr_repository.dart';
import '../data/prayer_repository.dart';
import '../data/secret_store.dart';
import '../data/settings_repository.dart';
import '../data/turkish_cities.dart';
import '../domain/achievements.dart';
import '../domain/dates.dart';
import '../domain/dhikr.dart';
import '../domain/home_widget_snapshot.dart';
import '../domain/models.dart';
import '../domain/notification_plan.dart';
import '../domain/prayer.dart';
import '../domain/prayer_time_service.dart';
import '../domain/streaks.dart';
import '../namaz_backend.dart';
import '../platform/home_widget_service.dart';
import '../platform/location_service.dart';
import '../platform/notification_service.dart';
import '../platform/share_service.dart';
import 'background_service.dart' show BackgroundService;
import 'notification_scheduler.dart';

/// [NamazBackend] uygulaması: depo, servis ve platform katmanlarını birleştirir.
class NamazBackendImpl implements NamazBackend {
  NamazBackendImpl._({
    required SettingsRepository settings,
    required PrayerRepository prayers,
    required this._dhikrs,
    required NotificationTexts texts,
    required this._widgetTexts,
    required this._dhikrContent,
  }) : _settings = settings,
       _prayers = prayers,
       _scheduler = NotificationScheduler(
         settings: settings,
         prayers: prayers,
         texts: texts,
       );

  final SettingsRepository _settings;
  final PrayerRepository _prayers;
  final DhikrRepository _dhikrs;
  final NotificationScheduler _scheduler;
  final HomeWidgetTexts _widgetTexts;
  final DhikrContent _dhikrContent;

  final PrayerTimeService _timeService = const PrayerTimeService();
  final LocationService _location = const LocationService();
  final NotificationService _notifications = NotificationService.instance;
  final ShareService _shareService = ShareService.instance;
  final HomeWidgetService _homeWidget = const HomeWidgetService();

  static Future<NamazBackendImpl> create(NamazBackendConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsRepository(prefs, secrets: const SecureSecretStore());
    await settings.loadSecrets();
    await settings.ensureInstallDate(prayerDay(DateTime.now()));
    final database = await AppDatabase.open();
    if (database.corruptedBackupPath != null) {
      await settings.setCorruptedDbBackup(database.corruptedBackupPath);
    }

    final dhikrs = DhikrRepository(database);
    await dhikrs.seedDefaultsIfEmpty(config.dhikrContent);

    await NotificationService.instance.init();
    ShareService.instance.init();

    // Arka plan yenilemesi desteklenmeyen ortamda (ör. masaüstü) uygulamayı durdurmasın.
    try {
      await const BackgroundService().register(config.backgroundEntryPoint);
    } catch (e) {
      debugPrint('[Background] kaydedilemedi: $e');
    }

    final instance = NamazBackendImpl._(
      settings: settings,
      prayers: PrayerRepository(database),
      dhikrs: dhikrs,
      texts: config.notificationTexts,
      widgetTexts: config.homeWidgetTexts,
      dhikrContent: config.dhikrContent,
    );
    unawaited(instance.syncHomeWidget());
    return instance;
  }

  DateTime get _today => trackingDay();

  // ---- Ayarlar ----------------------------------------------------------------

  @override
  AppSettings get settings => AppSettings(
    themeKey: _settings.themeKey,
    notificationsEnabled: _settings.notificationsEnabled,
    reminderMinutes: _settings.reminderMinutes,
    calcMethod: _settings.calcMethod,
    locationMode: _settings.locationMode,
    manualLocation: _settings.manualLocation,
    location: _settings.effectiveLocation,
    hasGeminiApiKey: _settings.geminiApiKey != null,
  );

  /// Ayar değişince bildirimleri tazeler.
  Future<void> _afterSettingsChange() async => _rescheduleQuietly();

  @override
  Future<void> setTheme(String key) => _settings.setThemeKey(key);

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) await _notifications.requestPermissions();
    await _settings.setNotificationsEnabled(enabled);
    await _afterSettingsChange();
  }

  @override
  Future<void> setReminderMinutes(int minutes) async {
    await _settings.setReminderMinutes(minutes);
    await _afterSettingsChange();
  }

  @override
  Future<void> setCalcMethod(CalcMethod method) async {
    await _settings.setCalcMethod(method);
    await _afterSettingsChange();
  }

  @override
  Future<void> useManualLocation(AppLocation location) async {
    await _settings.setManualLocation(location);
    await _settings.setLocationMode(LocationMode.manual);
    await _afterSettingsChange();
  }

  @override
  Future<void> useAutoLocation() async {
    await _settings.setLocationMode(LocationMode.auto);
    await _afterSettingsChange();
  }

  @override
  Future<void> setGeminiApiKey(String? apiKey) =>
      _settings.setGeminiApiKey(apiKey);

  @override
  List<AppLocation> get cities => kTurkishCities;

  // ---- Konum ve vakitler -------------------------------------------------------

  @override
  Future<AppLocation?> refreshLocation() async {
    if (_settings.locationMode == LocationMode.manual &&
        _settings.manualLocation != null) {
      return _settings.manualLocation;
    }
    try {
      final loc = await _location.current();
      await _settings.setLastLocation(loc);
      await _afterSettingsChange();
      return loc;
    } on LocationException {
      final last = _settings.lastLocation;
      if (last != null) return last;
      rethrow;
    }
  }

  @override
  DayTimes? timesFor(DateTime day) {
    final loc = _settings.effectiveLocation;
    if (loc == null) return null;
    return _timeService.compute(loc, day, _settings.calcMethod);
  }

  @override
  DateTime trackingDay([DateTime? now]) {
    final current = now ?? DateTime.now();
    return prayerDay(current, fajrToday: timesFor(dateOnly(current))?.fajr);
  }

  @override
  Stream<double> get compassHeading {
    // Manyetik sapma konuma bağlıdır; dinleme başlarken geçerli konum verilir.
    final loc = _settings.effectiveLocation;
    return _location.compassHeading(
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
  }

  // ---- Takip ---------------------------------------------------------------------

  @override
  Future<Map<PrayerType, PrayerRecord>> recordsForDate(DateTime date) =>
      _prayers.recordsForDate(date);

  @override
  Future<void> markPerformed(
    DateTime date,
    PrayerType prayer, {
    required bool congregation,
  }) async {
    await _prayers.markPerformed(date, prayer, congregation: congregation);
    _rescheduleQuietly();
  }

  @override
  Future<void> markMissed(DateTime date, PrayerType prayer) async {
    await _prayers.markMissed(date, prayer);
    _rescheduleQuietly();
  }

  // ---- Kaza & Geçmiş Kaza Borcu Planlayıcı ------------------------------------

  @override
  Future<List<QazaItem>> qazaItems() =>
      _prayers.qazaItems(firstDay: trackingStart, today: _today);

  @override
  Future<void> compensate(QazaItem item) =>
      _prayers.markCompensated(item.date, item.prayer);

  @override
  QazaDebtPlan get qazaDebtPlan => QazaDebtPlan(
    backlogByPrayer: _settings.qazaBacklog,
    dailyTarget: _settings.qazaDailyTarget,
  );

  @override
  Future<void> setQazaBacklog(Map<PrayerType, int> counts) =>
      _settings.setQazaBacklog(counts);

  @override
  Future<void> decrementQazaBacklog(PrayerType prayer, {int step = 1}) async {
    final current = Map<PrayerType, int>.from(_settings.qazaBacklog);
    final nextVal = ((current[prayer] ?? 0) - step).clamp(0, 1000000);
    current[prayer] = nextVal;
    await _settings.setQazaBacklog(current);
  }

  @override
  Future<void> setQazaDailyTarget(int dailyTarget) =>
      _settings.setQazaDailyTarget(dailyTarget);

  // ---- İstatistik ----------------------------------------------------------------

  @override
  DateTime get trackingStart => _settings.installDate ?? _today;

  @override
  Future<WeekComparison> weekComparison() async {
    final today = _today;
    final counts = await _prayers.dailyCounts(addDays(today, -13), today);
    final previous = counts.take(7).fold<int>(0, (s, c) => s + c.performed);
    final current = counts.skip(7).fold<int>(0, (s, c) => s + c.performed);
    return WeekComparison(current, previous);
  }

  @override
  Future<List<DayCount>> dailyCounts(int days) {
    final today = _today;
    return _prayers.dailyCounts(addDays(today, -(days - 1)), today);
  }

  @override
  Future<List<DayCount>> monthCounts(DateTime month) {
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    return _prayers.dailyCounts(first, last);
  }

  @override
  Future<Map<PrayerType, int>> radar(int days) async {
    final today = _today;
    final performed = await _prayers.performedByPrayer(
      addDays(today, -(days - 1)),
      today,
    );
    final span = daysDiff(today, trackingStart) + 1;
    final denom = span < days ? span : days;
    return {
      for (final e in performed.entries)
        e.key: denom <= 0 ? 0 : ((e.value / denom) * 100).round().clamp(0, 100),
    };
  }

  @override
  Future<GamificationData> gamification() async {
    final streaks = computeStreaks(await _prayers.fullDays(), _today);
    return GamificationData(
      streaks,
      buildAchievements(
        streaks: streaks,
        totalCongregation: await _prayers.totalCongregation(),
        totalFajr: await _prayers.totalPerformed(PrayerType.fajr),
      ),
    );
  }

  // ---- Zikir & Sosyal Medya Yakalayıcı -------------------------------------------

  @override
  Future<List<DhikrItem>> dhikrItems() => _dhikrs.allItems();

  @override
  Future<DhikrItem> saveDhikr(DhikrDraft draft) => _dhikrs.insertDraft(draft);

  @override
  Future<void> updateDhikr(DhikrItem item) => _dhikrs.update(item);

  @override
  Future<DhikrItem?> incrementDhikr(int id, {int step = 1}) =>
      _dhikrs.incrementCount(id, step: step);

  @override
  Future<DhikrItem?> resetDhikr(int id) => _dhikrs.resetCount(id);

  @override
  Future<void> deleteDhikr(int id) => _dhikrs.delete(id);

  @override
  Future<DhikrDraft> analyzeSharedContent(String textOrUrl) =>
      _shareService.analyzeSharedContent(
        textOrUrl,
        geminiApiKey: _settings.geminiApiKey,
        content: _dhikrContent,
      );

  @override
  Stream<String> get sharedTexts => _shareService.sharedTexts;

  @override
  Future<String?> takeInitialSharedText() =>
      _shareService.takeInitialSharedText();

  @override
  Future<bool> openExternalUrl(String url) =>
      _shareService.openExternalUrl(url);

  // ---- Bildirimler ---------------------------------------------------------------

  @override
  Stream<PrayerPrompt> get notificationPrompts => _notifications.prompts;

  @override
  PrayerPrompt? takeLaunchPrompt() {
    final prompt = _notifications.launchPrompt;
    _notifications.launchPrompt = null;
    return prompt;
  }

  @override
  Future<bool> requestNotificationPermission() =>
      _notifications.requestPermissions();

  @override
  Future<void> rescheduleNotifications() => _scheduler.reschedule();

  @override
  Future<NotificationHealth> notificationHealth() async => NotificationHealth(
    exactAlarmsAllowed: await _notifications.canScheduleExactAlarms(),
  );

  @override
  Future<void> openExactAlarmSettings() =>
      _notifications.openExactAlarmSettings();

  // ---- Veritabanı sağlığı --------------------------------------------------------

  @override
  String? get corruptedDatabaseBackup => _settings.corruptedDbBackup;

  @override
  Future<void> dismissCorruptedDatabaseNotice() =>
      _settings.setCorruptedDbBackup(null);

  // ---- Telefon Ana Ekran Widget'ı ------------------------------------------------

  @override
  Future<bool> syncHomeWidget() async {
    final loc = _settings.effectiveLocation;
    if (loc == null) return false;
    final now = DateTime.now();
    final today = trackingDay(now);
    final todayTimes = timesFor(today);
    final calToday = dateOnly(now);
    final upcoming = [
      for (final d in [addDays(calToday, -1), calToday, addDays(calToday, 1)])
        ?timesFor(d),
    ];
    final records = await recordsForDate(today);
    // Widget uygulama açılmadan da doğru kalsın: dünden başlayarak 7 günlük program.
    final schedule = [
      for (var i = -1; i <= 5; i++) ?timesFor(addDays(calToday, i)),
    ];
    final snapshot = buildHomeWidgetSnapshot(
      now: now,
      location: loc,
      todayTimes: todayTimes,
      upcomingDays: upcoming,
      todayRecords: records,
      scheduleDays: schedule,
    );
    if (snapshot == null) return false;
    return _homeWidget.updateWidget(snapshot, _widgetTexts);
  }

  @override
  Future<bool> requestPinHomeWidget() async {
    await syncHomeWidget();
    return _homeWidget.requestPinWidget();
  }

  /// Planlama hatası kullanıcıya yansımasın ve işaretlemeyi bozmasın.
  void _rescheduleQuietly() {
    unawaited(syncHomeWidget());
    unawaited(
      _scheduler.reschedule().catchError((Object e) {
        debugPrint('[Notifications] yeniden planlama başarısız: $e');
      }),
    );
  }
}
