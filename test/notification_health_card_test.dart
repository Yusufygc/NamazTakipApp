import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/core/theme/app_theme.dart';
import 'package:namaz_takip/providers/providers.dart';
import 'package:namaz_takip/ui/widgets/notification_health_card.dart';

/// Yalnızca kartın kullandığı üyeleri uygulayan sahte backend; gerisi
/// `noSuchMethod` ile çağrılırsa test düşer.
class _FakeBackend implements NamazBackend {
  _FakeBackend({required this.exactAllowed, this.notificationsEnabled = true});

  bool exactAllowed;
  bool notificationsEnabled;
  int openCalls = 0;
  int rescheduleCalls = 0;

  @override
  AppSettings get settings => AppSettings(
        themeKey: 'default',
        notificationsEnabled: notificationsEnabled,
        reminderMinutes: 15,
        calcMethod: CalcMethod.diyanet,
        locationMode: LocationMode.auto,
        manualLocation: null,
        location: null,
      );

  @override
  Future<NotificationHealth> notificationHealth() async =>
      NotificationHealth(exactAlarmsAllowed: exactAllowed);

  @override
  Future<void> openExactAlarmSettings() async => openCalls++;

  @override
  Future<void> rescheduleNotifications() async => rescheduleCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pump(WidgetTester tester, _FakeBackend backend) async {
  final container = ProviderContainer(
    overrides: [backendProvider.overrideWithValue(backend)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildTheme(kThemes.first.palette),
      home: const Scaffold(body: NotificationHealthCard()),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('izin yokken ve bildirimler açıkken uyarı görünür', (tester) async {
    await _pump(tester, _FakeBackend(exactAllowed: false));
    expect(find.text(NotificationHealthStrings.exactAlarmTitle), findsOneWidget);
    expect(find.text(NotificationHealthStrings.openSettings), findsOneWidget);
  });

  testWidgets('izin varsa uyarı görünmez', (tester) async {
    await _pump(tester, _FakeBackend(exactAllowed: true));
    expect(find.text(NotificationHealthStrings.exactAlarmTitle), findsNothing);
  });

  testWidgets('bildirimler kapalıysa uyarı görünmez', (tester) async {
    await _pump(
        tester, _FakeBackend(exactAllowed: false, notificationsEnabled: false));
    expect(find.text(NotificationHealthStrings.exactAlarmTitle), findsNothing);
  });

  testWidgets('düğme sistem ayar ekranını açar', (tester) async {
    final backend = _FakeBackend(exactAllowed: false);
    await _pump(tester, backend);
    await tester.tap(find.text(NotificationHealthStrings.openSettings));
    await tester.pumpAndSettle();
    expect(backend.openCalls, 1);
  });

  testWidgets('izin sonradan verilince uyarı kalkar ve bir kez yeniden planlanır',
      (tester) async {
    final backend = _FakeBackend(exactAllowed: false);
    final container = await _pump(tester, backend);
    expect(find.text(NotificationHealthStrings.exactAlarmTitle), findsOneWidget);
    expect(backend.rescheduleCalls, 0);

    backend.exactAllowed = true; // kullanıcı ayarlardan izni açtı
    container.invalidate(notificationHealthProvider);
    await tester.pumpAndSettle();

    expect(find.text(NotificationHealthStrings.exactAlarmTitle), findsNothing);
    expect(backend.rescheduleCalls, 1);
  });

  testWidgets('izin hiç değişmezse yeniden planlama tetiklenmez', (tester) async {
    final backend = _FakeBackend(exactAllowed: true);
    final container = await _pump(tester, backend);
    container.invalidate(notificationHealthProvider);
    await tester.pumpAndSettle();
    expect(backend.rescheduleCalls, 0);
  });
}
