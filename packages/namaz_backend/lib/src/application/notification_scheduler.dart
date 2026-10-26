import '../data/prayer_repository.dart';
import '../data/settings_repository.dart';
import '../domain/dates.dart';
import '../domain/notification_gateway.dart';
import '../domain/notification_plan.dart';
import '../domain/prayer.dart';
import '../domain/prayer_time_service.dart';
import '../platform/notification_service.dart';

/// Ayarlar + konum + işaretleme durumundan bildirim planını kurup uygular.
/// Ön planda ve arka plan görevinde aynı kod çalışır.
///
/// [reschedule] **serileştirilir**: biri çalışırken gelen çağrılar tek bir
/// "bir tur daha" isteğine birleşir. Böylece iki işaretleme art arda gelse bile
/// planlar örtüşmez ve son durum en son planla uygulanır (önceki planın,
/// yenisinin iptal ettiği bildirimi geri eklemesi engellenir).
class NotificationScheduler {
  NotificationScheduler({
    required this.settings,
    required this.prayers,
    required this.texts,
    NotificationGateway? notifications,
    this.timeService = const PrayerTimeService(),
  }) : notifications = notifications ?? NotificationService.instance;

  final SettingsRepository settings;
  final PrayerRepository prayers;
  final NotificationTexts texts;
  final NotificationGateway notifications;
  final PrayerTimeService timeService;

  Future<void>? _running;
  bool _again = false;

  /// [now] yalnızca testlerde zamanı sabitlemek içindir.
  Future<void> reschedule({DateTime? now}) {
    final running = _running;
    if (running != null) {
      _again = true; // çalışan tur bittiğinde güncel durumla bir kez daha çalışır
      return running;
    }
    return _running = _drain(now);
  }

  Future<void> _drain(DateTime? now) async {
    try {
      do {
        _again = false;
        await _runOnce(now);
      } while (_again);
    } finally {
      // `await` ile döngü kontrolü arasında boşluk yoktur; yeni çağrı ya
      // `_again`'i işaretler ya da tamamen yeni bir tur başlatır.
      _again = false;
      _running = null;
    }
  }

  Future<void> _runOnce(DateTime? now) async {
    final current = now ?? DateTime.now();

    if (!settings.notificationsEnabled) {
      await notifications.cancelAll();
      return;
    }
    final location = settings.effectiveLocation;
    if (location == null) return;

    final today = dateOnly(current);
    final count = notifications.planningDays;
    final days = [
      for (var i = 0; i < count; i++)
        timeService.compute(location, addDays(today, i), settings.calcMethod),
    ];

    // Dünkü Yatsı sorusu için bir gün geriden başla.
    final records = await prayers.recordsBetween(
        addDays(today, -1), addDays(today, count));
    final done = <String>{
      for (final r in records)
        if (r.status == PrayerStatus.performed ||
            r.status == PrayerStatus.compensated)
          '${dateKey(r.date)}|${r.prayer.key}',
    };

    final plan = buildNotificationPlan(
      now: current,
      days: days,
      isDone: (date, prayer) => done.contains('${dateKey(date)}|${prayer.key}'),
      reminderMinutes: settings.reminderMinutes,
      texts: texts,
    );
    await notifications.apply(plan, texts: texts);
  }
}
