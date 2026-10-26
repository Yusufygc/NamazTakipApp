/// Uygulama açılırken oluşan hata ekranı ve veritabanı kurtarma uyarıları.
abstract final class StartupStrings {
  static const title = 'Uygulama başlatılamadı';
  static const message =
      'Kayıtlarınız okunurken bir sorun oluştu. Yeniden denemek için '
      'aşağıdaki düğmeye dokunun. Sorun sürerse uygulamayı kapatıp yeniden '
      'açın.';

  static String details(Object error) => 'Ayrıntı: $error';

  static const corruptedDbTitle = 'Kayıt dosyası bozulduğu için sıfırlandı';
  static const acknowledge = 'Anladım';

  static String corruptedDbMessage(String backupPath) =>
      'Namaz geçmişinizin tutulduğu veritabanı bozulmuş olarak tespit edildi '
      've temiz bir veritabanı oluşturuldu. Bozuk dosya silinmeden önce '
      'yedeklendi: $backupPath';
}
