import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

/// Süreç: Performans (radar), Isı Haritası ve Karşılaştırma sekmeleri.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: p.card,
            child: TabBar(
              labelColor: p.primary,
              unselectedLabelColor: p.textLight,
              indicatorColor: p.primary,
              tabs: const [
                Tab(icon: Icon(AppIcons.statsRadar), text: StatsStrings.tabPerformance),
                Tab(icon: Icon(AppIcons.statsHeatmap), text: StatsStrings.tabHeatmap),
                Tab(icon: Icon(AppIcons.statsCompare), text: StatsStrings.tabComparison),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [_RadarTab(), _HeatmapTab(), _ComparisonTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Radar -----------------------------------------------------------------

class _RadarTab extends ConsumerStatefulWidget {
  const _RadarTab();

  @override
  ConsumerState<_RadarTab> createState() => _RadarTabState();
}

class _RadarTabState extends ConsumerState<_RadarTab> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final async = ref.watch(radarProvider(_days));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 7, label: Text(StatsStrings.days(7))),
              ButtonSegment(value: 30, label: Text(StatsStrings.days(30))),
              ButtonSegment(value: 90, label: Text(StatsStrings.days(90))),
            ],
            selected: {_days},
            onSelectionChanged: (s) => setState(() => _days = s.first),
          ),
        ),
        const SizedBox(height: 16),
        async.when(
          loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text(CommonStrings.error(e)),
          data: (data) {
            final values = [for (final t in PrayerType.values) (data[t] ?? 0).toDouble()];
            return Column(
              children: [
                SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      tickCount: 4,
                      ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                      tickBorderData: BorderSide(color: p.textLight.withValues(alpha: 0.3)),
                      gridBorderData: BorderSide(color: p.textLight.withValues(alpha: 0.3)),
                      radarBorderData: BorderSide(color: p.textLight.withValues(alpha: 0.3)),
                      titleTextStyle: TextStyle(color: p.text, fontSize: 13, fontWeight: FontWeight.w600),
                      getTitle: (i, _) => RadarChartTitle(text: PrayerType.values[i].label),
                      dataSets: [
                        RadarDataSet(
                          fillColor: p.primary.withValues(alpha: 0.35),
                          borderColor: p.primary,
                          entryRadius: 3,
                          borderWidth: 2.5,
                          dataEntries: [for (final v in values) RadarEntry(value: v)],
                        ),
                        // Ölçeği 0-100'e sabitlemek için görünmez referans.
                        RadarDataSet(
                          fillColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          entryRadius: 0,
                          borderWidth: 0,
                          dataEntries: [for (var i = 0; i < 5; i++) const RadarEntry(value: 100)],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final t in PrayerType.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(width: 70, child: Text(t.label)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (data[t] ?? 0) / 100,
                              minHeight: 10,
                              color: p.primary,
                              backgroundColor: p.dark.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(StatsStrings.percent(data[t] ?? 0), textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---- Isı haritası ------------------------------------------------------------

class _HeatmapTab extends ConsumerStatefulWidget {
  const _HeatmapTab();

  @override
  ConsumerState<_HeatmapTab> createState() => _HeatmapTabState();
}

class _HeatmapTabState extends ConsumerState<_HeatmapTab> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final today = prayerDay(DateTime.now());
    _month = DateTime(today.year, today.month);
  }

  Color _color(AppPalette p, int count) {
    if (count >= 5) return const Color(0xFF4CAF50);
    if (count >= 3) return const Color(0xFFFFC107);
    if (count >= 1) return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = ref.watch(trackingDayProvider);
    final isCurrent = _month.year == today.year && _month.month == today.month;
    final async = ref.watch(monthCountsProvider(_month));
    final install = ref.read(backendProvider).trackingStart;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: StatsStrings.previousMonth,
              onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              icon: const Icon(AppIcons.monthPrevious),
            ),
            Text(DateStrings.monthAndYear(_month),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p.primary)),
            IconButton.filledTonal(
              tooltip: StatsStrings.nextMonth,
              onPressed: isCurrent
                  ? null
                  : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              icon: const Icon(AppIcons.monthNext),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final d in DateStrings.weekdaysShort)
              Expanded(
                child: Center(
                  child: Text(d, style: TextStyle(fontSize: 12, color: p.textLight)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        async.when(
          loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text(CommonStrings.error(e)),
          data: (counts) => _grid(p, counts, today, install),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            _legend(const Color(0xFF4CAF50), StatsStrings.legendFull),
            _legend(const Color(0xFFFFC107), StatsStrings.legendMost),
            _legend(const Color(0xFFFF9800), StatsStrings.legendFew),
            _legend(const Color(0xFFEF5350), StatsStrings.legendNone),
          ],
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
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  Widget _grid(AppPalette p, List<DayCount> counts, DateTime today, DateTime install) {
    final lead = DateTime(_month.year, _month.month).weekday - 1; // Pazartesi = 0
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
    final bg = tracked ? _color(p, c.performed) : p.card;
    final fg = tracked ? Colors.white : p.textLight;
    return Semantics(
      label: StatsStrings.cellSemantics(DateStrings.long(c.date), c.performed),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${c.date.day}',
                style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14)),
            if (tracked)
              Text(StatsStrings.dayCount(c.performed),
                  style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ---- Karşılaştırma -------------------------------------------------------------

class _ComparisonTab extends ConsumerStatefulWidget {
  const _ComparisonTab();

  @override
  ConsumerState<_ComparisonTab> createState() => _ComparisonTabState();
}

class _ComparisonTabState extends ConsumerState<_ComparisonTab> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cmp = ref.watch(weekComparisonProvider).value;
    final counts = ref.watch(dailyCountsProvider(_weekly ? 7 : 30));

    final diff = cmp?.diff ?? 0;
    // Açık temalarda p.secondary beyaz üstünde soluk kalır; koyu yeşil kullan.
    final Color diffColor = diff > 0
        ? (p.isDark ? p.secondary : const Color(0xFF2E7D32))
        : diff < 0
            ? const Color(0xFFEF5350)
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
            _statCard(p, StatsStrings.thisWeek, cmp?.currentWeek ?? 0, AppIcons.weekCurrent, p.primary),
            const SizedBox(width: 10),
            _statCard(p, StatsStrings.lastWeek, cmp?.previousWeek ?? 0, AppIcons.weekPrevious, p.textLight),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(StatsStrings.progress, style: TextStyle(color: p.textLight)),
                    Text(StatsStrings.progressValue(diff),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Icon(diffIcon, size: 32, color: diffColor),
                    Text(diffText, style: TextStyle(color: diffColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text(StatsStrings.weekly)),
              ButtonSegment(value: false, label: Text(StatsStrings.monthly)),
            ],
            selected: {_weekly},
            onSelectionChanged: (s) => setState(() => _weekly = s.first),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: counts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(CommonStrings.error(e)),
            data: (list) => _weekly ? _bar(p, list) : _line(p, list),
          ),
        ),
      ],
    );
  }

  Widget _statCard(AppPalette p, String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: p.card,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: p.textLight)),
              Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Icon(icon, color: color),
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
          getDrawingHorizontalLine: (_) =>
              FlLine(color: p.textLight.withValues(alpha: 0.2), strokeWidth: 1),
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
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: TextStyle(color: p.textLight, fontSize: 11)),
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
                  child: Text(_label(list[i].date),
                      style: TextStyle(color: p.textLight, fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < list.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: list[i].performed.toDouble(),
                color: p.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ]),
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
          getDrawingHorizontalLine: (_) =>
              FlLine(color: p.textLight.withValues(alpha: 0.2), strokeWidth: 1),
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
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: TextStyle(color: p.textLight, fontSize: 11)),
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
                  child: Text(_label(list[i].date),
                      style: TextStyle(color: p.textLight, fontSize: 11)),
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
            belowBarData: BarAreaData(show: true, color: p.primary.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}
