import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Ana ekrandaki tek vakit satırı.
class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    this.isPerformed = false,
    this.isMissed = false,
    this.isNext = false,
    this.isDisplayOnly = false,
    this.onTap,
  });

  final String name;
  final String time;
  final bool isPerformed;
  final bool isMissed;
  final bool isNext;
  final bool isDisplayOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Color background = p.card;
    Color? border;
    Color textColor = p.text;
    if (isDisplayOnly) {
      border = const Color(0xFFFFCC00);
    } else if (isNext) {
      background = p.primary;
      border = p.dark;
      textColor = p.isDark ? p.text : Colors.white;
    } else if (isPerformed) {
      // Şeffaf renk gölgeyi göstererek mat görünür; kartın üstüne harmanla.
      background = Color.alphaBlend(p.secondary.withValues(alpha: 0.25), p.card);
      border = p.secondary;
    } else if (isMissed) {
      background = Color.alphaBlend(p.danger.withValues(alpha: 0.15), p.card);
      border = p.danger;
      // Açık temalarda #FF8A80 beyaz üstünde düşük kontrastlı; koyu kırmızı kullan.
      textColor = p.isDark ? p.danger : const Color(0xFFC62828);
    }

    return Semantics(
      button: !isDisplayOnly,
      label: '$name $time'
          '${isPerformed ? ', kılındı' : isMissed ? ', kılınmadı' : ''}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 1.5,
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border, width: isNext ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDisplayOnly ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20, vertical: isDisplayOnly ? 14 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    const SizedBox(height: 2),
                    Text(time,
                        style: TextStyle(
                            fontSize: 15,
                            color: textColor.withValues(alpha: 0.85))),
                  ],
                ),
                _StatusIcon(
                  isDisplayOnly: isDisplayOnly,
                  isPerformed: isPerformed,
                  isMissed: isMissed,
                  isNext: isNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isDisplayOnly,
    required this.isPerformed,
    required this.isMissed,
    required this.isNext,
  });

  final bool isDisplayOnly;
  final bool isPerformed;
  final bool isMissed;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (isDisplayOnly) return const Text('☀️', style: TextStyle(fontSize: 24));

    Widget circle(Color color, {Widget? child, bool filled = true}) => Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : null,
            border: filled ? null : Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: child,
        );

    if (isPerformed) {
      return circle(p.secondary,
          child: Icon(Icons.check, size: 20, color: p.isDark ? Colors.black : p.dark));
    }
    if (isMissed) {
      return circle(p.danger, child: const Icon(Icons.close, size: 20, color: Colors.white));
    }
    return circle(
      isNext ? Colors.white : p.textLight,
      filled: false,
      child: isNext
          ? const Icon(Icons.hourglass_top, size: 16, color: Colors.white)
          : null,
    );
  }
}
