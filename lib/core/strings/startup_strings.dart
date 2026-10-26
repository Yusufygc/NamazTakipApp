/// Uygulama açılırken oluşan hata ekranı.
abstract final class StartupStrings {
  static const title = 'Uygulama başlatılamadı';
  static const message =
      'Kayıtlarınız okunurken bir sorun oluştu. Yeniden denemek için '
      'aşağıdaki düğmeye dokunun. Sorun sürerse uygulamayı kapatıp yeniden '
      'açın.';

  static String details(Object error) => 'Ayrıntı: $error';
}
