import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'islamic_pattern.dart';

Future<void> showQiblaCompassSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QiblaCompassSheet(),
  );
}

class _QiblaCompassSheet extends ConsumerStatefulWidget {
  const _QiblaCompassSheet();

  @override
  ConsumerState<_QiblaCompassSheet> createState() => _QiblaCompassSheetState();
}

class _QiblaCompassSheetState extends ConsumerState<_QiblaCompassSheet> {
  double _manualHeading = 0;
  bool _wasAligned = false;

  void _checkAlignment(double heading, double qiblaBearing) {
    final diff = ((qiblaBearing - heading + 540) % 360) - 180;
    final aligned = diff.abs() <= 5.0;
    if (aligned && !_wasAligned) {
      HapticFeedback.selectionClick();
    }
    _wasAligned = aligned;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final qibla = ref.watch(qiblaProvider);
    final compass = ref.watch(compassHeadingProvider);
    final sensorHeading = compass.value;
    // Sensör yoksa (NO_SENSOR) sessiz kalmak yerine kullanıcıya söylenir.
    final noSensor = compass.hasError;
    final location = ref.watch(settingsProvider.select((s) => s.location));

    // Konum yokken sahte bir yön gösterilmez; kadran yerine açıklama çıkar.
    final bearing = qibla?.bearingDegrees ?? 0.0;
    final distKm = qibla?.distanceKm ?? 0;
    final heading = (((sensorHeading ?? 0) + _manualHeading) % 360 + 360) % 360;
    final diff = ((bearing - heading + 540) % 360) - 180;
    final isAligned = diff.abs() <= 5.0;
    if (qibla != null) _checkAlignment(heading, bearing);

    final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
    final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: p.secondary.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: MihrabArchBackdrop(
        borderRadius: 28,
        lineColor: Colors.white.withValues(alpha: 0.08),
        accentColor: p.secondary.withValues(alpha: 0.16),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SeljukMedallion(
                      size: 38,
                      fillColor: Colors.white.withValues(alpha: 0.14),
                      borderColor: p.secondary,
                      child: Icon(
                        AppIcons.compass,
                        size: 20,
                        color: p.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            HomeStrings.qiblaSheetTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (location != null)
                            Text(
                              location.city,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 12.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        AppIcons.confirmMissed,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (qibla == null)
                  const _QiblaNoLocation()
                else ...[
                  // Hizalanma durum kapsülü
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isAligned
                          ? p.accent.withValues(alpha: 0.28)
                          : Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAligned
                            ? p.accent
                            : p.secondary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAligned ? AppIcons.selected : AppIcons.compass,
                          size: 16,
                          color: isAligned ? Colors.white : p.secondary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isAligned
                                ? HomeStrings.qiblaAligned
                                : HomeStrings.qiblaRotateHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (noSensor) ...[
                    const SizedBox(height: 10),
                    Text(
                      HomeStrings.qiblaNoSensor,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Selçuklu Pusula Kadranı
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _manualHeading =
                            (_manualHeading - details.delta.dx * 0.7) % 360;
                      });
                    },
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _manualHeading = bearing);
                    },
                    child: SizedBox(
                      width: 248,
                      height: 248,
                      child: CustomPaint(
                        painter: _SeljukCompassPainter(
                          headingDegrees: heading,
                          qiblaDegrees: bearing,
                          isAligned: isAligned,
                          goldColor: p.secondary,
                          alignedColor: p.accent,
                        ),
                        child: Center(
                          child: SeljukMedallion(
                            size: 62,
                            fillColor: isAligned
                                ? p.accent
                                : Colors.black.withValues(alpha: 0.35),
                            borderColor: p.secondary,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.app,
                                  size: 20,
                                  color: isAligned ? Colors.white : p.secondary,
                                ),
                                Text(
                                  HomeStrings.qiblaDegree(bearing.round()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Alt metrik kartları: Kıble Açısı ve Kâbe Mesafesi
                  Row(
                    children: [
                      Expanded(
                        child: _QiblaMetricBox(
                          label: HomeStrings.qiblaAngleLabel,
                          value: HomeStrings.qiblaDegree(bearing.round()),
                          accent: p.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QiblaMetricBox(
                          label: HomeStrings.qiblaDistanceLabel,
                          value: HomeStrings.qiblaDistanceKm(distKm),
                          accent: p.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Konum bilinmediğinde kadran yerine gösterilen açıklama.
class _QiblaNoLocation extends StatelessWidget {
  const _QiblaNoLocation();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.secondary.withValues(alpha: 0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.location, color: p.secondary, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              HomeStrings.qiblaNoLocation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaMetricBox extends StatelessWidget {
  const _QiblaMetricBox({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeljukCompassPainter extends CustomPainter {
  const _SeljukCompassPainter({
    required this.headingDegrees,
    required this.qiblaDegrees,
    required this.isAligned,
    required this.goldColor,
    required this.alignedColor,
  });

  final double headingDegrees;
  final double qiblaDegrees;
  final bool isAligned;
  final Color goldColor;
  final Color alignedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Üst sabit hedef üçgeni (cihazın baktığı yön)
    final topIndicatorPaint = Paint()
      ..color = isAligned ? alignedColor : goldColor
      ..style = PaintingStyle.fill;
    final topTriangle = Path()
      ..moveTo(center.dx, 2)
      ..lineTo(center.dx - 7, 14)
      ..lineTo(center.dx + 7, 14)
      ..close();
    canvas.drawPath(topTriangle, topIndicatorPaint);

    // Dış çember
    final ringPaint = Paint()
      ..color = isAligned
          ? alignedColor.withValues(alpha: 0.85)
          : goldColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // 8 köşeli Selçuklu yıldızı arka planı ve derece çizgileri (cihaz dönüşüne göre döner)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-headingDegrees * math.pi / 180.0);

    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rStar = radius - 34;
    for (final angle in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: rStar * 1.35,
          height: rStar * 1.35,
        ),
        starPaint,
      );
      canvas.restore();
    }

    // 72 adet 5 derecelik kadran çizgisi
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.3;
    final majorTickPaint = Paint()
      ..color = goldColor
      ..strokeWidth = 2.2;

    for (var i = 0; i < 360; i += 5) {
      final rad = i * math.pi / 180.0;
      final isMajor = i % 30 == 0;
      final outer = radius - 12;
      final inner = outer - (isMajor ? 10 : 5);
      canvas.drawLine(
        Offset(math.sin(rad) * inner, -math.cos(rad) * inner),
        Offset(math.sin(rad) * outer, -math.cos(rad) * outer),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    // K / D / G / B yön harfleri
    final cardinals = <int, String>{
      0: HomeStrings.qiblaNorth,
      90: HomeStrings.qiblaEast,
      180: HomeStrings.qiblaSouth,
      270: HomeStrings.qiblaWest,
    };
    for (final entry in cardinals.entries) {
      final rad = entry.key * math.pi / 180.0;
      final pos = Offset(
        math.sin(rad) * (radius - 34),
        -math.cos(rad) * (radius - 34),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            color: entry.key == 0 ? goldColor : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Kıble İbresi (Kâbe açısına bakar)
    canvas.save();
    canvas.rotate(qiblaDegrees * math.pi / 180.0);

    final needlePaint = Paint()
      ..color = isAligned ? alignedColor : goldColor
      ..style = PaintingStyle.fill;
    final needlePath = Path()
      ..moveTo(0, -(radius - 16))
      ..lineTo(-9, -28)
      ..lineTo(0, -36)
      ..lineTo(9, -28)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // İbre ucundaki altın nokta
    canvas.drawCircle(
      Offset(0, -(radius - 14)),
      4.5,
      Paint()..color = Colors.white,
    );

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeljukCompassPainter oldDelegate) =>
      oldDelegate.headingDegrees != headingDegrees ||
      oldDelegate.qiblaDegrees != qiblaDegrees ||
      oldDelegate.isAligned != isAligned;
}
