/// Birden çok ekranda kullanılan genel metinler.
abstract final class CommonStrings {
  static const appName = 'Namaz Takip';
  static const version = '1.0.0';
  static const versionLabel = 'Versiyon $version';
  static const developer = 'Geliştirici: MYY';
  static const copyright = 'Namaz Takip © 2026';
  static const tagline = 'Günlük namazlarınızı kolayca takip edin';

  static const cancel = 'İptal';
  static const dismiss = 'Vazgeç';
  static const retry = 'Tekrar dene';

  static String error(Object e) => 'Hata: $e';

  /// Ayarlar altbilgisi: sürüm ve geliştirici.
  static const footer = '$versionLabel  •  $developer';
}
