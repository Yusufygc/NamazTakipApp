import 'application/namaz_backend_impl.dart';
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

  // ---- Takip ---------------------------------------------------------------------

  Future<Map<PrayerType, PrayerRecord>> recordsForDate(DateTime date);

  /// Kaydeder ve bildirimleri yeniden planlar.
  Future<void> markPerformed(DateTime date, PrayerType prayer,
      {required bool congregation});

  /// Kaydeder ve bildirimleri yeniden planlar.
  Future<void> markMissed(DateTime date, PrayerType prayer);

  // ---- Kaza ----------------------------------------------------------------------

  Future<List<QazaItem>> qazaItems();
  Future<void> compensate(QazaItem item);

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
}
