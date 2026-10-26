import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// `NotificationService.apply` bildirimleri `tz.TZDateTime.from(zaman, tz.local)`
/// ile planlar. Saat dilimi bulunamazsa `tz.local` UTC kalır; bu testler,
/// tek seferlik bildirimlerin yine de **aynı ana** karşılık geldiğini, yani
/// zamanlamanın `tz.local`'e bağlı olmadığını kanıtlar. Bu varsayım bozulursa
/// (örn. eklenti veya paket değişirse) test düşer.
void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('TZDateTime.from, hedef bölgeden bağımsız olarak aynı anı korur', () {
    // Cihaz yerel saati: 10 Ocak 2026 05:55 (UTC+3 ise 02:55 UTC).
    final local = DateTime(2026, 1, 10, 5, 55);
    final utc = tz.TZDateTime.from(local, tz.UTC);
    final istanbul = tz.TZDateTime.from(local, tz.getLocation('Europe/Istanbul'));
    final tokyo = tz.TZDateTime.from(local, tz.getLocation('Asia/Tokyo'));

    expect(utc.millisecondsSinceEpoch, local.millisecondsSinceEpoch);
    expect(istanbul.millisecondsSinceEpoch, local.millisecondsSinceEpoch);
    expect(tokyo.millisecondsSinceEpoch, local.millisecondsSinceEpoch);
  });

  test('farklı bölgelerdeki duvar saati farklıdır ama an aynıdır', () {
    final instant = DateTime.utc(2026, 1, 10, 2, 55);
    final utc = tz.TZDateTime.from(instant, tz.UTC);
    final istanbul = tz.TZDateTime.from(instant, tz.getLocation('Europe/Istanbul'));

    expect(utc.hour, 2);
    expect(istanbul.hour, 5);
    expect(utc.isAtSameMomentAs(istanbul), isTrue);
  });
}
