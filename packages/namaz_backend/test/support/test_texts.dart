import 'package:namaz_backend/src/domain/notification_plan.dart';
import 'package:namaz_backend/src/domain/prayer.dart';

/// Backend metin üretmez; test, portu basit bir sahte ile doldurur.
class TestTexts implements NotificationTexts {
  const TestTexts();

  static const _names = {
    PrayerType.fajr: 'Sabah',
    PrayerType.dhuhr: 'Öğle',
    PrayerType.asr: 'İkindi',
    PrayerType.maghrib: 'Akşam',
    PrayerType.isha: 'Yatsı',
  };

  @override
  String get channelName => 'kanal';

  @override
  String get channelDescription => 'açıklama';

  @override
  String adhanTitle(PrayerType prayer) => '${_names[prayer]} Vakti';

  @override
  String adhanBody(PrayerType prayer) => '${_names[prayer]} vakti girdi.';

  @override
  String adhanAskBody(PrayerType prayer, PrayerType asked) =>
      '${_names[prayer]} ezanı okundu. ${_names[asked]} namazını kıldın mı?';

  @override
  String reminderTitle(PrayerType prayer) => '${_names[prayer]} Namazını Kıldınız mı?';

  @override
  String get reminderBody => 'işaretle';
}
