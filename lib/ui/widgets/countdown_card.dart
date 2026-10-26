import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/time_format.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'islamic_pattern.dart';

/// Mihrap kemeri ve Selçuklu yıldızı motifli ana geri sayım (Hero) kartı.
class CountdownCard extends ConsumerStatefulWidget {
  const CountdownCard({super.key, this.onNextChanged});

  final ValueChanged<PrayerType?>? onNextChanged;

  @override
  ConsumerState<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends ConsumerState<CountdownCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  PrayerType? _lastNotified;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(trackingDayProvider.notifier).sync();
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  double _intervalProgress(List<DayTimes> days, DateTime nextTime) {
    DateTime? prevTime;
    for (final d in days) {
      for (final p in PrayerType.values) {
        final t = d.timeOf(p);
        if (!t.isAfter(_now) && (prevTime == null || t.isAfter(prevTime))) {
          prevTime = t;
        }
      }
    }
    if (prevTime == null || !nextTime.isAfter(prevTime)) return 0.5;
    final total = nextTime.difference(prevTime).inSeconds;
    if (total <= 0) return 0.5;
    final elapsed = _now.difference(prevTime).inSeconds;
    return (elapsed / total).clamp(0.04, 1.0);
  }

  void _notifyNext(PrayerType? type) {
    if (type == _lastNotified) return;
    _lastNotified = type;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onNextChanged?.call(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final days = ref.watch(upcomingDaysProvider);
    final today = ref.watch(trackingDayProvider);
    final records = ref.watch(todayRecordsProvider).value ?? const {};
    final doneCount = records.values
        .where(
          (r) =>
              r.status == PrayerStatus.performed ||
              r.status == PrayerStatus.compensated,
        )
        .length;
    final next = days.isEmpty ? null : nextPrayer(_now, days);
    _notifyNext(next?.type);

    final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
    final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            HomeStrings.noTimes,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final remaining = _fmt(next.time.difference(_now));
    final progress = _intervalProgress(days, next.time);

    return Semantics(
      label: HomeStrings.countdownSemantics(next.type.label, remaining),
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: p.secondary.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: p.dark.withValues(alpha: p.isDark ? 0.45 : 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: MihrabArchBackdrop(
          borderRadius: 22,
          lineColor: Colors.white.withValues(alpha: 0.08),
          accentColor: p.secondary.withValues(alpha: 0.16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              children: [
                // Üst satır: Sıradaki vakit rozeti ve hedef saat kapsülü
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: p.secondary.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.prayerIcon(next.type),
                            size: 14,
                            color: p.secondary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            HomeStrings.nextBadge,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        HomeStrings.timeLabel(formatTime(next.time)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Merkez: Vakit adı ve büyük sayaç
                Text(
                  HomeStrings.nextPrayer(next.type.label),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 10),
                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    color: p.secondary,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                const SizedBox(height: 10),
                // Alt bilgi satırı: Tarih ve tamamlanan vakit sayısı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateStrings.long(today),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.secondary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        HomeStrings.completedSummary(doneCount, 5),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
