import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/domain/dates.dart';
import 'package:namaz_backend/src/domain/prayer.dart';
import 'package:namaz_backend/src/domain/streaks.dart';
import 'package:namaz_backend/src/domain/prayer_time_service.dart';

void main() {
  group('prayerDay', () {
    test('gece 00:30 hâlâ dünkü gün', () {
      expect(prayerDay(DateTime(2026, 1, 25, 0, 30)), DateTime(2026, 1, 24));
    });
    test('03:59 dünkü gün, 04:00 bugün', () {
      expect(prayerDay(DateTime(2026, 1, 25, 3, 59)), DateTime(2026, 1, 24));
      expect(prayerDay(DateTime(2026, 1, 25, 4, 0)), DateTime(2026, 1, 25));
    });
    test('ay başında dünkü gün önceki aya düşer', () {
      expect(prayerDay(DateTime(2026, 3, 1, 1, 0)), DateTime(2026, 2, 28));
    });
  });

  group('prayerDay Sabah vaktiyle (gün sınırı = min(04:00, Sabah))', () {
    // Yaz: İstanbul 21 Haziran, Sabah 03:24.
    final summerFajr = DateTime(2026, 6, 21, 3, 24);
    test('yazın Sabah vakti girince gün değişir (03:30 bugündür)', () {
      expect(prayerDay(DateTime(2026, 6, 21, 3, 30), fajrToday: summerFajr),
          DateTime(2026, 6, 21));
    });
    test('yazın Sabah vaktinden önce hâlâ dünkü gün', () {
      expect(prayerDay(DateTime(2026, 6, 21, 3, 23), fajrToday: summerFajr),
          DateTime(2026, 6, 20));
      expect(prayerDay(DateTime(2026, 6, 21, 3, 24), fajrToday: summerFajr),
          DateTime(2026, 6, 21));
    });
    test('Sabah vakti verilmezse eski 04:00 kuralı korunur', () {
      expect(prayerDay(DateTime(2026, 6, 21, 3, 30)), DateTime(2026, 6, 20));
    });

    // Kış: İstanbul 21 Aralık, Sabah 06:46; sınır 04:00 kalır.
    final winterFajr = DateTime(2026, 12, 21, 6, 46);
    test('kışın sınır 04:00 kalır (Sabah geç girse de)', () {
      expect(prayerDay(DateTime(2026, 12, 21, 3, 59), fajrToday: winterFajr),
          DateTime(2026, 12, 20));
      expect(prayerDay(DateTime(2026, 12, 21, 4, 0), fajrToday: winterFajr),
          DateTime(2026, 12, 21));
      expect(prayerDay(DateTime(2026, 12, 21, 5, 0), fajrToday: winterFajr),
          DateTime(2026, 12, 21));
    });
    test('Sabah tam 04:00 ise sınır 04:00', () {
      final f = DateTime(2026, 5, 1, 4, 0);
      expect(prayerDay(DateTime(2026, 5, 1, 3, 59), fajrToday: f), DateTime(2026, 4, 30));
      expect(prayerDay(DateTime(2026, 5, 1, 4, 0), fajrToday: f), DateTime(2026, 5, 1));
    });
    test('gece yarısından sonra yazın da dünkü gün', () {
      expect(prayerDay(DateTime(2026, 6, 21, 0, 30), fajrToday: summerFajr),
          DateTime(2026, 6, 20));
    });
  });

  group('dateKey', () {
    test('ISO biçimi ve geri çevirme', () {
      expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(parseDateKey('2026-01-05'), DateTime(2026, 1, 5));
    });
    test('metin sıralaması tarih sıralamasıdır', () {
      final keys = ['2026-02-01', '2025-12-31', '2026-01-15']..sort();
      expect(keys, ['2025-12-31', '2026-01-15', '2026-02-01']);
    });
  });

  group('streaks', () {
    final today = DateTime(2026, 1, 10);
    test('boş liste', () {
      final s = computeStreaks([], today);
      expect(s.currentStreak, 0);
      expect(s.bestStreak, 0);
    });
    test('bugünle biten seri', () {
      final s = computeStreaks(
          [DateTime(2026, 1, 8), DateTime(2026, 1, 9), DateTime(2026, 1, 10)],
          today);
      expect(s.currentStreak, 3);
      expect(s.bestStreak, 3);
      expect(s.totalFullDays, 3);
    });
    test('dünle biten seri devam eder', () {
      final s = computeStreaks([DateTime(2026, 1, 8), DateTime(2026, 1, 9)], today);
      expect(s.currentStreak, 2);
    });
    test('iki gün önce biten seri kopmuştur ama en iyi seri korunur', () {
      final s = computeStreaks(
          [DateTime(2026, 1, 6), DateTime(2026, 1, 7), DateTime(2026, 1, 8)],
          today);
      expect(s.currentStreak, 0);
      expect(s.bestStreak, 3);
    });
    test('ay sınırını aşan seri', () {
      final s = computeStreaks(
          [DateTime(2025, 12, 31), DateTime(2026, 1, 1), DateTime(2026, 1, 2)],
          DateTime(2026, 1, 2));
      expect(s.currentStreak, 3);
    });
  });

  group('nextPrayer', () {
    DayTimes day(DateTime d) => DayTimes(
          date: d,
          fajr: DateTime(d.year, d.month, d.day, 5),
          sunrise: DateTime(d.year, d.month, d.day, 6, 30),
          dhuhr: DateTime(d.year, d.month, d.day, 12),
          asr: DateTime(d.year, d.month, d.day, 15),
          maghrib: DateTime(d.year, d.month, d.day, 18),
          isha: DateTime(d.year, d.month, d.day, 19, 30),
        );
    final d1 = DateTime(2026, 1, 10);
    final d2 = DateTime(2026, 1, 11);

    test('öğleden sonra sıradaki ikindi', () {
      final n = nextPrayer(DateTime(2026, 1, 10, 13), [day(d1), day(d2)]);
      expect(n!.type, PrayerType.asr);
    });
    test('yatsıdan sonra yarının sabahı, yenileme gerektirmeden', () {
      final n = nextPrayer(DateTime(2026, 1, 10, 22), [day(d1), day(d2)]);
      expect(n!.type, PrayerType.fajr);
      expect(n.time, DateTime(2026, 1, 11, 5));
    });
    test('gece yarısından sonra aynı takvim günün sabahı', () {
      final n = nextPrayer(DateTime(2026, 1, 11, 0, 30), [day(d1), day(d2)]);
      expect(n!.time, DateTime(2026, 1, 11, 5));
    });
  });

  group('PrayerTimeService', () {
    const istanbul = AppLocation(
        latitude: 41.0082, longitude: 28.9784, city: 'İstanbul', country: 'Türkiye');
    test('İstanbul vakitleri sıralı ve makul', () {
      final t = const PrayerTimeService()
          .compute(istanbul, DateTime(2026, 6, 21), CalcMethod.diyanet);
      expect(t.fajr.isBefore(t.sunrise), isTrue);
      expect(t.sunrise.isBefore(t.dhuhr), isTrue);
      expect(t.dhuhr.isBefore(t.asr), isTrue);
      expect(t.asr.isBefore(t.maghrib), isTrue);
      expect(t.maghrib.isBefore(t.isha), isTrue);
      // Haziranda İstanbul öğle ~13:10 (UTC+3), yatsı ~22:30.
      final dhuhrUtc = t.dhuhr.toUtc();
      expect(dhuhrUtc.hour, inInclusiveRange(9, 11));
    });

    test('güneş doğuş vakti ihtiyat için 1,5 dakika (90 sn) öne çekilir', () {
      expect(kSunriseCautionOffset, const Duration(seconds: 90));
      final t = const PrayerTimeService()
          .compute(istanbul, DateTime(2026, 10, 26), CalcMethod.diyanet);
      expect(t.sunrise.second, 0);
      expect(t.fajr.isBefore(t.sunrise), isTrue);
    });
  });
}
