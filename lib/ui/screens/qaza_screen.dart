import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

class QazaScreen extends ConsumerWidget {
  const QazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final async = ref.watch(qazaProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(CommonStrings.error(e))),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.qazaEmpty, size: 64, color: p.primary),
                  const SizedBox(height: 12),
                  const Text(QazaStrings.emptyTitle,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(QazaStrings.emptySubtitle, style: TextStyle(color: p.textLight)),
                ],
              ),
            ),
          );
        }

        final byDay = <DateTime, List<QazaItem>>{};
        for (final i in items) {
          byDay.putIfAbsent(i.date, () => []).add(i);
        }
        final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
              child: Text(
                QazaStrings.summary(items.length, days.length),
                style: TextStyle(color: p.textLight, fontWeight: FontWeight.w600),
              ),
            ),
            for (final d in days) _DayCard(date: d, items: byDay[d]!),
          ],
        );
      },
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.date, required this.items});

  final DateTime date;
  final List<QazaItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Card(
      color: p.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(DateStrings.long(date),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(QazaStrings.badge(items.length),
                    style: TextStyle(
                        color: p.danger, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Icon(AppIcons.expand),
            ],
          ),
          children: [
            for (final item in items)
              ListTile(
                dense: true,
                leading: Icon(AppIcons.qazaItem, color: p.danger),
                title: Text(item.prayer.label),
                subtitle: Text(item.isAutoDetected
                    ? QazaStrings.autoDetected
                    : QazaStrings.markedMissed),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: p.dark),
                  onPressed: () => _confirm(context, ref, item),
                  child: const Text(QazaStrings.compensate),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, QazaItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(QazaStrings.confirmTitle),
        content: Text(QazaStrings.confirmBody(
            DateStrings.long(item.date), item.prayer.label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(CommonStrings.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text(QazaStrings.confirmYes)),
        ],
      ),
    );
    if (ok == true) await ref.read(qazaProvider.notifier).compensate(item);
  }
}
