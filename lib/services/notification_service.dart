import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/strings/strings.dart';
import 'notification_plan.dart';

/// Arka plan izolatında da kullanılabilen, yalnızca eklenti çağıran ince katman.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'prayer_times';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<PrayerPrompt> _prompts =
      StreamController<PrayerPrompt>.broadcast();

  bool _initialized = false;

  /// Bildirime dokunulduğunda sorulacak vakit.
  Stream<PrayerPrompt> get prompts => _prompts.stream;

  /// Uygulama bildirime dokunularak soğuk başlatıldıysa o vakit.
  PrayerPrompt? launchPrompt;

  /// iOS en fazla 64 bekleyen bildirim tutar; Android'de sınır daha geniştir.
  int get planningDays => Platform.isIOS ? 6 : 10;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('[Notifications] timezone alınamadı: $e');
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final prompt = PrayerPrompt.decode(r.payload);
        if (prompt != null) _prompts.add(prompt);
      },
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      launchPrompt = PrayerPrompt.decode(launch?.notificationResponse?.payload);
    }
    _initialized = true;
  }

  /// Bildirim (ve Android'de tam zamanlı alarm) izinlerini ister.
  Future<bool> requestPermissions() async {
    await init();
    var granted = true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? true;
      if (!(await android.canScheduleExactNotifications() ?? true)) {
        await android.requestExactAlarmsPermission();
      }
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      granted = await ios.requestPermissions(
              alert: true, badge: false, sound: true) ??
          false;
    }
    return granted;
  }

  /// Planı uygular: aynı id'ler üzerine yazılır, plan dışı kalan eski
  /// bekleyen bildirimler iptal edilir.
  Future<void> apply(List<PlannedNotification> plan) async {
    await init();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exactOk = await android?.canScheduleExactNotifications() ?? true;
    final mode = exactOk
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        NotificationStrings.channelName,
        channelDescription: NotificationStrings.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    final wanted = {for (final n in plan) n.id};
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (!wanted.contains(pending.id)) await _plugin.cancel(id: pending.id);
    }

    for (final n in plan) {
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: tz.TZDateTime.from(n.scheduledAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: mode,
        payload: n.payload,
      );
    }
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
