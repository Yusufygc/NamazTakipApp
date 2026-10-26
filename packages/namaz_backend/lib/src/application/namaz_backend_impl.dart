import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../data/prayer_repository.dart';
import '../data/settings_repository.dart';
import '../data/turkish_cities.dart';
import '../domain/achievements.dart';
import '../domain/dates.dart';
import '../domain/models.dart';
import '../domain/notification_plan.dart';
import '../domain/prayer.dart';
import '../domain/prayer_time_service.dart';
import '../domain/streaks.dart';
import '../namaz_backend.dart';
import '../platform/location_service.dart';
import '../platform/notification_service.dart';
import 'background_service.dart' show BackgroundService;
import 'notification_scheduler.dart';

/// [NamazBackend] uygulaması: depo, servis ve platform katmanlarını birleştirir.
class NamazBackendImpl implements NamazBackend {
  NamazBackendImpl._({
    required SettingsRepository settings,
    required PrayerRepository prayers,
    required NotificationTexts texts,
  })  : _settings = settings,
        _prayers = prayers,
        _scheduler = NotificationScheduler(
          settings: settings,
          prayers: prayers,
          texts: texts,
        );

  final SettingsRepository _settings;
  final PrayerRepository _prayers;
  final NotificationScheduler _scheduler;

  final PrayerTimeService _timeService = const PrayerTimeService();
  final LocationService _location = const LocationService();
  final NotificationService _notifications = NotificationService.instance;

  static Future<NamazBackendImpl> create(NamazBackendConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsRepository(prefs);
    await settings.ensureInstallDate(prayerDay(DateTime.now()));
    final database = await AppDatabase.open();

    await NotificationService.instance.init();

    // Arka plan yenilemesi desteklenmeyen ortamda (ör. masaüstü) uygulamayı durdurmasın.
    try {
      await const BackgroundService().register(config.backgroundEntryPoint);
    } catch (e) {
      debugPrint('[Background] kaydedilemedi: $e');
    }

    return NamazBackendImpl._(
      settings: settings,
      prayers: PrayerRepository(database),
      texts: config.notificationTexts,
    );
  }

  DateTime get _today => prayerDay(DateTime.now());

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

  // ---- Takip ---------------------------------------------------------------------

  @override
  Future<Map<PrayerType, PrayerRecord>> recordsForDate(DateTime date) =>
      _prayers.recordsForDate(date);

  @override
  Future<void> markPerformed(DateTime date, PrayerType prayer,
      {required bool congregation}) async {
    await _prayers.markPerformed(date, prayer, congregation: congregation);
    _rescheduleQuietly();
  }

  @override
  Future<void> markMissed(DateTime date, PrayerType prayer) async {
    await _prayers.markMissed(date, prayer);
    _rescheduleQuietly();
  }

  // ---- Kaza ----------------------------------------------------------------------

  @override
  Future<List<QazaItem>> qazaItems() =>
      _prayers.qazaItems(firstDay: trackingStart, today: _today);

  @override
  Future<void> compensate(QazaItem item) =>
      _prayers.markCompensated(item.date, item.prayer);

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
    final performed =
        await _prayers.performedByPrayer(addDays(today, -(days - 1)), today);
    // Yüzde: kılınan / gün sayısı. Takip başlangıcından önceki günler paydaya girmez.
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

  /// Planlama hatası kullanıcıya yansımasın ve işaretlemeyi bozmasın.
  void _rescheduleQuietly() {
    unawaited(_scheduler.reschedule().catchError((Object e) {
      debugPrint('[Notifications] yeniden planlama başarısız: $e');
    }));
  }
}
