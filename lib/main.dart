import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import 'core/strings/strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/providers.dart';
import 'ui/app_shell.dart';

/// Arka plan görevinin giriş noktası. Workmanager üst düzey ve işaretli bir
/// fonksiyon ister; metinleri ön yüz verir, işi backend yapar.
@pragma('vm:entry-point')
void namazBackgroundEntryPoint() {
  NamazBackend.handleBackgroundTasks(const AppNotificationTexts());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // İzin pencereleri ilk ekran çizildikten sonra, HomeScreen'de sırayla istenir.
  final backend = await NamazBackend.create(const NamazBackendConfig(
    notificationTexts: AppNotificationTexts(),
    backgroundEntryPoint: namazBackgroundEntryPoint,
  ));

  runApp(ProviderScope(
    overrides: [backendProvider.overrideWithValue(backend)],
    child: const NamazTakipApp(),
  ));
}

class NamazTakipApp extends ConsumerWidget {
  const NamazTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    return MaterialApp(
      title: CommonStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      home: const AppShell(),
    );
  }
}
