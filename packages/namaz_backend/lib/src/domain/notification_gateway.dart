import 'notification_plan.dart';

/// Planlanan bildirimleri cihaza uygulayan katman. Eklentiye bağlı gerçek
/// uygulama `platform/` içindedir; bu arayüz planlayıcının eklentisiz
/// (örn. testte sahte bir uygulamayla) çalışmasını sağlar.
abstract interface class NotificationGateway {
  /// Kaç gün ilerisi için bildirim planlanacağı (iOS 64 bildirim sınırı yüzünden platforma bağlıdır).
  int get planningDays;

  /// Planı uygular: plandakiler eklenir/üzerine yazılır, plan dışı kalan
  /// bekleyen bildirimler iptal edilir.
  Future<void> apply(List<PlannedNotification> plan,
      {required NotificationTexts texts});

  /// Bekleyen tüm bildirimleri iptal eder.
  Future<void> cancelAll();
}
