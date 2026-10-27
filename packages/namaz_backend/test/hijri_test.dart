import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_backend/src/domain/hijri_month_starts.dart';

String _fmt(HijriDate h) => '${h.day}.${h.month}.${h.year}';

void main() {
  group('HijriDate (Diyanet ay başı tablosu)', () {
    // Diyanet takvimine dayanan yayınlardaki bayram, Ramazan, üç aylar tarihleri.
    final cases = <DateTime, String>{
      DateTime(2026, 2, 19): '1.9.1447', // Ramazan başı
      DateTime(2026, 3, 20): '1.10.1447', // Ramazan Bayramı 1. gün
      DateTime(2026, 5, 26): '9.12.1447', // Kurban arefesi
      DateTime(2026, 5, 27): '10.12.1447', // Kurban Bayramı 1. gün
      DateTime(2026, 6, 16): '1.1.1448', // Hicri yılbaşı
      DateTime(2026, 10, 27): '16.5.1448', // uygulamada görülen tarih
      DateTime(2026, 12, 10): '1.7.1448', // Üç aylar başı
      DateTime(2027, 1, 9): '1.8.1448', // Şaban başı
      DateTime(2027, 2, 8): '1.9.1448', // Ramazan başı
      DateTime(2027, 3, 5): '26.9.1448', // Kadir Gecesi
      DateTime(2027, 5, 16): '10.12.1448', // Kurban Bayramı 1. gün
    };

    cases.forEach((date, expected) {
      test('${date.toString().substring(0, 10)} → $expected', () {
        expect(_fmt(HijriDate.fromGregorian(date)), expected);
      });
    });

    test('tablo kapsamında her gün bir öncekinden tam bir gün ileridedir', () {
      var previous = HijriDate.fromGregorian(DateTime(2025, 6, 26));
      expect(_fmt(previous), '1.1.1447');
      for (var d = DateTime(2025, 6, 27);
          !d.isAfter(DateTime(2027, 5, 7));
          d = addDays(d, 1)) {
        final current = HijriDate.fromGregorian(d);
        final nextDay = current.day == 1
            ? (previous.day == 29 || previous.day == 30)
            : current.day == previous.day + 1 &&
                current.month == previous.month &&
                current.year == previous.year;
        expect(nextDay, isTrue,
            reason: '$d: ${_fmt(previous)} → ${_fmt(current)}');
        previous = current;
      }
    });

    test('ay başları arasındaki uzunluk 29 veya 30 gündür', () {
      for (var i = 0; i + 1 < kHijriMonthStarts.length; i++) {
        final length =
            daysDiff(kHijriMonthStarts[i + 1].date, kHijriMonthStarts[i].date);
        expect(length, anyOf(29, 30),
            reason: '${kHijriMonthStarts[i].hijriYear}/'
                '${kHijriMonthStarts[i].hijriMonth}');
      }
    });

    test('her ay başı tabloda ayın 1. günüdür', () {
      for (final start in kHijriMonthStarts) {
        final table = HijriDate.fromGregorian(start.date);
        expect(table.day, 1);
      }
    });

    test('tablo dışında (2030) algoritma geçerli bir tarih döner', () {
      final h = HijriDate.fromGregorian(DateTime(2030, 1, 1));
      expect(h.month, inInclusiveRange(1, 12));
      expect(h.day, inInclusiveRange(1, 30));
      expect(h.year, inInclusiveRange(1451, 1452));
    });
  });

  group('detectSpecialDay (Diyanet tarihleri)', () {
    SpecialDayId? special(DateTime d) =>
        detectSpecialDay(d, HijriDate.fromGregorian(d));

    test('Miraç, Berat, Regaip, Mevlid kandilleri Diyanet gününe düşer', () {
      expect(special(DateTime(2026, 1, 15)), SpecialDayId.mirajKandil);
      expect(special(DateTime(2026, 2, 2)), SpecialDayId.beratKandil);
      expect(special(DateTime(2026, 12, 10)), SpecialDayId.regaipKandil);
      expect(special(DateTime(2027, 1, 4)), SpecialDayId.mirajKandil);
      expect(special(DateTime(2027, 1, 22)), SpecialDayId.beratKandil);
      expect(special(DateTime(2025, 9, 3)), SpecialDayId.mawlidKandil);
    });

    test('Bayramlar ve Kadir Gecesi Diyanet gününe düşer', () {
      expect(special(DateTime(2026, 3, 20)), SpecialDayId.eidAlFitr);
      expect(special(DateTime(2026, 3, 22)), SpecialDayId.eidAlFitr);
      expect(special(DateTime(2026, 5, 26)), SpecialDayId.arafah);
      expect(special(DateTime(2026, 5, 27)), SpecialDayId.eidAlAdha);
      expect(special(DateTime(2027, 2, 8)), SpecialDayId.ramadanStart);
      expect(special(DateTime(2027, 3, 5)), SpecialDayId.qadrNight);
      expect(special(DateTime(2027, 5, 16)), SpecialDayId.eidAlAdha);
    });

    test('her Recep ayında Regaip tam bir kez ve ilk Cuma öncesi Perşembe', () {
      for (final recep in kHijriMonthStarts.where((s) => s.hijriMonth == 7)) {
        final flagged = <DateTime>[];
        for (var i = -3; i < 33; i++) {
          final d = addDays(recep.date, i);
          if (special(d) == SpecialDayId.regaipKandil) flagged.add(d);
        }
        expect(flagged, hasLength(1), reason: 'Recep ${recep.hijriYear}');
        final regaip = flagged.single;
        expect(regaip.weekday, DateTime.thursday);
        final friday = addDays(regaip, 1);
        // Cuma, Recep'in ilk yedi günü içinde olmalı.
        final h = HijriDate.fromGregorian(friday);
        expect(h.month, 7);
        expect(h.day, lessThanOrEqualTo(7));
      }
    });
  });
}
