import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../core/theme/app_theme.dart';

// Ön yüz backend'i yalnızca NamazBackend arayüzü üzerinden tanır. Bu dosya o
// arayüzü Riverpod sağlayıcılarına çevirir; iş kuralı burada yoktur.

/// `main.dart` içinde override edilir.
final backendProvider = Provider<NamazBackend>(
    (ref) => throw UnimplementedError('main içinde override edilmeli'));

// ---- Ayarlar ------------------------------------------------------------------

class SettingsNotifier extends Notifier<AppSettings> {
  NamazBackend get _backend => ref.read(backendProvider);

  @override
  AppSettings build() => _backend.settings;

  /// Backend ayarları kendi içinde değiştirdiğinde (örn. yeni GPS konumu) çağrılır.
  void reload() => state = _backend.settings;

  Future<void> setTheme(String key) async {
    await _backend.setTheme(key);
    reload();
  }

  Future<void> setNotifications(bool enabled) async {
    await _backend.setNotificationsEnabled(enabled);
    reload();
  }

  Future<void> setReminderMinutes(int minutes) async {
    await _backend.setReminderMinutes(minutes);
    reload();
  }

  Future<void> setCalcMethod(CalcMethod method) async {
    await _backend.setCalcMethod(method);
    reload();
  }

  Future<void> useManualLocation(AppLocation location) async {
    await _backend.useManualLocation(location);
    reload();
  }

  Future<void> useAutoLocation() async {
    await _backend.useAutoLocation();
    reload();
  }

  Future<void> setGeminiApiKey(String? apiKey) async {
    await _backend.setGeminiApiKey(apiKey);
    reload();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final paletteProvider = Provider<AppPalette>(
    (ref) => themeByKey(ref.watch(settingsProvider).themeKey).palette);

// ---- Bildirim sağlığı ------------------------------------------------------------

/// Tam zamanlı alarm izni gibi bildirim zamanlamasını etkileyen durum.
/// Ana ekrana dönüldüğünde ve ayar ekranından dönüldüğünde yenilenir.
final notificationHealthProvider = FutureProvider.autoDispose<NotificationHealth>(
    (ref) => ref.read(backendProvider).notificationHealth());

// ---- Veritabanı sağlığı ----------------------------------------------------------

/// Açılışta bozuk bir veritabanı tespit edilip sıfırlandıysa yedek dosya yolunu
/// tutar; kullanıcı onayladığında temizlenir.
class CorruptedDbNoticeNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(backendProvider).corruptedDatabaseBackup;

  Future<void> dismiss() async {
    await ref.read(backendProvider).dismissCorruptedDatabaseNotice();
    state = null;
  }
}

final corruptedDbBackupProvider =
    NotifierProvider<CorruptedDbNoticeNotifier, String?>(
        CorruptedDbNoticeNotifier.new);

// ---- Konum --------------------------------------------------------------------

/// Türkiye'nin 81 ili (elle seçim için).
final citiesProvider =
    Provider<List<AppLocation>>((ref) => ref.read(backendProvider).cities);

/// Konumu tazeler; hata durumunda [LocationException] ile UI'a bildirir.
final locationRefreshProvider = FutureProvider<AppLocation?>((ref) async {
  final location = await ref.read(backendProvider).refreshLocation();
  ref.read(settingsProvider.notifier).reload();
  return location;
});

// ---- Vakitler ------------------------------------------------------------------

/// Kaza ve ısı haritası takibinin başladığı gün.
final trackingStartProvider =
    Provider<DateTime>((ref) => ref.read(backendProvider).trackingStart);

/// Takip günü (gün sınırı: min(04:00, Sabah vakti)). Uygulama açık kalırken gün
/// değişimini yakalamak için [sync] düzenli çağrılır.
class TrackingDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => ref.read(backendProvider).trackingDay();

  void sync() {
    final now = ref.read(backendProvider).trackingDay();
    if (now != state) state = now;
  }
}

final trackingDayProvider =
    NotifierProvider<TrackingDayNotifier, DateTime>(TrackingDayNotifier.new);

DayTimes? _timesFor(Ref ref, DateTime day) {
  ref.watch(settingsProvider); // ayar veya konum değişince yeniden hesapla
  return ref.watch(backendProvider).timesFor(day);
}

final todayTimesProvider = Provider<DayTimes?>(
    (ref) => _timesFor(ref, ref.watch(trackingDayProvider)));

/// Sıradaki vakit hesabı için dün, bugün ve yarın (takvim günü).
final upcomingDaysProvider = Provider<List<DayTimes>>((ref) {
  ref.watch(trackingDayProvider);
  final today = dateOnly(DateTime.now());
  return [
    for (final d in [addDays(today, -1), today, addDays(today, 1)])
      ?_timesFor(ref, d),
  ];
});

// ---- İşaretleme durumu -----------------------------------------------------------

/// İstatistik ekranlarının veriyi yeniden okuması için sayaç.
class StatsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final statsVersionProvider = NotifierProvider<StatsVersion, int>(StatsVersion.new);

