import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/qaza_debt_sheet.dart';

class QazaScreen extends ConsumerWidget {
  const QazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final async = ref.watch(qazaProvider);
    final debtPlan = ref.watch(qazaDebtProvider);
    final today = ref.watch(trackingDayProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(CommonStrings.error(e))),
      data: (items) {
        final grandTotal = debtPlan.grandTotal(items.length);
        if (grandTotal == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeljukMedallion(
                    size: 84,
                    fillColor: p.primary.withValues(alpha: 0.12),
                    borderColor: p.secondary,
                    child: Icon(
                      AppIcons.qazaEmpty,
                      size: 38,
                      color: p.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    QazaStrings.emptyTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    QazaStrings.emptySubtitle,
                    style: TextStyle(fontSize: 15, color: p.textLight),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => showQazaDebtSheet(context),
                    icon: const Icon(AppIcons.navQazaSelected, size: 18),
                    label: const Text(QazaStrings.debtPlannerButton),
                  ),
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

        final estDays = debtPlan.estimatedDaysToFinish(items.length);
        final finishDate =
            debtPlan.estimatedCompletionDate(items.length, today);

        final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
        final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Üst Mihrap Özet Kartı
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.secondary.withValues(alpha: 0.45),
                ),
              ),
              child: MihrabArchBackdrop(
                borderRadius: 22,
                lineColor: Colors.white.withValues(alpha: 0.08),
                accentColor: p.secondary.withValues(alpha: 0.16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        QazaStrings.overviewTitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricPill(
                              value: '$grandTotal',
                              label: QazaStrings.totalPrayersLabel,
                              accent: p.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricPill(
                              value: '${debtPlan.dailyTarget}',
                              label: QazaStrings.dailyTargetLabel,
                              accent: p.secondary,
                            ),
                          ),
                        ],
                      ),
                      if (finishDate != null && estDays != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          QazaStrings.estimatedFinish(
                            DateStrings.long(finishDate),
                            estDays,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.10),
                            side: BorderSide(
                              color: p.secondary.withValues(alpha: 0.55),
                            ),
                          ),
                          onPressed: () => showQazaDebtSheet(context),
                          icon: Icon(
                            AppIcons.edit,
                            size: 16,
                            color: p.secondary,
                          ),
                          label: const Text(
                            QazaStrings.debtPlannerButton,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (debtPlan.totalBacklog > 0) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  QazaStrings.backlogSectionTitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: p.textLight,
                  ),
                ),
              ),
              _BacklogCard(plan: debtPlan),
            ],
            if (days.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  QazaStrings.trackedSectionTitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: p.textLight,
                  ),
                ),
              ),
              for (var i = 0; i < days.length; i++)
                _DayCard(
                  date: days[i],
                  items: byDay[days[i]]!,
                  initiallyExpanded: i == 0,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _BacklogCard extends ConsumerWidget {
  const _BacklogCard({required this.plan});

  final QazaDebtPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Card(
      color: p.card,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (final prayer in PrayerType.values)
            if (plan.countFor(prayer) > 0)
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.prayerIcon(prayer),
                    size: 18,
                    color: p.primary,
                  ),
                ),
                title: Text(
                  prayer.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  QazaStrings.remainingPrayerCount(plan.countFor(prayer)),
                  style: TextStyle(fontSize: 12.5, color: p.textLight),
                ),
                trailing: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () =>
                      ref.read(qazaDebtProvider.notifier).decrementPrayer(prayer),
                  icon: const Icon(AppIcons.confirmPerformed, size: 15),
                  label: const Text(
                    QazaStrings.decrementBacklogButton,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({
    required this.date,
    required this.items,
    this.initiallyExpanded = false,
  });

  final DateTime date;
  final List<QazaItem> items;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Card(
      color: p.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppIcons.calendar, size: 18, color: p.danger),
          ),
          title: Text(
            DateStrings.long(date),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.danger.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  QazaStrings.badge(items.length),
                  style: TextStyle(
                    color: p.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(AppIcons.expand),
            ],
          ),
          children: [
            Divider(height: 1, color: p.primary.withValues(alpha: 0.10)),
            for (final item in items)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.prayerIcon(item.prayer),
                    size: 18,
                    color: p.primary,
                  ),
                ),
                title: Text(
                  item.prayer.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  item.isAutoDetected
                      ? QazaStrings.autoDetected
                      : QazaStrings.markedMissed,
                  style: TextStyle(fontSize: 12, color: p.textLight),
                ),
                trailing: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _confirm(context, ref, item),
                  icon: const Icon(AppIcons.confirmPerformed, size: 16),
                  label: const Text(QazaStrings.compensate),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    QazaItem item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(QazaStrings.confirmTitle),
        content: Text(
          QazaStrings.confirmBody(
            DateStrings.long(item.date),
            item.prayer.label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(QazaStrings.confirmYes),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(qazaProvider.notifier).compensate(item);
  }
}
