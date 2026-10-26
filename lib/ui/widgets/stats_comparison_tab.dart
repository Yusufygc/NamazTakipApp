import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class StatsComparisonTab extends ConsumerStatefulWidget {
  const StatsComparisonTab({super.key});

  @override
  ConsumerState<StatsComparisonTab> createState() => _StatsComparisonTabState();
}

class _StatsComparisonTabState extends ConsumerState<StatsComparisonTab> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cmp = ref.watch(weekComparisonProvider).value;
    final counts = ref.watch(dailyCountsProvider(_weekly ? 7 : 30));

    final diff = cmp?.diff ?? 0;
    final Color diffColor = diff > 0
        ? p.primary
        : diff < 0
            ? p.danger
            : p.textLight;
    final IconData diffIcon = diff > 0
        ? AppIcons.trendUp
        : diff < 0
            ? AppIcons.trendDown
            : AppIcons.trendFlat;
    final String diffText = diff > 0
        ? StatsStrings.trendUp
        : diff < 0
            ? StatsStrings.trendDown
            : StatsStrings.trendFlat;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _statCard(
              p,
              StatsStrings.thisWeek,
              cmp?.currentWeek ?? 0,
              AppIcons.weekCurrent,
              p.primary,
            ),
            const SizedBox(width: 10),
            _statCard(
              p,
              StatsStrings.lastWeek,
              cmp?.previousWeek ?? 0,
              AppIcons.weekPrevious,
              p.secondary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StatsStrings.progress,
                      style: TextStyle(color: p.textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      StatsStrings.progressValue(diff),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(diffIcon, size: 22, color: diffColor),
                      const SizedBox(width: 6),
                      Text(
                        diffText,
                        style: TextStyle(
                          color: diffColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text(StatsStrings.weekly),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(StatsStrings.monthly),
                      ),
                    ],
                    selected: {_weekly},
                    onSelectionChanged: (s) =>
                        setState(() => _weekly = s.first),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 230,
                  child: counts.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(CommonStrings.error(e)),
                    data: (list) => _weekly ? _bar(p, list) : _line(p, list),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    AppPalette p,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: p.card,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                label,
                style: TextStyle(color: p.textLight, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(DateTime d) => DateStrings.short(d);

  Widget _bar(AppPalette p, List<DayCount> list) {
    return BarChart(
      BarChartData(
        maxY: 5,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: p.textLight.withValues(alpha: 0.16),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: TextStyle(color: p.textLight, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= list.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _label(list[i].date),
                    style: TextStyle(color: p.textLight, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < list.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: list[i].performed.toDouble(),
                  color: p.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _line(AppPalette p, List<DayCount> list) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 5,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: p.textLight.withValues(alpha: 0.16),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: TextStyle(color: p.textLight, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= list.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _label(list[i].date),
                    style: TextStyle(color: p.textLight, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < list.length; i++)
                FlSpot(i.toDouble(), list[i].performed.toDouble()),
            ],
            isCurved: true,
            color: p.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: p.primary.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}
