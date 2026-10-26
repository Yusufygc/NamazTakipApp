import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/application/notification_scheduler.dart';
import 'package:namaz_backend/src/data/app_database.dart';
import 'package:namaz_backend/src/data/prayer_repository.dart';
import 'package:namaz_backend/src/data/settings_repository.dart';
import 'package:namaz_backend/src/domain/notification_gateway.dart';
import 'package:namaz_backend/src/domain/notification_plan.dart';
import 'package:namaz_backend/src/domain/prayer.dart';
import 'package:namaz_backend/src/domain/prayer_time_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/test_texts.dart';

/// Eklenti yerine kullanılan sahte uygulayıcı. Çağrıların örtüşüp
/// örtüşmediğini ve her çağrıda hangi planın geldiğini kaydeder.
class _FakeGateway implements NotificationGateway {
  @override
  int planningDays = 2;

  final List<List<PlannedNotification>> plans = [];
  int cancelAllCalls = 0;
  int overlaps = 0;
  bool _busy = false;

  @override
  Future<void> apply(List<PlannedNotification> plan,
      {required NotificationTexts texts}) async {
    if (_busy) overlaps++;
    _busy = true;
    // Gerçek eklenti çağrıları gibi gerçek bir bekleme.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    plans.add(plan);
    _busy = false;
  }

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 10 Ocak 2026, 04:00: o günün tüm vakitleri ve hatırlatmaları gelecektedir.
  final now = DateTime(2026, 1, 10, 4, 0);
  final day = DateTime(2026, 1, 10);

  late AppDatabase db;
  late PrayerRepository repo;
  late _FakeGateway gateway;

