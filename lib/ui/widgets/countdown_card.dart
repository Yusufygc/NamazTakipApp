import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/date_utils.dart';
import '../../core/prayer.dart';
import '../../providers/providers.dart';

/// Sıradaki vakte kalan süre. Saat tabanlıdır; sayfa yenilemeden Yatsı'dan
/// sonra Sabah'a, gece yarısından sonra yeni güne kendiliğinden geçer.
class CountdownCard extends ConsumerStatefulWidget {
  const CountdownCard({super.key, this.onNextChanged});

  /// Sıradaki vakit değiştiğinde (örn. ezan vakti girince) çağrılır.
  final ValueChanged<PrayerType?>? onNextChanged;

  @override
  ConsumerState<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends ConsumerState<CountdownCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  PrayerType? _lastNext;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.read(trackingDayProvider.notifier).sync();
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    return '${two(h)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final next = nextPrayer(_now, ref.watch(upcomingDaysProvider));

    if (next?.type != _lastNext) {
      _lastNext = next?.type;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onNextChanged?.call(next?.type));
    }

    final onPrimary = p.isDark ? p.text : Colors.white;
    return Card(
      color: p.primary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: next == null
            ? Text('Vakit bilgisi yok',
                textAlign: TextAlign.center, style: TextStyle(color: onPrimary))
            : Semantics(
                liveRegion: false,
                label:
                    '${next.type.trName} vaktine ${_format(next.time.difference(_now))} kaldı',
                child: Column(
                  children: [
                    Text('Sıradaki Namaz: ${next.type.trName}',
                        style: TextStyle(
                            color: onPrimary.withValues(alpha: 0.9), fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      _format(next.time.difference(_now)),
                      style: TextStyle(
                        color: onPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Vakit: ${formatTime(next.time)}',
                        style: TextStyle(color: onPrimary.withValues(alpha: 0.85))),
                  ],
                ),
              ),
      ),
    );
  }
}
