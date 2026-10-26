import '../format/text_utils.dart';

/// "X namazını kıldınız mı?" diyaloğu.
abstract final class PrayerDialogStrings {
  static String title(String prayerName) =>
      '${turkishUpper(prayerName)} NAMAZINI';

  static const question = 'KILDINIZ MI?';
  static const congregation = 'Cemaatle kıldım';
  static const performed = 'Kıldım';
  static const missed = 'Kılmadım';
}
