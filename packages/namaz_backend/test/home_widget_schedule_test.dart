import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';

DayTimes _day(int d) => DayTimes(
      date: DateTime(2026, 10, d),
      fajr: DateTime(2026, 10, d, 5, 45),
      sunrise: DateTime(2026, 10, d, 7, 15),
      dhuhr: DateTime(2026, 10, d, 12, 55),
      asr: DateTime(2026, 10, d, 15, 50),
      maghrib: DateTime(2026, 10, d, 18, 15),
      isha: DateTime(2026, 10, d, 19, 35),
    );

void main() {
  const istanbul = AppLocation(
    latitude: 41.0082,
    longitude: 28.9784,
    city: 'İstanbul',
  );

  group('Widget gün programı (Android WidgetSchedule ile sözleşme)', () {
    test('her gün bir satır, altı vakit epoch milisaniye (Sabah..Yatsı)', () {
      final encoded = encodeWidgetSchedule([_day(26), _day(27)]);
      final lines = encoded.split('\n');
      expect(lines, hasLength(2));

      final first = lines.first.split(',').map(int.parse).toList();
      expect(first, hasLength(6));
      expect(first[0], DateTime(2026, 10, 26, 5, 45).millisecondsSinceEpoch);
      expect(first[1], DateTime(2026, 10, 26, 7, 15).millisecondsSinceEpoch);
      expect(first[5], DateTime(2026, 10, 26, 19, 35).millisecondsSinceEpoch);
    });

    test('boş program boş metin üretir', () {
      expect(encodeWidgetSchedule(const []), '');
    });

    test('anlık görüntü programı ve takip gününü widget\'a taşır', () {
      final days = [for (var d = 25; d <= 31; d++) _day(d)];
      final snapshot = buildHomeWidgetSnapshot(
        now: DateTime(2026, 10, 27, 14, 0),
        location: istanbul,
        todayTimes: _day(27),
        upcomingDays: [_day(26), _day(27), _day(28)],
        todayRecords: const {},
        scheduleDays: days,
      );

      expect(snapshot, isNotNull);
      final map = snapshot!.toMap();
      expect(map['doneDate'], '2026-10-27');
      final schedule = map['schedule']! as String;
      expect(schedule.split('\n'), hasLength(7));
    });

    test('program verilmezse yaklaşan günler kullanılır', () {
      final snapshot = buildHomeWidgetSnapshot(
        now: DateTime(2026, 10, 27, 14, 0),
        location: istanbul,
        todayTimes: _day(27),
        upcomingDays: [_day(26), _day(27), _day(28)],
        todayRecords: const {},
      );
      expect((snapshot!.toMap()['schedule']! as String).split('\n'), hasLength(3));
    });

    test('konum yoksa anlık görüntü üretilmez', () {
      final snapshot = buildHomeWidgetSnapshot(
        now: DateTime(2026, 10, 27, 14, 0),
        location: null,
        todayTimes: _day(27),
        upcomingDays: [_day(27)],
        todayRecords: const {},
      );
      expect(snapshot, isNull);
    });
  });
}
