import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

/// Açılışta bozuk bir SQLite veritabanı yedeklenip sıfırlandıysa ana ekranda
/// kullanıcıya uyarı ve yedek dosyanın yolunu gösterir.
class CorruptedDatabaseCard extends ConsumerWidget {
  const CorruptedDatabaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupPath = ref.watch(corruptedDbBackupProvider);
    if (backupPath == null) {
      return const SizedBox.shrink();
    }

    final p = context.palette;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Color.alphaBlend(p.danger.withValues(alpha: 0.15), p.card),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.danger),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.warning, color: p.danger),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    StartupStrings.corruptedDbTitle,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(StartupStrings.corruptedDbMessage(backupPath)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () =>
                          ref.read(corruptedDbBackupProvider.notifier).dismiss(),
                      child: const Text(StartupStrings.acknowledge),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
