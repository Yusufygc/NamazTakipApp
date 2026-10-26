import 'package:flutter/material.dart';

import '../core/icons/app_icons.dart';
import '../core/strings/strings.dart';
import '../core/theme/app_theme.dart';

/// Backend kurulurken (veritabanı, ayarlar, bildirim) hata olursa gösterilir.
/// Normal uygulama henüz yoktur, bu yüzden kendi küçük `MaterialApp`'ını taşır.
/// Kullanıcı verisini silen bir eylem sunmaz.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = kThemes.first.palette;
    return MaterialApp(
      title: CommonStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.error, size: 56, color: palette.danger),
                  const SizedBox(height: 16),
                  const Text(
                    StartupStrings.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(StartupStrings.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  SelectableText(
                    StartupStrings.details(error),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: palette.textLight),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(AppIcons.retry),
                    label: const Text(CommonStrings.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
