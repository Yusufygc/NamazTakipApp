import 'package:flutter/material.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';

class DhikrCard extends StatelessWidget {
  const DhikrCard({
    super.key,
    required this.item,
    required this.palette,
    required this.onOpenCounter,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.onOpenVideo,
  });

  final DhikrItem item;
  final AppPalette palette;
  final VoidCallback onOpenCounter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onOpenVideo;

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isCompleted
        ? palette.secondary.withValues(alpha: 0.65)
        : palette.primary.withValues(alpha: palette.isDark ? 0.22 : 0.12);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.groupName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: palette.primary,
                        ),
                      ),
                    ),
                    if (item.prayerTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: palette.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DhikrStrings.recommendedAfter(item.prayerTime!.label),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: onToggleFavorite,
                icon: Icon(
                  item.isFavorite ? AppIcons.favorite : AppIcons.favoriteBorder,
                  color:
                      item.isFavorite ? palette.secondary : palette.textLight,
                  size: 19,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: onEdit,
                icon: Icon(AppIcons.edit, color: palette.textLight, size: 18),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: onDelete,
                icon: Icon(AppIcons.delete, color: palette.danger, size: 18),
              ),
            ],
          ),
          if (item.arabic.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: palette.secondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          if (item.transliteration.isNotEmpty &&
              item.transliteration != item.title) ...[
            const SizedBox(height: 2),
            Text(
              item.transliteration,
              style: TextStyle(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: palette.textLight,
              ),
            ),
          ],
          if (item.meaning.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.meaning,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: palette.textLight,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 6,
              backgroundColor: palette.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                item.isCompleted ? palette.secondary : palette.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                DhikrStrings.progressLabel(item.currentCount, item.targetCount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: item.isCompleted ? palette.secondary : palette.text,
                ),
              ),
              if (item.totalCompleted > 0) ...[
                const SizedBox(width: 8),
                Text(
                  DhikrStrings.completedCycles(item.totalCompleted),
                  style: TextStyle(fontSize: 11.5, color: palette.textLight),
                ),
              ],
              const Spacer(),
              if (onOpenVideo != null) ...[
                TextButton.icon(
                  onPressed: onOpenVideo,
                  icon: const Icon(AppIcons.externalLink, size: 15),
                  label: const Text(
                    DhikrStrings.openVideoButton,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              FilledButton.tonalIcon(
                onPressed: onOpenCounter,
                icon: const Icon(AppIcons.touch, size: 16),
                label: const Text(
                  DhikrStrings.startCounterButton,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
