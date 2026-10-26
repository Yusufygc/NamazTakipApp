/// Bildirim kanalı ve bildirim metinleri.
///
/// Bildirimlerde ikon/emoji kullanılmaz; uygulama ikonu sistem tarafından
/// gösterilir.
abstract final class NotificationStrings {
  static const channelName = 'Namaz Vakitleri';
  static const channelDescription = 'Ezan vakti ve namaz hatırlatmaları';

  static String adhanTitle(String prayerName) => '$prayerName Vakti';

  /// Önceki vakit zaten işaretliyse yalnızca vaktin girdiği söylenir.
  static String adhanBody(String prayerName) => '$prayerName vakti girdi.';

  static String adhanAskBody(String prayerName, String askedPrayerName) =>
      'Selamünaleyküm! $prayerName ezanı okundu. '
      '$askedPrayerName namazını kıldın mı?';

  static String reminderTitle(String prayerName) =>
      '$prayerName Namazını Kıldınız mı?';

  static const reminderBody = 'Namazınızı işaretlemek için dokunun.';
}
