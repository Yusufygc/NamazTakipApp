import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/ui/startup_error_app.dart';

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
}
