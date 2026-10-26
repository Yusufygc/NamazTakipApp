/// Kaza namazları ekranı.
abstract final class QazaStrings {
  static const emptyTitle = 'Kaza namazınız yok';
  static const emptySubtitle = 'Allah kabul etsin.';

  static const overviewTitle = 'Kaza Borcu Özeti';
  static const totalPrayersLabel = 'Kaza Vakti';
  static const totalDaysLabel = 'Eksik Gün';

  static String summary(int count, int days) =>
      'Toplam $count kaza namazı • $days gün';

  static String badge(int count) => '$count Kaza';

  static const autoDetected = 'Otomatik tespit';
  static const markedMissed = 'Kılınmadı olarak işaretlendi';

  static const compensate = 'Kaza Et';
  static const confirmTitle = 'Kaza Namazı';
  static const confirmYes = 'Evet, Kıldım';

  static String confirmBody(String date, String prayerName) =>
      '$date tarihli $prayerName namazını kaza ettiniz mi?';
}
