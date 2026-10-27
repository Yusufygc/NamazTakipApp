import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/time_format.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'islamic_pattern.dart';

/// Ayarlar ekranında telefon ana ekran widget'ının canlı önizlemesini ve
/// tek dokunuşla "Ana Ekrana Widget Ekle" düğmesini gösteren kart.
class HomeWidgetPreviewCard extends ConsumerWidget {
  const HomeWidgetPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final location = ref.watch(settingsProvider.select((s) => s.location));
    final todayTimes = ref.watch(todayTimesProvider);
    final upcomingDays = ref.watch(upcomingDaysProvider);
    final records = ref.watch(todayRecordsProvider).value ?? const {};

    final doneCount = records.values
        .where(
          (r) =>
              r.status == PrayerStatus.performed ||
              r.status == PrayerStatus.compensated,
        )
        .length;
    final next =
        upcomingDays.isEmpty ? null : nextPrayer(DateTime.now(), upcomingDays);

    final city = location?.city ?? NavStrings.home;
    final nextName = next?.type.label ?? PrayerType.fajr.label;
    final nextTimeStr = next != null ? formatTime(next.time) : '05:50';

    final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
    final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

    return Card(
      color: p.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              SettingsStrings.homeWidgetSubtitle,
              style: TextStyle(
                color: p.textLight,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            // Canlı Widget Önizlemesi (Android AppWidget / iOS WidgetKit görünümü)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: p.secondary.withValues(alpha: 0.55),
                  width: 1.2,
                ),
              ),
              child: MihrabArchBackdrop(
                borderRadius: 20,
                lineColor: Colors.white.withValues(alpha: 0.08),
                accentColor: p.secondary.withValues(alpha: 0.16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              SettingsStrings.homeWidgetHeader(city),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p.secondary.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              SettingsStrings.homeWidgetDoneBadge(doneCount),
                              style: TextStyle(
                                color: p.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                HomeStrings.nextBadge,
                                style: TextStyle(
                                  color: p.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                nextName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            nextTimeStr,
                            style: TextStyle(
                              color: p.secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            _MiniSlot(
                              label: PrayerType.fajr.label,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.fajr)
                                  : '--:--',
                            ),
                            _MiniSlot(
                              label: PrayerStrings.sunrise,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.sunrise)
                                  : '--:--',
                            ),
                            _MiniSlot(
                              label: PrayerType.dhuhr.label,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.dhuhr)
                                  : '--:--',
                            ),
                            _MiniSlot(
                              label: PrayerType.asr.label,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.asr)
                                  : '--:--',
                            ),
                            _MiniSlot(
                              label: PrayerType.maghrib.label,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.maghrib)
                                  : '--:--',
                            ),
                            _MiniSlot(
                              label: PrayerType.isha.label,
                              time: todayTimes != null
                                  ? formatTime(todayTimes.isha)
                                  : '--:--',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.primary,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () async {
                      final pinned = await ref
                          .read(settingsProvider.notifier)
                          .requestPinHomeWidget();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            pinned
                                ? SettingsStrings.homeWidgetPinSuccess
                                : SettingsStrings.homeWidgetManualHint,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(AppIcons.add, size: 18),
                    label: const Text(
                      SettingsStrings.homeWidgetPinButton,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(settingsProvider.notifier).syncHomeWidget();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(SettingsStrings.homeWidgetManualHint),
                      ),
                    );
                  },
                  icon: const Icon(AppIcons.retry, size: 17),
                  label: const Text(SettingsStrings.homeWidgetRefreshButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSlot extends StatelessWidget {
  const _MiniSlot({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
