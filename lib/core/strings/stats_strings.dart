/// Süreç ekranı: performans, ısı haritası, karşılaştırma.
abstract final class StatsStrings {
  static const tabPerformance = 'Performans';
  static const tabHeatmap = 'Isı Haritası';
  static const tabComparison = 'Karşılaştırma';

  static String days(int n) => '$n Gün';

  static String percent(int n) => '%$n';

  // Isı haritası
  static const previousMonth = 'Önceki ay';
  static const nextMonth = 'Sonraki ay';
  static const legendFull = '5/5';
  static const legendMost = '3-4';
  static const legendFew = '1-2';
  static const legendNone = '0';

  static String dayCount(int performed) => '$performed/5';

  static String cellSemantics(String date, int performed) =>
      '$date: $performed / 5';

  // Karşılaştırma
  static const thisWeek = 'Bu Hafta';
  static const lastWeek = 'Geçen Hafta';
  static const progress = 'Gelişim Durumu';

  static String progressValue(int diff) => '${diff > 0 ? '+' : ''}$diff Vakit';

  static const trendUp = 'Yükselişte';
  static const trendDown = 'Düşüşte';
  static const trendFlat = 'Değişim yok';

  static const weekly = 'Haftalık';
  static const monthly = 'Aylık';
}
