import 'package:namaz_backend/namaz_backend.dart';

import 'notification_strings.dart';
import 'prayer_strings.dart';

/// Backend'in [NotificationTexts] portunu, ön yüzün metin sistemiyle doldurur.
/// Backend dil bilmez; hangi vakit için hangi metnin gerektiğini söyler,
/// metni burası üretir.
class AppNotificationTexts implements NotificationTexts {
  const AppNotificationTexts();

  @override
  String get channelName => NotificationStrings.channelName;

  @override
  String get channelDescription => NotificationStrings.channelDescription;

  @override
  String adhanTitle(PrayerType prayer) =>
      NotificationStrings.adhanTitle(prayer.label);

  @override
  String adhanBody(PrayerType prayer) =>
      NotificationStrings.adhanBody(prayer.label);

  @override
  String adhanAskBody(PrayerType prayer, PrayerType asked) =>
      NotificationStrings.adhanAskBody(prayer.label, asked.label);

  @override
  String reminderTitle(PrayerType prayer) =>
      NotificationStrings.reminderTitle(prayer.label);

  @override
  String get reminderBody => NotificationStrings.reminderBody;
}