  Future<NotificationScheduler> build({
    bool withLocation = true,
    bool notificationsEnabled = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': notificationsEnabled,
      if (withLocation) ...{
        'location_mode': 'manual',
        'manual_location': jsonEncode({
          'lat': 41.0082,
          'lon': 28.9784,
          'city': 'İstanbul',
          'country': 'Türkiye',
        }),
      },
    });
    final prefs = await SharedPreferences.getInstance();
    return NotificationScheduler(
      settings: SettingsRepository(prefs),
      prayers: repo,
      texts: const TestTexts(),
      notifications: gateway,
    );
  }

  setUp(() async {
    db = await AppDatabase.openInMemory();
    repo = PrayerRepository(db);
    gateway = _FakeGateway();
  });
  tearDown(() => db.close());

  int dhuhrReminder() => notificationId(day, PrayerType.dhuhr, reminder: true);

  test('konum yoksa hiçbir şey planlanmaz', () async {
    final scheduler = await build(withLocation: false);
    await scheduler.reschedule(now: now);
    expect(gateway.plans, isEmpty);
    expect(gateway.cancelAllCalls, 0);
  });

  test('bildirimler kapalıysa hepsi iptal edilir, plan kurulmaz', () async {
    final scheduler = await build(notificationsEnabled: false);
    await scheduler.reschedule(now: now);
    expect(gateway.cancelAllCalls, 1);
    expect(gateway.plans, isEmpty);
  });

  test('tek çağrı bir plan uygular ve hatırlatmayı içerir', () async {
    final scheduler = await build();
    await scheduler.reschedule(now: now);
    expect(gateway.plans.length, 1);
    expect(gateway.plans.single.any((n) => n.id == dhuhrReminder()), isTrue);
  });

  test('eşzamanlı çağrılar örtüşmez ve son durum son planla uygulanır', () async {
    final scheduler = await build();

    // A başlar; çalışırken Öğle işaretlenir ve B istenir.
    final a = scheduler.reschedule(now: now);
    await repo.markPerformed(day, PrayerType.dhuhr);
    final b = scheduler.reschedule(now: now);
    await Future.wait([a, b]);

    expect(gateway.overlaps, 0, reason: 'iki apply aynı anda çalışmamalı');
    expect(gateway.plans.length, inInclusiveRange(1, 2));
    // İşaretlenen Öğle'nin hatırlatması, eski planın geri eklemesiyle değil,
    // son planla belirlenir: son planda yoktur.
    expect(gateway.plans.last.any((n) => n.id == dhuhrReminder()), isFalse);
  });

  test('çok sayıda hızlı çağrı en fazla iki tura birleşir', () async {
    final scheduler = await build();
    final calls = [for (var i = 0; i < 10; i++) scheduler.reschedule(now: now)];
    await Future.wait(calls);
    expect(gateway.overlaps, 0);
    expect(gateway.plans.length, lessThanOrEqualTo(2));
  });

  test('tur bittikten sonra yeni çağrı yeni bir tur başlatır', () async {
    final scheduler = await build();
    await scheduler.reschedule(now: now);
    await scheduler.reschedule(now: now);
    expect(gateway.plans.length, 2);
  });

  test('hata sonrası kuyruk kilitlenmez', () async {
    final scheduler = await build();
    final failing = _ThrowingGateway();
    final broken = NotificationScheduler(
      settings: scheduler.settings,
      prayers: repo,
      texts: const TestTexts(),
      notifications: failing,
    );
    await expectLater(broken.reschedule(now: now), throwsA(isA<StateError>()));
    failing.shouldThrow = false;
    await broken.reschedule(now: now); // ikinci çağrı yeniden çalışabilmeli
    expect(failing.applied, 1);
  });

  test('plan uygulanırken geçmişe düşen bildirim atlanır ve kalanlar planlanır',
      () async {
    final baseScheduler = await build();
    final istanbul = baseScheduler.settings.effectiveLocation!;
    final fajr = const PrayerTimeService()
        .compute(istanbul, day, CalcMethod.diyanet)
        .fajr;

    // Plan kurulurken Sabah vaktine 1 sn vardır (Sabah plana girer);
    // uygulama anına gelindiğinde saat Sabah'ı 1 sn geçmiştir.
    var clockCalls = 0;
    DateTime fakeClock() {
      clockCalls++;
      return clockCalls == 1
          ? fajr.subtract(const Duration(seconds: 1))
          : fajr.add(const Duration(seconds: 1));
    }

    final strictGateway = _StrictFutureGateway(
      currentTime: () => fajr.add(const Duration(seconds: 1)),
    );
    final scheduler = NotificationScheduler(
      settings: baseScheduler.settings,
      prayers: repo,
      texts: const TestTexts(),
      notifications: strictGateway,
      clock: fakeClock,
    );

    await scheduler.reschedule();

    final fajrAdhanId = notificationId(day, PrayerType.fajr, reminder: false);
    final fajrReminderId = notificationId(day, PrayerType.fajr, reminder: true);
    expect(strictGateway.scheduled.any((n) => n.id == fajrAdhanId), isFalse,
        reason: 'geçmişe düşen Sabah ezanı atlanmalı');
    expect(strictGateway.scheduled.any((n) => n.id == fajrReminderId), isTrue,
        reason: 'gelecekteki Sabah hatırlatması planlanmalı');
    expect(strictGateway.scheduled.any((n) => n.id == dhuhrReminder()), isTrue,
        reason: 'kalan bildirimler planlanmaya devam etmeli');
    expect(strictGateway.scheduled.length, 19);
  });

  test(
      'uygulama sırasında geçmiş zaman hatası fırlatan tek bildirim kalan planı durdurmaz',
      () async {
    final baseScheduler = await build();
    final istanbul = baseScheduler.settings.effectiveLocation!;
    final fajr = const PrayerTimeService()
        .compute(istanbul, day, CalcMethod.diyanet)
        .fajr;

    // Plan kurulurken ve apply başlarken Sabah gelecektedir; ancak eklenti ilk
    // öğeyi zamanlarken saat Sabah'ı geçer ve zonedSchedule gibi ArgumentError atar.
    var currentClock = fajr.subtract(const Duration(seconds: 1));
    final gateway = _StrictFutureGateway(
      currentTime: () => currentClock,
      onBeforeApply: () {
        currentClock = fajr.add(const Duration(seconds: 1));
      },
    );
    final scheduler = NotificationScheduler(
      settings: baseScheduler.settings,
      prayers: repo,
      texts: const TestTexts(),
      notifications: gateway,
      clock: () => currentClock,
    );

    await scheduler.reschedule();

    final fajrAdhanId = notificationId(day, PrayerType.fajr, reminder: false);
    expect(gateway.scheduled.any((n) => n.id == fajrAdhanId), isFalse);
    expect(gateway.scheduled.any((n) => n.id == dhuhrReminder()), isTrue);
    expect(gateway.scheduled.length, 19);
  });
}

class _StrictFutureGateway implements NotificationGateway {
  _StrictFutureGateway({required this.currentTime, this.onBeforeApply});

  final DateTime Function() currentTime;
  final void Function()? onBeforeApply;
  final List<PlannedNotification> scheduled = [];

  @override
  int get planningDays => 2;

  @override
  Future<void> apply(List<PlannedNotification> plan,
      {required NotificationTexts texts}) async {
    onBeforeApply?.call();
    scheduled.clear();
    final now = currentTime();
    for (final n in plan) {
      if (!n.scheduledAt.isAfter(now)) {
        throw ArgumentError.value(
          n.scheduledAt,
          'scheduledDate',
          'Must be a date in the future',
        );
      }
      scheduled.add(n);
    }
  }

  @override
  Future<void> cancelAll() async => scheduled.clear();
}

class _ThrowingGateway implements NotificationGateway {
  bool shouldThrow = true;
  int applied = 0;

  @override
  int get planningDays => 1;

  @override
  Future<void> apply(List<PlannedNotification> plan,
      {required NotificationTexts texts}) async {
    if (shouldThrow) throw StateError('eklenti hatası');
    applied++;
  }

  @override
  Future<void> cancelAll() async {}
}
