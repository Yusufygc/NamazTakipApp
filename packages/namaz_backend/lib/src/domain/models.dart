import 'achievements.dart';
import 'prayer.dart';
import 'prayer_time_service.dart';
import 'streaks.dart';

/// Konumun nasıl belirleneceği.
enum LocationMode { auto, manual }

/// Bir vaktin, bir gün için kayıtlı durumu.
class PrayerRecord {
  const PrayerRecord({
    required this.date,
    required this.prayer,
    required this.status,
    required this.isCongregation,
  });

  final DateTime date;
  final PrayerType prayer;
  final PrayerStatus status;
  final bool isCongregation;
}

/// Kaza listesindeki tek satır.
class QazaItem {
  const QazaItem(this.date, this.prayer, this.status);

  final DateTime date;
  final PrayerType prayer;

  /// `pending` = gün bitti ama işaretlenmedi, `missed` = kullanıcı "kılmadım" dedi.
  final PrayerStatus status;

  bool get isAutoDetected => status == PrayerStatus.pending;
}

/// Bir günün, kılınan vakit sayısıyla özeti.
class DayCount {
  const DayCount(this.date, this.performed);

  final DateTime date;
  final int performed;
}

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

/// Kullanıcı ayarlarının o anki görüntüsü.
class AppSettings {
  const AppSettings({
    required this.themeKey,
    required this.notificationsEnabled,
    required this.reminderMinutes,
    required this.calcMethod,
    required this.locationMode,
    required this.manualLocation,
    required this.location,
    this.hasGeminiApiKey = false,
  });

  /// Arayüzün seçtiği temanın anahtarı. Backend için anlamsız bir metindir;
  /// yalnızca kalıcılığı sağlar.
  final String themeKey;
  final bool notificationsEnabled;
  final int reminderMinutes;
  final CalcMethod calcMethod;
  final LocationMode locationMode;
  final AppLocation? manualLocation;

  /// Vakit hesabında kullanılan geçerli konum (yoksa null).
  final AppLocation? location;

  /// Sosyal medya zikir kazıma için isteğe bağlı Gemini API anahtarı tanımlı mı.
  final bool hasGeminiApiKey;
}

/// Bildirimlerin zamanında gelmesini etkileyen sistem durumu.
class NotificationHealth {
  const NotificationHealth({required this.exactAlarmsAllowed});

  /// Tam zamanlı alarm izni. Yoksa bildirimler yaklaşık zamanlı kurulur ve
  /// (Android'de) bir saate kadar geç gelebilir. Android dışında her zaman `true`.
  final bool exactAlarmsAllowed;

  bool get isHealthy => exactAlarmsAllowed;
}

enum LocationFailure { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException($failure)';
}
