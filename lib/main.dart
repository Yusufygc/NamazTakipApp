import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_theme.dart';
import 'core/date_utils.dart';
import 'data/app_database.dart';
import 'data/settings_repository.dart';
import 'providers/providers.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsRepository(prefs);
  await settings.ensureInstallDate(prayerDay(DateTime.now()));
  final db = await AppDatabase.open();

  // İzin pencereleri ilk ekran çizildikten sonra, HomeScreen'de sırayla istenir.
  await NotificationService.instance.init();

  // Arka plan yenilemesi desteklenmeyen ortamda (ör. masaüstü) uygulamayı durdurmasın.
  try {
    await const BackgroundService().register();
  } catch (e) {
    debugPrint('[Background] kaydedilemedi: $e');
  }

  runApp(ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const NamazTakipApp(),
  ));
}

class NamazTakipApp extends ConsumerWidget {
  const NamazTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    return MaterialApp(
      title: 'Namaz Takip',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      home: const AppShell(),
    );
  }
}
