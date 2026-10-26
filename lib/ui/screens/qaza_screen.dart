import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/date_utils.dart';
import '../../data/prayer_repository.dart';
import '../../providers/providers.dart';

class QazaScreen extends ConsumerWidget {
  const QazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final async = ref.watch(qazaProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  const Text('Kaza namazınız yok',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Allah kabul etsin.', style: TextStyle(color: p.textLight)),
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
                'Toplam ${items.length} kaza namazı • ${days.length} gün',
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
          title: Text(formatDateTr(date),
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
                child: Text('${items.length} Kaza',
                    style: TextStyle(
                        color: p.danger, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
          children: [
            for (final item in items)
              ListTile(
                dense: true,
                leading: Icon(Icons.cancel, color: p.danger),
                title: Text(item.prayer.trName),
                subtitle: Text(item.isAutoDetected ? 'Otomatik tespit' : 'Kılınmadı olarak işaretlendi'),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: p.dark),
                  onPressed: () => _confirm(context, ref, item),
                  child: const Text('Kaza Et'),
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
        title: const Text('Kaza Namazı'),
        content: Text(
            '${formatDateTr(item.date)} tarihli ${item.prayer.trName} namazını kaza ettiniz mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet, Kıldım')),
        ],
      ),
    );
    if (ok == true) await ref.read(qazaProvider.notifier).compensate(item);
  }
}
