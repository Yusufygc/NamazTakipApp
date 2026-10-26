/// Ana ekran ve sayaç.
abstract final class HomeStrings {
  static const noTimes = 'Vakit bilgisi yok';

  static String todaysPrayers(String date) => 'BUGÜNÜN NAMAZLARI  •  $date';

  static String nextPrayer(String name) => 'Sıradaki Namaz: $name';

  static String timeLabel(String time) => 'Vakit: $time';

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
