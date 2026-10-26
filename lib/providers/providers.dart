import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/achievements.dart';
import '../core/app_theme.dart';
import '../core/date_utils.dart';
import '../core/prayer.dart';
import '../core/streaks.dart';
import '../data/app_database.dart';
import '../data/prayer_repository.dart';
import '../data/settings_repository.dart';
import '../services/location_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_service.dart';

// ---- Altyapı (main.dart'ta override edilir) ----------------------------

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => throw UnimplementedError('main içinde override edilmeli'));

final appDatabaseProvider = Provider<AppDatabase>(
    (ref) => throw UnimplementedError('main içinde override edilmeli'));

final prayerRepositoryProvider =
    Provider<PrayerRepository>((ref) => PrayerRepository(ref.watch(appDatabaseProvider)));

final prayerTimeServiceProvider =
    Provider<PrayerTimeService>((ref) => const PrayerTimeService());

final locationServiceProvider =
    Provider<LocationService>((ref) => const LocationService());

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) =>
    NotificationScheduler(
      settings: ref.watch(settingsRepositoryProvider),
      prayers: ref.watch(prayerRepositoryProvider),
    ));

// ---- Ayarlar ------------------------------------------------------------

class AppSettings {
  const AppSettings({
    required this.themeKey,
    required this.notificationsEnabled,
    required this.reminderMinutes,
    required this.calcMethod,
    required this.locationMode,
    required this.manualLocation,
    required this.location,
  });

  final String themeKey;
  final bool notificationsEnabled;
  final int reminderMinutes;
  final CalcMethod calcMethod;
  final LocationMode locationMode;
  final AppLocation? manualLocation;

  /// Hesaplamada kullanılan geçerli konum (yoksa null).
  final AppLocation? location;
}

class SettingsNotifier extends Notifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => _read();

  AppSettings _read() {
    final r = _repo;
    return AppSettings(
      themeKey: r.themeKey,
      notificationsEnabled: r.notificationsEnabled,
      reminderMinutes: r.reminderMinutes,
      calcMethod: r.calcMethod,
      locationMode: r.locationMode,
      manualLocation: r.manualLocation,
      location: r.effectiveLocation,
    );
  }

  Future<void> _after() async {
    state = _read();
    unawaited(ref.read(notificationSchedulerProvider).reschedule());
  }

  Future<void> setTheme(String key) async {
    await _repo.setThemeKey(key);
    state = _read();
  }

  Future<void> setNotifications(bool v) async {
    if (v) await NotificationService.instance.requestPermissions();
    await _repo.setNotificationsEnabled(v);
    await _after();
  }

  Future<void> setReminderMinutes(int v) async {
    await _repo.setReminderMinutes(v);
    await _after();
  }

  Future<void> setCalcMethod(CalcMethod m) async {
    await _repo.setCalcMethod(m);
    await _after();
  }

  Future<void> useManualLocation(AppLocation l) async {
    await _repo.setManualLocation(l);
    await _repo.setLocationMode(LocationMode.manual);
    await _after();
  }

  Future<void> useAutoLocation() async {
    await _repo.setLocationMode(LocationMode.auto);
    await _after();
  }

  /// GPS'ten alınan konumu kaydeder (ön plan).
  Future<void> saveDetectedLocation(AppLocation l) async {
    await _repo.setLastLocation(l);
    await _after();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final paletteProvider = Provider<AppPalette>(
    (ref) => themeByKey(ref.watch(settingsProvider).themeKey).palette);

// ---- Konum --------------------------------------------------------------

/// Otomatik modda GPS konumunu tazeler; başarısızsa son konumla devam eder.
/// Hata durumunda UI'a bildirmek için [LocationException] fırlatır.
final locationRefreshProvider = FutureProvider<AppLocation?>((ref) async {
  final settings = ref.read(settingsProvider);
  if (settings.locationMode == LocationMode.manual &&
      settings.manualLocation != null) {
    return settings.manualLocation;
  }
  try {
    final loc = await ref.read(locationServiceProvider).current();
    await ref.read(settingsProvider.notifier).saveDetectedLocation(loc);
    return loc;
  } on LocationException {
    if (ref.read(settingsRepositoryProvider).lastLocation != null) {
      return ref.read(settingsRepositoryProvider).lastLocation;
    }
    rethrow;
  }
});

// ---- Vakitler ------------------------------------------------------------

/// Takip günü (gece 04:00'e kadar dünkü gün). Uygulama açık kalırken gün
/// değişimini yakalamak için [sync] düzenli çağrılır.
class TrackingDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => prayerDay(DateTime.now());

  void sync() {
    final now = prayerDay(DateTime.now());
    if (now != state) state = now;
  }
}

final trackingDayProvider =
    NotifierProvider<TrackingDayNotifier, DateTime>(TrackingDayNotifier.new);

DayTimes? _timesFor(Ref ref, DateTime day) {
  final settings = ref.watch(settingsProvider);
  final loc = settings.location;
  if (loc == null) return null;
  return ref.watch(prayerTimeServiceProvider).compute(loc, day, settings.calcMethod);
}

final todayTimesProvider = Provider<DayTimes?>(
    (ref) => _timesFor(ref, ref.watch(trackingDayProvider)));

/// Sıradaki vakit hesabı için bugün + yarın (takvim günü).
final upcomingDaysProvider = Provider<List<DayTimes>>((ref) {
  ref.watch(trackingDayProvider);
  final today = dateOnly(DateTime.now());
  return [
    for (final d in [addDays(today, -1), today, addDays(today, 1)])
      ?_timesFor(ref, d),
  ];
});

