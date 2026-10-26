import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/domain/dates.dart';
import 'package:namaz_backend/src/domain/prayer.dart';
import 'package:namaz_backend/src/data/turkish_cities.dart';
import 'package:namaz_backend/src/domain/notification_plan.dart';

/// Backend metin üretmez; test, portu basit bir sahte ile doldurur.
class _TestTexts implements NotificationTexts {
  const _TestTexts();

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

DayTimes _day(DateTime d) => DayTimes(
      date: d,
      fajr: DateTime(d.year, d.month, d.day, 5),
      sunrise: DateTime(d.year, d.month, d.day, 6, 30),
      dhuhr: DateTime(d.year, d.month, d.day, 12),
      asr: DateTime(d.year, d.month, d.day, 15),
      maghrib: DateTime(d.year, d.month, d.day, 18),
      isha: DateTime(d.year, d.month, d.day, 19, 30),
    );

void main() {
  final d1 = DateTime(2026, 1, 10);
  final d2 = DateTime(2026, 1, 11);

  test('id her vakit/tür için benzersiz ve kararlı', () {
    final ids = <int>{};
    for (final t in PrayerType.values) {
      ids.add(notificationId(d1, t, reminder: false));
      ids.add(notificationId(d1, t, reminder: true));
    }
    expect(ids.length, 10);
    expect(notificationId(d1, PrayerType.asr, reminder: true),
        notificationId(d1, PrayerType.asr, reminder: true));
    expect(notificationId(d1, PrayerType.fajr, reminder: false), 202601100);
    // 32 bit işaretli sınırın altında kalmalı (Android bildirim id'si).
    expect(notificationId(DateTime(2099, 12, 31), PrayerType.isha, reminder: true),
        lessThan(2147483647));
  });

  test('planda aynı id iki kez bulunmaz (çift bildirim yok)', () {
    final plan = buildNotificationPlan(
      now: DateTime(2026, 1, 10, 0, 0),
      days: [_day(d1), _day(d2)],
      isDone: (_, _) => false,
      reminderMinutes: 15,
      texts: const _TestTexts(),
    );
    expect(plan.map((n) => n.id).toSet().length, plan.length);
    expect(plan.length, 20);
  });

  test('geçmiş vakitler için bildirim planlanmaz', () {
    final plan = buildNotificationPlan(
      now: DateTime(2026, 1, 10, 13),
      days: [_day(d1)],
      isDone: (_, _) => false,
      reminderMinutes: 15,
      texts: const _TestTexts(),
    );
    // Öğle ezanı ve hatırlatması geçti; ikindi, akşam, yatsı kaldı.
    expect(plan.every((n) => n.scheduledAt.isAfter(DateTime(2026, 1, 10, 13))), isTrue);
    expect(plan.length, 6);
  });

  test('ezan bildirimi önceki vakti sorar; Sabah dünkü Yatsı yı sorar', () {
    final plan = buildNotificationPlan(
      now: DateTime(2026, 1, 9, 23),
      days: [_day(d1)],
      isDone: (_, _) => false,
      reminderMinutes: 15,
      texts: const _TestTexts(),
    );
    final fajr = plan.firstWhere(
        (n) => n.id == notificationId(d1, PrayerType.fajr, reminder: false));
    expect(fajr.body, contains('Yatsı namazını kıldın mı?'));
    final prompt = PrayerPrompt.decode(fajr.payload)!;
    expect(prompt.prayer, PrayerType.isha);
    expect(prompt.date, DateTime(2026, 1, 9));

    final asr = plan.firstWhere(
        (n) => n.id == notificationId(d1, PrayerType.asr, reminder: false));
    expect(asr.body, contains('Öğle namazını kıldın mı?'));
  });

  test('kılınmış vakit için hatırlatma ve soru üretilmez', () {
    final plan = buildNotificationPlan(
      now: DateTime(2026, 1, 10, 4),
      days: [_day(d1)],
      isDone: (date, p) => date == d1 && p == PrayerType.dhuhr,
      reminderMinutes: 15,
      texts: const _TestTexts(),
    );
    expect(plan.any((n) => n.id == notificationId(d1, PrayerType.dhuhr, reminder: true)),
        isFalse);
    final asr = plan.firstWhere(
        (n) => n.id == notificationId(d1, PrayerType.asr, reminder: false));
    expect(asr.body, isNot(contains('kıldın mı')));
    expect(asr.payload, isNull);
  });

  test('hatırlatma ezandan belirlenen dakika sonra gelir', () {
    final plan = buildNotificationPlan(
      now: DateTime(2026, 1, 10, 4),
      days: [_day(d1)],
      isDone: (_, _) => false,
      reminderMinutes: 20,
      texts: const _TestTexts(),
    );
    final r = plan.firstWhere(
        (n) => n.id == notificationId(d1, PrayerType.maghrib, reminder: true));
    expect(r.scheduledAt, DateTime(2026, 1, 10, 18, 20));
  });

  test('payload gidiş-dönüş', () {
    final p = PrayerPrompt(DateTime(2026, 1, 9), PrayerType.isha);
    expect(PrayerPrompt.decode(p.encode()), p);
    expect(PrayerPrompt.decode('saçma'), isNull);
    expect(PrayerPrompt.decode(null), isNull);
  });

  test('81 il tanımlı ve koordinatlar Türkiye sınırları içinde', () {
    expect(kTurkishCities.length, 81);
    expect(kTurkishCities.map((c) => c.city).toSet().length, 81);
    for (final c in kTurkishCities) {
      expect(c.latitude, inInclusiveRange(35.8, 42.2), reason: c.city);
      expect(c.longitude, inInclusiveRange(25.6, 44.9), reason: c.city);
    }
  });

  test('dateOnly saat bilgisini atar', () {
    expect(dateOnly(DateTime(2026, 1, 10, 23, 59)), DateTime(2026, 1, 10));
  });
}
