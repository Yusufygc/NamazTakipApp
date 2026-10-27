import 'application/namaz_backend_impl.dart';
import 'domain/dhikr.dart';
import 'domain/models.dart';
import 'domain/notification_plan.dart';
import 'domain/prayer.dart';
import 'domain/prayer_time_service.dart';
import 'application/background_service.dart' as bg;

/// Backend'in kurulum ayarları. Ön yüz bunları verir; backend dil, ikon veya
/// arayüz bilmez.
class NamazBackendConfig {
  const NamazBackendConfig({
    required this.notificationTexts,
    required this.backgroundEntryPoint,
  });

  /// Bildirim metinleri (ön yüzün metin sisteminden gelir).
  final NotificationTexts notificationTexts;

  /// Arka plan görevinin giriş noktası: `@pragma('vm:entry-point')` ile işaretli
  /// üst düzey bir fonksiyon. İçinde [NamazBackend.handleBackgroundTasks] çağrılmalıdır.
  final void Function() backgroundEntryPoint;
}

/// Ön yüzün backend ile tek konuşma noktası.
///
/// Ön yüz veritabanını, konum/bildirim/arka plan eklentilerini, vakit
/// hesabını ve istatistik kurallarını bilmez; yalnızca bu arayüzü ve burada
/// dönen sade modelleri kullanır. Bu sayede backend değiştirilebilir ve ön yüz
/// sahte (fake) bir uygulamayla test edilebilir.
abstract interface class NamazBackend {
  /// Backend'i kurar: ayarlar, veritabanı, bildirim ve arka plan görevi.
  /// İzin penceresi açmaz.
  static Future<NamazBackend> create(NamazBackendConfig config) =>
      NamazBackendImpl.create(config);

  /// Arka plan görevinin giriş noktasından çağrılır.
  static void handleBackgroundTasks(NotificationTexts texts) =>
      bg.handleBackgroundTasks(texts);

  // ---- Ayarlar ----------------------------------------------------------------

  /// Ayarların o anki görüntüsü.
  AppSettings get settings;

  Future<void> setTheme(String key);

  /// Açarken bildirim iznini de ister.
  Future<void> setNotificationsEnabled(bool enabled);
  Future<void> setReminderMinutes(int minutes);
  Future<void> setCalcMethod(CalcMethod method);
  Future<void> useManualLocation(AppLocation location);
  Future<void> useAutoLocation();
  Future<void> setGeminiApiKey(String? apiKey);

  /// Elle seçilebilecek şehirler.
  List<AppLocation> get cities;

  // ---- Konum ve vakitler -------------------------------------------------------

  /// Konumu tazeler ve geçerli konumu döner. Elle modda seçili şehri verir;
  /// otomatik modda GPS'i dener, olmazsa son konumu kullanır. Hiç konum yoksa
  /// [LocationException] fırlatır.
  Future<AppLocation?> refreshLocation();

  /// [day] için vakitler; konum yoksa `null`.
  DayTimes? timesFor(DateTime day);

  /// Takip günü (varsayılan: şimdi). Gün sınırı `min(04:00, Sabah vakti)`'dir.
  DateTime trackingDay([DateTime? now]);

  /// Cihaz pusula sensöründen gelen **gerçek kuzeye** göre açı (`0.0` – `360.0`);
  /// konum biliniyorsa manyetik sapma düzeltilmiştir. Cihazda sensör yoksa akış
  /// hata verir (`PlatformException`, kod `NO_SENSOR`).
  Stream<double> get compassHeading;

  // ---- Takip ---------------------------------------------------------------------

  Future<Map<PrayerType, PrayerRecord>> recordsForDate(DateTime date);

  /// Kaydeder ve bildirimleri yeniden planlar.
  Future<void> markPerformed(DateTime date, PrayerType prayer,
      {required bool congregation});

  /// Kaydeder ve bildirimleri yeniden planlar.
  Future<void> markMissed(DateTime date, PrayerType prayer);

  // ---- Kaza & Geçmiş Kaza Borcu Planlayıcı ------------------------------------

  Future<List<QazaItem>> qazaItems();
  Future<void> compensate(QazaItem item);

  QazaDebtPlan get qazaDebtPlan;
  Future<void> setQazaBacklog(Map<PrayerType, int> counts);
  Future<void> decrementQazaBacklog(PrayerType prayer, {int step = 1});
  Future<void> setQazaDailyTarget(int dailyTarget);

  // ---- İstatistik ----------------------------------------------------------------

  /// Takibin başladığı gün.
  DateTime get trackingStart;

  Future<WeekComparison> weekComparison();

  /// Son [days] gün için günlük kılınan sayıları (eskiden yeniye, sıfırlar dahil).
  Future<List<DayCount>> dailyCounts(int days);

  /// [month] ayının günlük sayıları.
  Future<List<DayCount>> monthCounts(DateTime month);

  /// Son [days] günde vakit bazında yüzde (0–100).
  Future<Map<PrayerType, int>> radar(int days);

  Future<GamificationData> gamification();

  // ---- Zikir & Sosyal Medya Yakalayıcı -------------------------------------------

  Future<List<DhikrItem>> dhikrItems();
  Future<DhikrItem> saveDhikr(DhikrDraft draft);
  Future<void> updateDhikr(DhikrItem item);
  Future<DhikrItem?> incrementDhikr(int id, {int step = 1});
  Future<DhikrItem?> resetDhikr(int id);
  Future<void> deleteDhikr(int id);
  Future<DhikrDraft> analyzeSharedContent(String textOrUrl);
  Stream<String> get sharedTexts;
  Future<String?> takeInitialSharedText();
  Future<bool> openExternalUrl(String url);

  // ---- Bildirimler ---------------------------------------------------------------

  /// Bildirime dokunulduğunda sorulacak vakit.
  Stream<PrayerPrompt> get notificationPrompts;

  /// Uygulama bildirimle soğuk başlatıldıysa o vakit; bir kez döner.
  PrayerPrompt? takeLaunchPrompt();

  Future<bool> requestNotificationPermission();
  Future<void> rescheduleNotifications();

  /// Bildirimlerin zamanında gelmesini etkileyen durum (tam zamanlı alarm izni).
  Future<NotificationHealth> notificationHealth();

  /// Sistemin "Alarmlar ve hatırlatıcılar" ayar ekranını açar. Kullanıcı
  /// dönünce [rescheduleNotifications] çağrılmalıdır; mevcut alarmlar yaklaşık
  /// zamanlı kalır.
  Future<void> openExactAlarmSettings();

  // ---- Veritabanı sağlığı -----------------------------------------------------

  /// Açılışta bozuk bir veritabanı dosyası tespit edilip sıfırlandıysa,
  /// silinmeden önce alınan yedeğin yolu (`namaz_takip.db.bozuk-<zaman>`).
  /// Sorun yaşanmadıysa veya kullanıcı uyarıyı kapattıysa `null` döner.
  String? get corruptedDatabaseBackup;

  /// Bozuk veritabanı sıfırlama uyarısını onaylayıp kapatır.
  Future<void> dismissCorruptedDatabaseNotice();

  // ---- Telefon Ana Ekran Widget'ı ---------------------------------------------

  /// Güncel vakitleri ve kılınma durumunu telefon ana ekran widget'ına yazar.
  Future<bool> syncHomeWidget();

  /// Destekleyen başlatıcılarda (Android 8+) ana ekrana widget ekleme penceresini açar.
  Future<bool> requestPinHomeWidget();
}
