/// Konum alma durumları ve şehir seçimi.
abstract final class LocationStrings {
  static const loading = 'Konum alınıyor...';
  static const notFound = 'Konum bulunamadı';
  static const needed = 'Namaz vakitleri için konumunuz gerekiyor.';

  static const serviceDisabled =
      'Cihazın konum servisi kapalı. Açın veya şehrinizi elle seçin.';
  static const denied =
      'Konum izni verilmedi. İzin verin veya şehrinizi elle seçin.';
  static const deniedForever =
      'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin '
      'veya şehrinizi elle seçin.';
  static const unavailable =
      'Konum alınamadı. Tekrar deneyin veya şehrinizi elle seçin.';

  static const chooseCity = 'Şehir seç';
  static const cityPickerTitle = 'Şehir Seç';
  static const citySearchHint = 'Şehir ara';
}
