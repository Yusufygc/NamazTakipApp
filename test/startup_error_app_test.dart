import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/core/theme/app_theme.dart';
import 'package:namaz_takip/providers/providers.dart';
import 'package:namaz_takip/ui/startup_error_app.dart';
import 'package:namaz_takip/ui/widgets/corrupted_database_card.dart';

class _FakeBackend implements NamazBackend {
  _FakeBackend({this.corruptedBackup});

  String? corruptedBackup;
  int dismissCalls = 0;

  @override
  String? get corruptedDatabaseBackup => corruptedBackup;

  @override
  Future<void> dismissCorruptedDatabaseNotice() async {
    dismissCalls++;
    corruptedBackup = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('hata ekranı mesajı, ayrıntıyı ve yeniden dene düğmesini gösterir',
      (tester) async {
    var retried = 0;
    await tester.pumpWidget(StartupErrorApp(
      error: Exception('bozuk veritabanı'),
      onRetry: () => retried++,
    ));

    expect(find.text(StartupStrings.title), findsOneWidget);
    expect(find.text(StartupStrings.message), findsOneWidget);
    expect(find.textContaining('bozuk veritabanı'), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsOneWidget);

    await tester.tap(find.text(CommonStrings.retry));
    expect(retried, 1);
  });

  testWidgets('verileri silen bir eylem sunmaz', (tester) async {
    await tester.pumpWidget(StartupErrorApp(error: 'x', onRetry: () {}));
    // Yalnızca tek düğme: Tekrar dene.
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets(
      'bozuk veritabanı uyarısı yedek yolunu gösterir ve onaylanınca kapanır',
      (tester) async {
    const backup = 'namaz_takip.db.bozuk-20261026-213045';
    final backend = _FakeBackend(corruptedBackup: backup);

    await tester.pumpWidget(ProviderScope(
      overrides: [backendProvider.overrideWithValue(backend)],
      child: MaterialApp(
        theme: buildTheme(kThemes.first.palette),
        home: const Scaffold(body: CorruptedDatabaseCard()),
      ),
    ));

    expect(find.text(StartupStrings.corruptedDbTitle), findsOneWidget);
    expect(find.textContaining(backup), findsOneWidget);
    expect(find.text(StartupStrings.acknowledge), findsOneWidget);

    await tester.tap(find.text(StartupStrings.acknowledge));
    await tester.pumpAndSettle();

    expect(backend.dismissCalls, 1);
    expect(find.text(StartupStrings.corruptedDbTitle), findsNothing);
  });

  testWidgets('bozuk veritabanı yedeği yoksa uyarı görünmez', (tester) async {
    final backend = _FakeBackend();
    await tester.pumpWidget(ProviderScope(
      overrides: [backendProvider.overrideWithValue(backend)],
      child: MaterialApp(
        theme: buildTheme(kThemes.first.palette),
        home: const Scaffold(body: CorruptedDatabaseCard()),
      ),
    ));

    expect(find.text(StartupStrings.corruptedDbTitle), findsNothing);
  });
}
