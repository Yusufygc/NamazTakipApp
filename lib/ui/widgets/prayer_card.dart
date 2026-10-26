import 'package:flutter/material.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';

/// Zaman çizelgesi (Timeline) bağlantılı vakit satırı kartı.
class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    this.prayerType,
    this.isPerformed = false,
    this.isMissed = false,
    this.isCongregation = false,
    this.isNext = false,
    this.isDisplayOnly = false,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final String name;
  final String time;
  final PrayerType? prayerType;
  final bool isPerformed;
  final bool isMissed;
  final bool isCongregation;
  final bool isNext;
  final bool isDisplayOnly;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Kart arka planı ve kenarlık renkleri
    Color cardBg = p.card;
    Color borderColor = p.primary.withValues(alpha: p.isDark ? 0.16 : 0.10);
    double borderWidth = 1.0;

    if (isNext) {
      cardBg = Color.alphaBlend(
        p.secondary.withValues(alpha: p.isDark ? 0.14 : 0.12),
        p.card,
      );
      borderColor = p.secondary;
      borderWidth = 1.8;
    } else if (isPerformed) {
      cardBg = Color.alphaBlend(
        p.primary.withValues(alpha: p.isDark ? 0.18 : 0.08),
        p.card,
      );
      borderColor = p.primary.withValues(alpha: 0.45);
    } else if (isMissed) {
      cardBg = Color.alphaBlend(
        p.danger.withValues(alpha: p.isDark ? 0.16 : 0.07),
        p.card,
      );
      borderColor = p.danger.withValues(alpha: 0.45);
    } else if (isDisplayOnly) {
      cardBg = p.card.withValues(alpha: p.isDark ? 0.65 : 0.80);
    }

    // Zaman çizelgesi düğüm rengi ve ikonu
    Color nodeColor = p.textLight.withValues(alpha: 0.35);
    IconData nodeIcon = AppIcons.prayerPending;
    if (isPerformed) {
      nodeColor = p.primary;
      nodeIcon = AppIcons.prayerPerformed;
    } else if (isMissed) {
      nodeColor = p.danger;
      nodeIcon = AppIcons.prayerMissed;
    } else if (isNext) {
      nodeColor = p.secondary;
      nodeIcon = AppIcons.prayerNext;
    } else if (isDisplayOnly) {
      nodeColor = p.secondary.withValues(alpha: 0.75);
      nodeIcon = AppIcons.sunrise;
    }

    final leadingIcon = isDisplayOnly
        ? AppIcons.sunrise
        : (prayerType != null ? AppIcons.prayerIcon(prayerType!) : AppIcons.app);

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sol dikey zaman çizelgesi (Timeline) sütunu
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isFirst
                      ? Colors.transparent
                      : p.primary.withValues(alpha: 0.20),
                ),
              ),
              Container(
                width: isNext ? 24 : 20,
                height: isNext ? 24 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPerformed || isNext ? nodeColor : p.background,
                  border: Border.all(
                    color: nodeColor,
                    width: isNext ? 2.4 : 1.8,
                  ),
                  boxShadow: isNext
                      ? [
                          BoxShadow(
                            color: p.secondary.withValues(alpha: 0.40),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  nodeIcon,
                  size: isNext ? 13 : 11,
                  color: isPerformed || isNext ? Colors.white : nodeColor,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : p.primary.withValues(alpha: 0.20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Sağ vakit kartı gövdesi
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Material(
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor, width: borderWidth),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isDisplayOnly ? null : onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (isNext ? p.secondary : p.primary)
                              .withValues(alpha: p.isDark ? 0.22 : 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          leadingIcon,
                          size: 19,
                          color: isNext ? p.secondary : p.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isNext ? FontWeight.w800 : FontWeight.w600,
                                color: isDisplayOnly ? p.textLight : p.text,
                              ),
                            ),
                            if (isNext)
                              _StatusBadge(
                                label: HomeStrings.nextTag,
                                color: p.secondary,
                                filled: true,
                              ),
                            if (isCongregation && isPerformed)
                              _StatusBadge(
                                label: HomeStrings.congregationBadge,
                                color: p.primary,
                                icon: AppIcons.congregation,
                              )
                            else if (isPerformed)
                              _StatusBadge(
                                label: HomeStrings.performedBadge,
                                color: p.primary,
                              )
                            else if (isMissed)
                              _StatusBadge(
                                label: HomeStrings.missedBadge,
                                color: p.danger,
                              )
                            else if (isDisplayOnly)
                              _StatusBadge(
                                label: HomeStrings.sunriseTag,
                                color: p.textLight,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isNext
                              ? p.primary
                              : (isDisplayOnly ? p.textLight : p.text),
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      if (!isDisplayOnly) ...[
                        const SizedBox(width: 6),
                        Icon(
                          AppIcons.chevronRight,
                          size: 18,
                          color: p.textLight.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: !isDisplayOnly && onTap != null,
      label: HomeStrings.prayerSemantics(
        name,
        time,
        performed: isPerformed,
        missed: isMissed,
      ),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedHeight) return row;
          return IntrinsicHeight(child: row);
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
