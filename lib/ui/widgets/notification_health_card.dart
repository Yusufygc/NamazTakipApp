import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

/// Tam zamanlı alarm izni kapalıyken ana ekranda kalıcı uyarı gösterir.
/// İzin sonradan verilirse mevcut (yaklaşık zamanlı) alarmlar yeniden planlanır.
class NotificationHealthCard extends ConsumerWidget {
  const NotificationHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // İzin verilince alarmlar hâlâ yaklaşık zamanlıdır; tam zamanlıya çevirmek
    // için yalnızca "yok → var" geçişinde bir kez yeniden planla.
    ref.listen<AsyncValue<NotificationHealth>>(notificationHealthProvider,
        (previous, next) {
      final was = previous?.value?.exactAlarmsAllowed;
      final now = next.value?.exactAlarmsAllowed;
      if (was == false && now == true) {
        ref.read(backendProvider).rescheduleNotifications();
      }
    });

    final enabled =
        ref.watch(settingsProvider.select((s) => s.notificationsEnabled));
    final health = ref.watch(notificationHealthProvider).value;
    if (!enabled || health == null || health.isHealthy) {
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
                    NotificationHealthStrings.exactAlarmTitle,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(NotificationHealthStrings.exactAlarmMessage),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        await ref.read(backendProvider).openExactAlarmSettings();
                        ref.invalidate(notificationHealthProvider);
                      },
                      child: const Text(NotificationHealthStrings.openSettings),
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
