import 'package:intl/intl.dart';

import 'prayer.dart';

/// Gece yarısından sonra bu saate kadar "dünün" namazları geçerlidir.
const int kLateNightCutoffHour = 4;

final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
final DateFormat _timeFormat = DateFormat('HH:mm');

/// Saat bilgisini atar.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Veritabanı anahtarı: `2026-01-25`. Metin sıralaması tarih sıralamasıyla aynıdır.
String dateKey(DateTime d) => _keyFormat.format(d);

DateTime parseDateKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String formatTime(DateTime d) => _timeFormat.format(d);

/// Gün ekler; yaz/kış saati geçişinde bile takvim gününü korur.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// İki takvim günü arasındaki gün farkı (yaz/kış saatinden etkilenmez).
int daysDiff(DateTime a, DateTime b) =>
    DateTime.utc(a.year, a.month, a.day).difference(DateTime.utc(b.year, b.month, b.day)).inDays;

/// Takip açısından "bugün". 00:00–03:59 arası hâlâ dünkü gündür.
DateTime prayerDay(DateTime now) {
  final today = dateOnly(now);
  return now.hour < kLateNightCutoffHour ? addDays(today, -1) : today;
}

/// [from] ile [to] arasındaki (ikisi dahil) takvim günleri.
Iterable<DateTime> daysBetween(DateTime from, DateTime to) sync* {
  var d = dateOnly(from);
  final end = dateOnly(to);
  while (!d.isAfter(end)) {
    yield d;
    d = addDays(d, 1);
  }
}

/// [now] anından sonraki ilk farz vakit. [days] sırasıyla bugün ve yarının
/// vakitlerini içermelidir; sayfa yenilenmeden Yatsı→Sabah geçişini çözer.
NextPrayer? nextPrayer(DateTime now, List<DayTimes> days) {
  NextPrayer? best;
  for (final day in days) {
    for (final type in PrayerType.values) {
      final t = day.timeOf(type);
      if (t.isAfter(now) && (best == null || t.isBefore(best.time))) {
        best = NextPrayer(type, t);
      }
    }
  }
  return best;
}

const List<String> kMonthNamesTr = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// `25 Ocak 2026`
String formatDateTr(DateTime d) => '${d.day} ${kMonthNamesTr[d.month - 1]} ${d.year}';
