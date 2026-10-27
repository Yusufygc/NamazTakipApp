import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/core/theme/app_theme.dart';
import 'package:namaz_takip/providers/providers.dart';
import 'package:namaz_takip/ui/widgets/qibla_compass_sheet.dart';

/// Yalnızca pusula sayfasının kullandığı üyeleri uygulayan sahte backend.
class _FakeBackend implements NamazBackend {
  _FakeBackend({this.location});

  final AppLocation? location;

  @override
  AppSettings get settings => AppSettings(
        themeKey: 'default',
        notificationsEnabled: true,
        reminderMinutes: 15,
        calcMethod: CalcMethod.diyanet,
        locationMode: LocationMode.auto,
        manualLocation: null,
        location: location,
      );

  // Sensör yok: sayfa elle çevirme ile çalışmalı.
  @override
  Stream<double> get compassHeading => const Stream<double>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _openSheet(WidgetTester tester, _FakeBackend backend) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [backendProvider.overrideWithValue(backend)],
    child: MaterialApp(
      theme: buildTheme(kThemes.first.palette),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showQiblaCompassSheet(context),
            child: const Text('aç'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('aç'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('konum yokken sahte yön ve mesafe gösterilmez', (tester) async {
    await _openSheet(tester, _FakeBackend());

    expect(find.text(HomeStrings.qiblaNoLocation), findsOneWidget);
    // Eski hata: konum yokken İstanbul değerleri (151° ve 2400 km) çıkıyordu.
    expect(find.text(HomeStrings.qiblaDegree(151)), findsNothing);
    expect(find.text(HomeStrings.qiblaDistanceKm(2400)), findsNothing);
    expect(find.text(HomeStrings.qiblaAngleLabel), findsNothing);
    expect(find.text(HomeStrings.qiblaDistanceLabel), findsNothing);
  });

  testWidgets('konum varsa o konumun Kıble açısı ve mesafesi gösterilir',
      (tester) async {
    const istanbul = AppLocation(
      latitude: 41.0082,
      longitude: 28.9784,
      city: 'İstanbul',
    );
    await _openSheet(tester, _FakeBackend(location: istanbul));

    expect(find.text(HomeStrings.qiblaNoLocation), findsNothing);
    // İstanbul: 151,6° ve 2.405 km (kadranın ortasındaki ve alttaki kutu).
    expect(find.text(HomeStrings.qiblaDegree(152)), findsWidgets);
    expect(find.text(HomeStrings.qiblaDistanceKm(2405)), findsOneWidget);
    expect(find.text(HomeStrings.qiblaAngleLabel), findsOneWidget);
  });

  testWidgets('başka şehirde başka açı gösterilir (sabit değer değil)',
      (tester) async {
    const ankara = AppLocation(
      latitude: 39.9334,
      longitude: 32.8597,
      city: 'Ankara',
    );
    await _openSheet(tester, _FakeBackend(location: ankara));

    expect(find.text(HomeStrings.qiblaDegree(160)), findsWidgets);
    expect(find.text(HomeStrings.qiblaDistanceKm(2162)), findsOneWidget);
    expect(find.text(HomeStrings.qiblaDegree(152)), findsNothing);
  });
}