// ---- İşaretleme durumu ---------------------------------------------------

class TodayRecordsNotifier extends AsyncNotifier<Map<PrayerType, PrayerRecord>> {
  @override
  Future<Map<PrayerType, PrayerRecord>> build() => ref
      .read(prayerRepositoryProvider)
      .recordsForDate(ref.watch(trackingDayProvider));

  Future<void> _afterMark() async {
    final day = ref.read(trackingDayProvider);
    state = AsyncData(await ref.read(prayerRepositoryProvider).recordsForDate(day));
    ref.read(statsVersionProvider.notifier).bump();
    ref.invalidate(qazaProvider);
    unawaited(ref.read(notificationSchedulerProvider).reschedule());
  }

  /// [date] genellikle takip günüdür; Sabah bildiriminden gelen "dünkü Yatsı"
  /// sorusunda önceki gün olabilir.
  Future<void> markPerformed(DateTime date, PrayerType p,
      {required bool congregation}) async {
    await ref
        .read(prayerRepositoryProvider)
        .markPerformed(date, p, congregation: congregation);
    await _afterMark();
  }

  Future<void> markMissed(DateTime date, PrayerType p) async {
    await ref.read(prayerRepositoryProvider).markMissed(date, p);
    await _afterMark();
  }
}

final todayRecordsProvider =
    AsyncNotifierProvider<TodayRecordsNotifier, Map<PrayerType, PrayerRecord>>(
        TodayRecordsNotifier.new);

/// İstatistik ekranlarının veriyi yeniden okuması için sayaç.
class StatsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final statsVersionProvider = NotifierProvider<StatsVersion, int>(StatsVersion.new);

// ---- Kaza ----------------------------------------------------------------

class QazaNotifier extends AsyncNotifier<List<QazaItem>> {
  @override
  Future<List<QazaItem>> build() async {
    final today = ref.watch(trackingDayProvider);
    final first = ref.read(settingsRepositoryProvider).installDate ?? today;
    return ref.read(prayerRepositoryProvider).qazaItems(firstDay: first, today: today);
  }

  Future<void> compensate(QazaItem item) async {
    await ref.read(prayerRepositoryProvider).markCompensated(item.date, item.prayer);
    ref.invalidateSelf();
    ref.invalidate(todayRecordsProvider);
    ref.read(statsVersionProvider.notifier).bump();
  }

  void refresh() => ref.invalidateSelf();
}

final qazaProvider = AsyncNotifierProvider.autoDispose<QazaNotifier, List<QazaItem>>(
    QazaNotifier.new);

// ---- İstatistik -----------------------------------------------------------

class WeekComparison {
  const WeekComparison(this.currentWeek, this.previousWeek);

  final int currentWeek;
  final int previousWeek;

  int get diff => currentWeek - previousWeek;
}

class GamificationData {
  const GamificationData(this.streaks, this.achievements);

  final StreakStats streaks;
  final List<Achievement> achievements;
}

final weekComparisonProvider = FutureProvider.autoDispose<WeekComparison>((ref) async {
  ref.watch(statsVersionProvider);
  final repo = ref.read(prayerRepositoryProvider);
  final today = ref.read(trackingDayProvider);
  final counts = await repo.dailyCounts(addDays(today, -13), today);
  final prev = counts.take(7).fold<int>(0, (s, c) => s + c.performed);
  final cur = counts.skip(7).fold<int>(0, (s, c) => s + c.performed);
  return WeekComparison(cur, prev);
});

/// Son [n] gün için günlük kılınan sayısı (eskiden yeniye).
final dailyCountsProvider = FutureProvider.autoDispose.family<List<DayCount>, int>((ref, n) async {
  ref.watch(statsVersionProvider);
  final today = ref.read(trackingDayProvider);
  return ref.read(prayerRepositoryProvider).dailyCounts(addDays(today, -(n - 1)), today);
});

/// Ay görünümü için gün bazlı sayılar; anahtar `DateTime(yıl, ay)`.
final monthCountsProvider = FutureProvider.autoDispose.family<List<DayCount>, DateTime>((ref, month) async {
  ref.watch(statsVersionProvider);
  final first = DateTime(month.year, month.month);
  final last = DateTime(month.year, month.month + 1, 0);
  return ref.read(prayerRepositoryProvider).dailyCounts(first, last);
});

final radarProvider = FutureProvider.autoDispose.family<Map<PrayerType, int>, int>((ref, days) async {
  ref.watch(statsVersionProvider);
  final repo = ref.read(prayerRepositoryProvider);
  final today = ref.read(trackingDayProvider);
  final performed = await repo.performedByPrayer(addDays(today, -(days - 1)), today);
  // Yüzde: kılınan / gün sayısı. Takip başlangıcından önceki günler paydaya girmez.
  final start = ref.read(settingsRepositoryProvider).installDate ?? today;
  final span = daysDiff(today, start) + 1;
  final denom = span < days ? span : days;
  return {
    for (final e in performed.entries)
      e.key: denom <= 0 ? 0 : ((e.value / denom) * 100).round().clamp(0, 100),
  };
});

final gamificationProvider = FutureProvider.autoDispose<GamificationData>((ref) async {
  ref.watch(statsVersionProvider);
  final repo = ref.read(prayerRepositoryProvider);
  final today = ref.read(trackingDayProvider);
  final streaks = computeStreaks(await repo.fullDays(), today);
  return GamificationData(
    streaks,
    buildAchievements(
      streaks: streaks,
      totalCongregation: await repo.totalCongregation(),
      totalFajr: await repo.totalPerformed(PrayerType.fajr),
    ),
  );
});
