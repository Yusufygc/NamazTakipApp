import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import 'core/content/dhikr_catalog.dart';
import 'core/strings/strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/providers.dart';
import 'ui/app_shell.dart';
import 'ui/startup_error_app.dart';

/// Arka plan görevinin giriş noktası. Workmanager üst düzey ve işaretli bir
/// fonksiyon ister; metinleri ön yüz verir, işi backend yapar.
@pragma('vm:entry-point')
void namazBackgroundEntryPoint() {
  NamazBackend.handleBackgroundTasks(const AppNotificationTexts());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHooks();
  await _start();
}

/// Backend'i kurar ve uygulamayı açar. Kurulum hata verirse boş ekran yerine
/// hata ekranı gösterilir; "Tekrar dene" bu fonksiyonu yeniden çalıştırır.
Future<void> _start() async {
  final NamazBackend backend;
  try {
    // İzin pencereleri ilk ekran çizildikten sonra, HomeScreen'de sırayla istenir.
    backend = await NamazBackend.create(
      const NamazBackendConfig(
        notificationTexts: AppNotificationTexts(),
        homeWidgetTexts: AppHomeWidgetTexts(),
        dhikrContent: kAppDhikrContent,
        backgroundEntryPoint: namazBackgroundEntryPoint,
      ),
    );
  } catch (error, stack) {
    debugPrint('[Startup] başlatılamadı: $error\n$stack');
    runApp(StartupErrorApp(error: error, onRetry: _start));
    return;
  }

  runApp(
    ProviderScope(
      overrides: [backendProvider.overrideWithValue(backend)],
      child: const NamazTakipApp(),
    ),
  );
}

/// Yakalanmayan hatalar sessiz kalmasın. Yapısal günlükleme ayrı bir iştir;
/// şimdilik hatalar `debugPrint` ile yazılır.
void _installErrorHooks() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    debugPrint('[Flutter] ${details.exceptionAsString()}');
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[Yakalanmayan] $error\n$stack');
    return true;
  };
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
