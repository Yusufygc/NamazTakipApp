import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class StatsHeatmapTab extends ConsumerStatefulWidget {
  const StatsHeatmapTab({super.key});

  @override
  ConsumerState<StatsHeatmapTab> createState() => _StatsHeatmapTabState();
}

class _StatsHeatmapTabState extends ConsumerState<StatsHeatmapTab> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final today = ref.read(trackingDayProvider);
    _month = DateTime(today.year, today.month);
  }

  Color _color(AppPalette p, int count) {
    if (count >= 5) return p.primary;
    if (count >= 3) return p.secondary;
    if (count >= 1) return const Color(0xFFE67E22);
    return p.danger;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = ref.watch(trackingDayProvider);
    final isCurrent = _month.year == today.year && _month.month == today.month;
    final async = ref.watch(monthCountsProvider(_month));
    final install = ref.watch(trackingStartProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      tooltip: StatsStrings.previousMonth,
                      onPressed: () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      ),
                      icon: const Icon(AppIcons.monthPrevious),
                    ),
                    Text(
                      DateStrings.monthAndYear(_month),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: p.primary,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: StatsStrings.nextMonth,
                      onPressed: isCurrent
                          ? null
                          : () => setState(
                                () => _month =
                                    DateTime(_month.year, _month.month + 1),
                              ),
                      icon: const Icon(AppIcons.monthNext),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final d in DateStrings.weekdaysShort)
                      Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: p.textLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                async.when(
                  loading: () => const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(CommonStrings.error(e)),
                  data: (counts) => _grid(p, counts, today, install),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _legend(p.primary, StatsStrings.legendFull),
                    _legend(p.secondary, StatsStrings.legendMost),
                    _legend(const Color(0xFFE67E22), StatsStrings.legendFew),
                    _legend(p.danger, StatsStrings.legendNone),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      );

  Widget _grid(
    AppPalette p,
    List<DayCount> counts,
    DateTime today,
    DateTime install,
  ) {
    final lead = DateTime(_month.year, _month.month).weekday - 1;
    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (final c in counts) _cell(p, c, today, install),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: cells,
    );
  }

  Widget _cell(AppPalette p, DayCount c, DateTime today, DateTime install) {
    final tracked = !c.date.isAfter(today) && !c.date.isBefore(install);
    final bg = tracked ? _color(p, c.performed) : p.background;
    final fg = tracked ? Colors.white : p.textLight;
    return Semantics(
      label: StatsStrings.cellSemantics(DateStrings.long(c.date), c.performed),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: tracked
              ? null
              : Border.all(color: p.primary.withValues(alpha: 0.08)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${c.date.day}',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            if (tracked)
              Text(
                StatsStrings.dayCount(c.performed),
                style: TextStyle(
                  color: fg.withValues(alpha: 0.90),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
