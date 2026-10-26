import '../core/date_utils.dart';
import '../core/prayer.dart';

/// Planlanan tek bir bildirim; platformdan bağımsız, saf veri.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.scheduledAt,
    required this.title,
    required this.body,
    this.payload,
  });

  final int id;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String? payload;
}

/// Bildirime dokunulunca uygulamanın soracağı vakit.
class PrayerPrompt {
  const PrayerPrompt(this.date, this.prayer);

  final DateTime date;
  final PrayerType prayer;

  String encode() => 'ask|${dateKey(date)}|${prayer.key}';

  static PrayerPrompt? decode(String? payload) {
    if (payload == null) return null;
    final p = payload.split('|');
    if (p.length != 3 || p[0] != 'ask') return null;
    try {
      return PrayerPrompt(parseDateKey(p[1]), PrayerType.fromKey(p[2]));
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerPrompt && other.date == date && other.prayer == prayer;

  @override
  int get hashCode => Object.hash(date, prayer);
}

/// Aynı vakit için her zaman aynı id üretilir; yeniden planlama çift
/// bildirim oluşturmaz, üzerine yazar. `yyyymmdd * 10 + vakit*2 + tür`.
int notificationId(DateTime date, PrayerType prayer, {required bool reminder}) {
  final ymd = date.year * 10000 + date.month * 100 + date.day;
  return ymd * 10 + prayer.index * 2 + (reminder ? 1 : 0);
}

/// [days] ardışık takvim günleri (artan). [isDone] bir vaktin kılındığını
/// (veya kaza edildiğini) söyler; kılınmış vakit için soru/hatırlatma üretilmez.
List<PlannedNotification> buildNotificationPlan({
  required DateTime now,
  required List<DayTimes> days,
  required bool Function(DateTime date, PrayerType prayer) isDone,
  required int reminderMinutes,
}) {
  final plan = <PlannedNotification>[];
  for (final day in days) {
    for (final type in PrayerType.values) {
      final adhanAt = day.timeOf(type);

      // Ezan bildirimi önceki vaktin kılınıp kılınmadığını sorar.
      // Sabah ezanında sorulan, dünkü Yatsı'dır.
      if (adhanAt.isAfter(now)) {
        final askType = type.previous ?? PrayerType.isha;
        final askDate = type.previous == null ? addDays(day.date, -1) : day.date;
        final answered = isDone(askDate, askType);
        plan.add(PlannedNotification(
          id: notificationId(day.date, type, reminder: false),
          scheduledAt: adhanAt,
          title: '${type.trName} Vakti 🕌',
          body: answered
              ? '${type.trName} vakti girdi.'
              : 'Selamünaleyküm! ${type.trName} ezanı okundu. '
                  '${askType.trName} namazını kıldın mı?',
          payload: answered ? null : PrayerPrompt(askDate, askType).encode(),
        ));
      }

      // Hatırlatma: ezandan sonra, hâlâ işaretlenmemişse.
      final remindAt = adhanAt.add(Duration(minutes: reminderMinutes));
      if (remindAt.isAfter(now) && !isDone(day.date, type)) {
        plan.add(PlannedNotification(
          id: notificationId(day.date, type, reminder: true),
          scheduledAt: remindAt,
          title: '${type.trName} Namazını Kıldınız mı?',
          body: 'Namazınızı işaretlemek için dokunun.',
          payload: PrayerPrompt(day.date, type).encode(),
        ));
      }
    }
  }
  return plan;
}
