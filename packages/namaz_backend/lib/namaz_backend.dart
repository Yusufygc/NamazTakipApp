/// Namaz Takip backend'inin herkese açık yüzü.
///
/// Ön yüz yalnızca bu dosyayı içe aktarır; `src/` altındaki hiçbir dosyaya
/// doğrudan erişmez. Burada dışa açılanlar sade modeller, saf yardımcı
/// fonksiyonlar ve [NamazBackend] arayüzüdür.
library;

export 'src/domain/achievements.dart';
export 'src/domain/dates.dart';
export 'src/domain/models.dart';
export 'src/domain/notification_plan.dart' show NotificationTexts, PrayerPrompt;
export 'src/domain/prayer.dart';
export 'src/domain/prayer_time_service.dart' show AppLocation, CalcMethod;
export 'src/domain/streaks.dart';
export 'src/namaz_backend.dart' show NamazBackend, NamazBackendConfig;
