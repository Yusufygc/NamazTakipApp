import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Selçuklu sekiz köşeli yıldızı (Rub el-Hizb) ve mihrap kemeri suigranı çizen
/// dekoratif arka plan sarmalayıcısı.
class MihrabArchBackdrop extends StatelessWidget {
  const MihrabArchBackdrop({
    super.key,
    required this.child,
    required this.lineColor,
    this.accentColor,
    this.borderRadius = 24,
  });

  final Widget child;
  final Color lineColor;
  final Color? accentColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _MihrabAndStarPainter(
          lineColor: lineColor,
          accentColor: accentColor ?? lineColor,
        ),
        child: child,
      ),
    );
  }
}

class _MihrabAndStarPainter extends CustomPainter {
  const _MihrabAndStarPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final archPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final starPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Sağ üst ve sol alt köşelerde Selçuklu sekiz köşeli yıldız motifi
    _drawSeljukStar(
      canvas,
      Offset(size.width - 28, 28),
      44,
      starPaint,
    );
    _drawSeljukStar(
      canvas,
      Offset(26, size.height - 22),
      32,
      archPaint,
    );

    // Merkezde zarif sivri mihrap kemeri silüeti
    final w = size.width;
    final h = size.height;
    final left = w * 0.14;
    final right = w * 0.86;
    final topApex = h * 0.08;
    final shoulderY = h * 0.44;

    final arch = Path()
      ..moveTo(left, h)
      ..lineTo(left, shoulderY)
      ..quadraticBezierTo(left, topApex + 18, w * 0.5, topApex)
      ..quadraticBezierTo(right, topApex + 18, right, shoulderY)
      ..lineTo(right, h);

    canvas.drawPath(arch, archPaint);

    // İç kemer konturu
    final innerLeft = w * 0.19;
    final innerRight = w * 0.81;
    final innerApex = h * 0.14;
    final innerShoulderY = h * 0.46;

    final innerArch = Path()
      ..moveTo(innerLeft, h)
      ..lineTo(innerLeft, innerShoulderY)
      ..quadraticBezierTo(innerLeft, innerApex + 16, w * 0.5, innerApex)
      ..quadraticBezierTo(innerRight, innerApex + 16, innerRight, innerShoulderY)
      ..lineTo(innerRight, h);

    canvas.drawPath(
      innerArch,
      Paint()
        ..color = lineColor.withValues(alpha: (lineColor.a * 0.65).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawSeljukStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // İki karenin 45 derece açıyla üst üste binmesiyle oluşan 8 köşeli yıldız
    for (var sq = 0; sq < 2; sq++) {
      final offsetAngle = sq * (math.pi / 4);
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = offsetAngle + i * (math.pi / 2) + (math.pi / 4);
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(center, radius * 0.36, paint);
  }

  @override
  bool shouldRepaint(covariant _MihrabAndStarPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.accentColor != accentColor;
}

/// Rozetler, diyalog başlığı ve ikonlar için 8 köşeli Selçuklu madalyon çerçevesi.
class SeljukMedallion extends StatelessWidget {
  const SeljukMedallion({
    super.key,
    required this.child,
    required this.fillColor,
    required this.borderColor,
    this.size = 56,
  });

  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedallionPainter(
          fillColor: fillColor,
          borderColor: borderColor,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _MedallionPainter extends CustomPainter {
  const _MedallionPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rOuter = size.width / 2;
    final rInner = rOuter * 0.82;

    // 8 köşeli yıldız dış konturu (16 tepe noktası: dış ve iç yarıçap dönüşümlü)
    final star = Path();
    for (var i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) - (math.pi / 2);
      final r = i.isEven ? rOuter : rInner;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();

    canvas.drawPath(
      star,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      star,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _MedallionPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor;
}