class TodayRecordsNotifier extends AsyncNotifier<Map<PrayerType, PrayerRecord>> {
  NamazBackend get _backend => ref.read(backendProvider);

  @override
  Future<Map<PrayerType, PrayerRecord>> build() =>
      _backend.recordsForDate(ref.watch(trackingDayProvider));

  Future<void> _afterMark() async {
    state = AsyncData(await _backend.recordsForDate(ref.read(trackingDayProvider)));
    ref.read(statsVersionProvider.notifier).bump();
    ref.invalidate(qazaProvider);
  }

  /// [date] genellikle takip günüdür; Sabah bildiriminden gelen "dünkü Yatsı"
  /// sorusunda önceki gün olabilir. Backend bildirimleri kendisi yeniden planlar.
  Future<void> markPerformed(DateTime date, PrayerType prayer,
      {required bool congregation}) async {
    await _backend.markPerformed(date, prayer, congregation: congregation);
    await _afterMark();
  }

  Future<void> markMissed(DateTime date, PrayerType prayer) async {
    await _backend.markMissed(date, prayer);
    await _afterMark();
  }
}

final todayRecordsProvider =
    AsyncNotifierProvider<TodayRecordsNotifier, Map<PrayerType, PrayerRecord>>(
        TodayRecordsNotifier.new);

// ---- Kaza ----------------------------------------------------------------------

class QazaNotifier extends AsyncNotifier<List<QazaItem>> {
  @override
  Future<List<QazaItem>> build() => ref.read(backendProvider).qazaItems();

  Future<void> compensate(QazaItem item) async {
    await ref.read(backendProvider).compensate(item);
    ref.invalidateSelf();
    ref.invalidate(todayRecordsProvider);
    ref.read(statsVersionProvider.notifier).bump();
  }
}

final qazaProvider = AsyncNotifierProvider.autoDispose<QazaNotifier, List<QazaItem>>(
    QazaNotifier.new);

// ---- Zikir & Sosyal Medya Yakalayıcı -------------------------------------------

class DhikrNotifier extends AsyncNotifier<List<DhikrItem>> {
  NamazBackend get _backend => ref.read(backendProvider);

  @override
  Future<List<DhikrItem>> build() => _backend.dhikrItems();

  Future<DhikrItem> saveDraft(DhikrDraft draft) async {
    final saved = await _backend.saveDhikr(draft);
    state = AsyncData(await _backend.dhikrItems());
    return saved;
  }

  Future<void> updateItem(DhikrItem item) async {
    await _backend.updateDhikr(item);
    state = AsyncData(await _backend.dhikrItems());
  }

  Future<DhikrItem?> increment(int id, {int step = 1}) async {
    final updated = await _backend.incrementDhikr(id, step: step);
    state = AsyncData(await _backend.dhikrItems());
    return updated;
  }

  Future<DhikrItem?> resetCount(int id) async {
    final updated = await _backend.resetDhikr(id);
    state = AsyncData(await _backend.dhikrItems());
    return updated;
  }

  Future<void> toggleFavorite(DhikrItem item) async {
    await _backend.updateDhikr(item.copyWith(isFavorite: !item.isFavorite));
    state = AsyncData(await _backend.dhikrItems());
  }

  Future<void> delete(int id) async {
    await _backend.deleteDhikr(id);
    state = AsyncData(await _backend.dhikrItems());
  }

  Future<DhikrDraft> analyzeShared(String textOrUrl) =>
      _backend.analyzeSharedContent(textOrUrl);

  Future<bool> openUrl(String url) => _backend.openExternalUrl(url);

  Stream<String> get sharedTexts => _backend.sharedTexts;

  Future<String?> takeInitialSharedText() => _backend.takeInitialSharedText();
}

final dhikrProvider =
    AsyncNotifierProvider<DhikrNotifier, List<DhikrItem>>(DhikrNotifier.new);

// ---- İstatistik ------------------------------------------------------------------

final weekComparisonProvider = FutureProvider.autoDispose<WeekComparison>((ref) {
  ref.watch(statsVersionProvider);
  return ref.read(backendProvider).weekComparison();
});

final dailyCountsProvider =
    FutureProvider.autoDispose.family<List<DayCount>, int>((ref, days) {
  ref.watch(statsVersionProvider);
  return ref.read(backendProvider).dailyCounts(days);
});

/// Ay görünümü için gün bazlı sayılar; anahtar `DateTime(yıl, ay)`.
final monthCountsProvider =
    FutureProvider.autoDispose.family<List<DayCount>, DateTime>((ref, month) {
  ref.watch(statsVersionProvider);
  return ref.read(backendProvider).monthCounts(month);
});

final radarProvider =
    FutureProvider.autoDispose.family<Map<PrayerType, int>, int>((ref, days) {
  ref.watch(statsVersionProvider);
  return ref.read(backendProvider).radar(days);
});

final gamificationProvider = FutureProvider.autoDispose<GamificationData>((ref) {
  ref.watch(statsVersionProvider);
  return ref.read(backendProvider).gamification();
});
