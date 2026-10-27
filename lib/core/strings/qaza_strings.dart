/// Kaza namazları ve geçmiş yıllar kaza borcu planlayıcı metinleri.
abstract final class QazaStrings {
  static const emptyTitle = 'Kaza namazınız yok';
  static const emptySubtitle = 'Allah kabul etsin.';

  static const overviewTitle = 'Kaza Borcu Özeti';
  static const totalPrayersLabel = 'Kaza Vakti';
  static const totalDaysLabel = 'Eksik Gün';
  static const backlogPrayersLabel = 'Geçmiş Borç';
  static const dailyTargetLabel = 'Günlük Hedef';

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

  // Geçmiş Yıllar Kaza Borcu Hesaplayıcı ve Günlük Hedef
  static const debtPlannerButton = 'Geçmiş Borç Hesapla / Hedef Belirle';
  static const backlogSectionTitle = 'GEÇMİŞ YILLAR KAZA BORCU (VAKİT BAZLI)';
  static const trackedSectionTitle = 'GÜNLÜK TAKİPTEN DÜŞEN KAZA NAMAZLARI';
  static const decrementBacklogButton = '1 Kaza Düş';
  static const wizardTitle = 'Geçmiş Kaza Borcu & Hedef';
  static const wizardSubtitle =
      'Uygulamayı kurmadan önceki yıllardan kalan tahmini borcunuzu yıl/ay/gün olarak hesaplayabilir veya vakit sayılarını doğrudan girebilirsiniz.';
  static const wizardYearsLabel = 'Yıl';
  static const wizardMonthsLabel = 'Ay';
  static const wizardDaysLabel = 'Gün';
  static const wizardApplyDurationButton = 'Süreden Hesapla ve Vakitlere Ekle';
  static const wizardDailyTargetLabel = 'Günlük Kaza Kılma Hedefi';
  static const wizardSaveButton = 'Kaza Planını Kaydet';

  static String dailyTargetValue(int n) => 'Günde $n Vakit';
  static String estimatedFinish(String dateStr, int days) =>
      'Hedefinize uyarsanız tahmini bitiş: $dateStr ($days gün)';
  static String remainingPrayerCount(int count) => '$count vakit kaldı';
}
