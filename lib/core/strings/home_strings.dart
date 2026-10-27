import 'package:namaz_backend/namaz_backend.dart';

/// Ana ekran, sayaç, kerahat vakti ve Kıble pusulası metinleri.
abstract final class HomeStrings {
  static const noTimes = 'Vakit bilgisi yok';

  static String todaysPrayers(String date) => 'BUGÜNÜN NAMAZLARI  •  $date';

  static String nextPrayer(String name) => 'Sıradaki Namaz: $name';

  static String timeLabel(String time) => 'Vakit: $time';

  static const nextBadge = 'SIRADAKİ VAKİT';
  static const nextTag = 'Sıradaki';
  static const sunriseTag = 'Güneş Doğuşu';
  static const congregationBadge = 'Cemaatle';
  static const performedBadge = 'Kılındı';
  static const missedBadge = 'Kılınmadı';
  static const pendingBadge = 'Bekliyor';

  static String completedSummary(int done, int total) =>
      '$done / $total Vakit Eda Edildi';

  static String kerahatBadge(KerahatType type, int mins) {
    switch (type) {
      case KerahatType.sunrise:
        return 'Kerahat (İşrak) • $mins dk kaldı';
      case KerahatType.istiva:
        return 'Kerahat (İstiva) • $mins dk kaldı';
      case KerahatType.sunset:
        return 'Kerahat (İsfirar) • $mins dk kaldı';
    }
  }

  // Kıble Pusulası
  static const qiblaButton = 'Kıble';
  static const qiblaSheetTitle = 'Selçuklu Kıble Pusulası';
  static const qiblaAligned = 'Kıble Yönüne Hizalandınız';
  static const qiblaRotateHint =
      'Cihazı düz tutarak döndürün veya kadranı parmağınızla çevirin';
  static const qiblaNoLocation =
      'Konum belirlenmediği için Kıble yönü hesaplanamıyor. Ayarlar ekranından şehir seçin veya konumu otomatik bulun.';
  static const qiblaAngleLabel = 'Kıble Açısı';
  static const qiblaDistanceLabel = 'Kâbe Mesafesi';
  static const qiblaNorth = 'K';
  static const qiblaEast = 'D';
  static const qiblaSouth = 'G';
  static const qiblaWest = 'B';

  static String qiblaDistanceKm(int km) => '$km km';
  static String qiblaDegree(int deg) => '$deg°';

  /// Ekran okuyucular için sayaç açıklaması.
  static String countdownSemantics(String name, String remaining) =>
      '$name vaktine $remaining kaldı';

  /// Ekran okuyucular için vakit kartı açıklaması.
  static String prayerSemantics(
    String name,
    String time, {
    required bool performed,
    required bool missed,
  }) {
    final status = performed ? ', kılındı' : (missed ? ', kılınmadı' : '');
    return '$name $time$status';
  }
}
