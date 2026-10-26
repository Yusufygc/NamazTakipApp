import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'islamic_pattern.dart';

/// Dokunmatik Selçuklu Zikirmatik alt sayfası.
Future<void> showDhikrCounterSheet(BuildContext context, DhikrItem initialItem) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DhikrCounterSheet(initialItem: initialItem),
  );
}

class DhikrCounterSheet extends ConsumerStatefulWidget {
  const DhikrCounterSheet({super.key, required this.initialItem});

  final DhikrItem initialItem;

  @override
  ConsumerState<DhikrCounterSheet> createState() => _DhikrCounterSheetState();
}

class _DhikrCounterSheetState extends ConsumerState<DhikrCounterSheet> {
  late DhikrItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
  }

  Future<void> _onTapCount() async {
    final wasCompleted = _item.isCompleted;
    if (wasCompleted) {
      await ref.read(dhikrProvider.notifier).resetCount(_item.id);
    }
    final updated = await ref.read(dhikrProvider.notifier).increment(_item.id);
    if (updated == null || !mounted) return;
    if (updated.isCompleted && !wasCompleted) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() => _item = updated);
  }

  Future<void> _onReset() async {
    HapticFeedback.selectionClick();
    final updated = await ref.read(dhikrProvider.notifier).resetCount(_item.id);
    if (updated != null && mounted) {
      setState(() => _item = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final borderColor = p.primary.withValues(alpha: p.isDark ? 0.24 : 0.14);

    return Container(
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _item.groupName,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ),
              if (_item.prayerTime != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: p.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DhikrStrings.recommendedAfter(_item.prayerTime!.label),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: p.secondary,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: _onReset,
                tooltip: DhikrStrings.resetCounterButton,
                icon: Icon(AppIcons.reset, color: p.textLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_item.arabic.isNotEmpty) ...[
            Text(
              _item.arabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: p.secondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            _item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: p.text,
            ),
          ),
          if (_item.transliteration.isNotEmpty &&
              _item.transliteration != _item.title) ...[
            const SizedBox(height: 4),
            Text(
              _item.transliteration,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                color: p.textLight,
              ),
            ),
          ],
          if (_item.meaning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _item.meaning,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: p.textLight,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 22),
          // Dokunmatik Zikirmatik Madalyonu
          GestureDetector(
            onTap: _onTapCount,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SeljukMedallion(
                  size: 210,
                  fillColor: p.primary.withValues(alpha: 0.06),
                  borderColor: p.secondary.withValues(alpha: 0.35),
                  child: const SizedBox.shrink(),
                ),
                SizedBox(
                  width: 174,
                  height: 174,
                  child: CircularProgressIndicator(
                    value: _item.progress,
                    strokeWidth: 10,
                    backgroundColor: borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _item.isCompleted ? p.secondary : p.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [p.primary, p.dark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_item.currentCount}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${_item.targetCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        _item.isCompleted ? AppIcons.selected : AppIcons.touch,
                        size: 20,
                        color: p.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _item.isCompleted
                ? DhikrStrings.completedBadge
                : DhikrStrings.counterTapHint,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _item.isCompleted ? p.secondary : p.textLight,
            ),
          ),
          if (_item.totalCompleted > 0) ...[
            const SizedBox(height: 4),
            Text(
              DhikrStrings.completedCycles(_item.totalCompleted),
              style: TextStyle(
                fontSize: 12,
                color: p.textLight,
              ),
            ),
          ],
          if (_item.sourceUrl != null && _item.sourceUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(dhikrProvider.notifier).openUrl(_item.sourceUrl!),
              icon: const Icon(AppIcons.externalLink, size: 16),
              label: const Text(DhikrStrings.openVideoButton),
            ),
          ],
        ],
      ),
    );
  }
}
