import 'prayer.dart';

/// Gece yarısından sonra bu saate kadar (Sabah vakti bu saatten önce girmediyse)
/// "dünün" namazları geçerlidir.
const int kLateNightCutoffHour = 4;

/// Saat bilgisini atar.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _two(int n) => n.toString().padLeft(2, '0');

/// Veritabanı anahtarı: `2026-01-25`. Metin sıralaması tarih sıralamasıyla aynıdır.
String dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

DateTime parseDateKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// Gün ekler; yaz/kış saati geçişinde bile takvim gününü korur.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// İki takvim günü arasındaki gün farkı (yaz/kış saatinden etkilenmez).
int daysDiff(DateTime a, DateTime b) => DateTime.utc(a.year, a.month, a.day)
    .difference(DateTime.utc(b.year, b.month, b.day))
    .inDays;

/// Takip açısından "bugün". Gün sınırı `min(04:00, bugünkü Sabah vakti)`'dir:
/// sınırdan önce hâlâ dünkü gündür.
///
/// Sabah vakti 04:00'ten önce girdiğinde (örn. yazın İstanbul'da 03:24) gün o
/// anda değişir; böylece Sabah namazı doğru güne yazılır. [fajrToday] verilmezse
/// (konum yok) yalnızca 04:00 kuralı uygulanır.
DateTime prayerDay(DateTime now, {DateTime? fajrToday}) {
  final today = dateOnly(now);
  var boundary = DateTime(now.year, now.month, now.day, kLateNightCutoffHour);
  if (fajrToday != null && fajrToday.isBefore(boundary)) boundary = fajrToday;
  return now.isBefore(boundary) ? addDays(today, -1) : today;
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
