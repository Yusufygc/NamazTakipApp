import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/core/theme/app_theme.dart';
import 'package:namaz_takip/providers/providers.dart';
import 'package:namaz_takip/ui/widgets/dhikr_editor_sheet.dart';

/// Yalnızca zikir düzenleyicinin kullandığı üyeleri uygulayan sahte backend.
class _FakeBackend implements NamazBackend {
  final analyzed = <String>[];

  @override
  Future<DhikrDraft> analyzeSharedContent(String textOrUrl) async {
    analyzed.add(textOrUrl);
    return DhikrDraft(
      title: 'Taslak',
      arabic: '',
      transliteration: 'Taslak',
      meaning: '',
      targetCount: 33,
      groupName: DhikrGroups.general,
      prayerTime: null,
      sourceUrl: null,
      rawCaption: textOrUrl,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _FakeBackend backend, String shared) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [backendProvider.overrideWithValue(backend)],
    child: MaterialApp(
      theme: buildTheme(kThemes.first.palette),
      home: Scaffold(
        body: DhikrEditorSheet(startWithScraper: true, initialSharedText: shared),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dışarıdan gelen paylaşım onaysız çözümlenmez ve uyarı gösterir',
      (tester) async {
    final backend = _FakeBackend();
    await _pump(tester, backend, 'http://192.168.0.1/admin');

    expect(backend.analyzed, isEmpty);
    expect(find.byKey(const ValueKey('shared-consent-banner')), findsOneWidget);
    expect(find.text(DhikrStrings.sharedConsentBanner), findsOneWidget);
    // Paylaşılan metin kullanıcıya gösterilir; düzenleyebilir veya silebilir.
    expect(find.text('http://192.168.0.1/admin'), findsOneWidget);
  });

  testWidgets('kazı düğmesine basılınca çözümlenir ve uyarı kalkar',
      (tester) async {
    final backend = _FakeBackend();
    await _pump(tester, backend, 'Ya Rezzak 100 defa');

    await tester.tap(find.text(DhikrStrings.analyzeButton));
    await tester.pumpAndSettle();

    expect(backend.analyzed, ['Ya Rezzak 100 defa']);
    expect(find.byKey(const ValueKey('shared-consent-banner')), findsNothing);
    expect(find.text(DhikrStrings.sharedDetectedBanner), findsOneWidget);
  });
}
