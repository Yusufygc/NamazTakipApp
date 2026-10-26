import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/stats_comparison_tab.dart';
import '../widgets/stats_heatmap_tab.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: p.primary.withValues(alpha: p.isDark ? 0.18 : 0.10),
                ),
              ),
              child: TabBar(
                labelColor: p.primary,
                unselectedLabelColor: p.textLight,
                indicatorColor: p.primary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    icon: Icon(AppIcons.statsRadar, size: 20),
                    text: StatsStrings.tabPerformance,
                  ),
                  Tab(
                    icon: Icon(AppIcons.statsHeatmap, size: 20),
                    text: StatsStrings.tabHeatmap,
                  ),
                  Tab(
                    icon: Icon(AppIcons.statsCompare, size: 20),
                    text: StatsStrings.tabComparison,
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _RadarTab(),
                StatsHeatmapTab(),
                StatsComparisonTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          loading: () => const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(CommonStrings.error(e)),
          data: (data) {
            final values = [
              for (final t in PrayerType.values) (data[t] ?? 0).toDouble(),
            ];
            return Column(
              children: [
                Card(
                  color: p.card,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 270,
                      child: RadarChart(
                        RadarChartData(
                          radarShape: RadarShape.polygon,
                          tickCount: 4,
                          ticksTextStyle: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 0,
                          ),
                          tickBorderData: BorderSide(
                            color: p.textLight.withValues(alpha: 0.25),
                          ),
                          gridBorderData: BorderSide(
                            color: p.textLight.withValues(alpha: 0.25),
                          ),
                          radarBorderData: BorderSide(
                            color: p.primary.withValues(alpha: 0.35),
                          ),
                          titleTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          getTitle: (i, _) => RadarChartTitle(
                            text: PrayerType.values[i].label,
                          ),
                          dataSets: [
                            RadarDataSet(
                              fillColor: p.primary.withValues(alpha: 0.30),
                              borderColor: p.primary,
                              entryRadius: 3.5,
                              borderWidth: 2.5,
                              dataEntries: [
                                for (final v in values) RadarEntry(value: v),
                              ],
                            ),
                            RadarDataSet(
                              fillColor: Colors.transparent,
                              borderColor: Colors.transparent,
                              entryRadius: 0,
                              borderWidth: 0,
                              dataEntries: [
                                for (var i = 0; i < 5; i++)
                                  const RadarEntry(value: 100),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: p.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final t in PrayerType.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  AppIcons.prayerIcon(t),
                                  size: 18,
                                  color: p.primary,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 64,
                                  child: Text(
                                    t.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (data[t] ?? 0) / 100,
                                      minHeight: 9,
                                      color: p.primary,
                                      backgroundColor:
                                          p.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    StatsStrings.percent(data[t] ?? 0),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
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
