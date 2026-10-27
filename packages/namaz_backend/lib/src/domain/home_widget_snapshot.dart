import 'dates.dart';
import 'islamic_calendar.dart';
import 'models.dart';
import 'prayer.dart';
import 'prayer_time_service.dart';

/// Widget'ta gösterilen metinler: ön yüz verir (metin ve dil kararı ön yüzdedir).
abstract interface class HomeWidgetTexts {
  /// Vakit adı (Sabah..Yatsı).
  String prayerLabel(PrayerType prayer);

  /// Güneş doğuşu satırının adı.
  String get sunriseLabel;

  /// "Sıradaki vakit" etiketi.
  String get nextTag;

  /// Başlık; şehir yerine [kWidgetCityToken] verilerek şablon alınır.
  String header(String city);

  /// "n / 5 Eda" rozeti; 0..5 için ayrı ayrı istenir.
  String doneBadge(int done);
}

/// [HomeWidgetTexts.header] şablonunda şehrin yerine konan işaret.
const String kWidgetCityToken = '{city}';

/// Telefon ana ekran widget'ında (Android AppWidget / iOS WidgetKit)
/// gösterilecek güncel vakit ve takip verisi özeti.
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.city,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.completedCount,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
    required this.performedMask,
    this.scheduleDays = const [],
    this.doneDate = '',
  });

  final String city;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final PrayerType nextPrayer;
  final String nextPrayerTime;
  final int completedCount;
  final String fajrTime;
  final String sunriseTime;
  final String dhuhrTime;
  final String asrTime;
  final String maghribTime;
  final String ishaTime;

  /// Kılınan vakitlerin bit maskesi (bit 0: Sabah .. bit 4: Yatsı).
  final int performedMask;

  /// Dünden itibaren birkaç günün vakitleri. Widget bunu kendi başına kullanır:
  /// uygulama açılmasa da "sıradaki vakit" ve günün saatleri doğru kalır.
  final List<DayTimes> scheduleDays;

  /// [completedCount]'un ait olduğu takip günü (`yyyy-MM-dd`).
  final String doneDate;

  bool isPerformed(PrayerType prayer) =>
      (performedMask & (1 << prayer.index)) != 0;

  Map<String, Object?> toMap(HomeWidgetTexts texts) => {
    'city': city,
    'hijriDay': hijriDay,
    'hijriMonth': hijriMonth,
    'hijriYear': hijriYear,
    'nextPrayerKey': nextPrayer.key,
    'nextPrayerLabel': texts.prayerLabel(nextPrayer),
    // Android widget'ı bu metinleri saklar ve kendi hesabına göre seçer.
    'prayerLabels': [for (final p in PrayerType.values) texts.prayerLabel(p)]
        .join('\n'),
    'sunriseLabel': texts.sunriseLabel,
    'nextTag': texts.nextTag,
    'headerTemplate': texts.header(kWidgetCityToken),
    'doneBadges': [for (var i = 0; i <= 5; i++) texts.doneBadge(i)].join('\n'),
    'nextPrayerTime': nextPrayerTime,
    'completedCount': completedCount,
    'fajrTime': fajrTime,
    'sunriseTime': sunriseTime,
    'dhuhrTime': dhuhrTime,
    'asrTime': asrTime,
    'maghribTime': maghribTime,
    'ishaTime': ishaTime,
    'performedMask': performedMask,
    'doneDate': doneDate,
    'schedule': encodeWidgetSchedule(scheduleDays),
  };
}

/// Widget için gün programı: her satır bir gün, `Sabah,Güneş,Öğle,İkindi,Akşam,
/// Yatsı` vakitlerinin epoch milisaniyesi (virgülle ayrılmış).
String encodeWidgetSchedule(List<DayTimes> days) => days
    .map(
      (d) => [
        d.fajr,
        d.sunrise,
        d.dhuhr,
        d.asr,
        d.maghrib,
        d.isha,
      ].map((t) => t.millisecondsSinceEpoch).join(','),
    )
    .join('\n');

String _fmtHm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Mevcut konum, günün vakitleri ve kılınma kayıtlarından widget özetini üretir.
HomeWidgetSnapshot? buildHomeWidgetSnapshot({
  required DateTime now,
  required AppLocation? location,
  required DayTimes? todayTimes,
  required List<DayTimes> upcomingDays,
  required Map<PrayerType, PrayerRecord> todayRecords,
  List<DayTimes>? scheduleDays,
}) {
  if (location == null || todayTimes == null || upcomingDays.isEmpty) {
    return null;
  }
  final next = nextPrayer(now, upcomingDays);
  if (next == null) return null;

  final hijri = HijriDate.fromGregorian(todayTimes.date);
  var mask = 0;
  var done = 0;
  for (final p in PrayerType.values) {
    final status = todayRecords[p]?.status;
    if (status == PrayerStatus.performed ||
        status == PrayerStatus.compensated) {
      mask |= (1 << p.index);
      done++;
    }
  }

  return HomeWidgetSnapshot(
    city: location.city,
    hijriDay: hijri.day,
    hijriMonth: hijri.month,
    hijriYear: hijri.year,
    nextPrayer: next.type,
    nextPrayerTime: _fmtHm(next.time),
    completedCount: done,
    fajrTime: _fmtHm(todayTimes.fajr),
    sunriseTime: _fmtHm(todayTimes.sunrise),
    dhuhrTime: _fmtHm(todayTimes.dhuhr),
    asrTime: _fmtHm(todayTimes.asr),
    maghribTime: _fmtHm(todayTimes.maghrib),
    ishaTime: _fmtHm(todayTimes.isha),
    performedMask: mask,
    scheduleDays: scheduleDays ?? upcomingDays,
    doneDate: dateKey(todayTimes.date),
  );
}
