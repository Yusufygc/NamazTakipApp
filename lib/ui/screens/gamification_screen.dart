import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/islamic_pattern.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return ref.watch(gamificationProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(CommonStrings.error(e))),
          data: (data) {
            final unlocked =
                data.achievements.where((a) => a.isUnlocked).length;
            final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
            final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Üst Seri Özeti Mihrap Kartı
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [startColor, endColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: p.secondary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: MihrabArchBackdrop(
                    borderRadius: 22,
                    lineColor: Colors.white.withValues(alpha: 0.08),
                    accentColor: p.secondary.withValues(alpha: 0.16),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          _StreakPillar(
                            label: GamificationStrings.currentStreak,
                            value: data.streaks.currentStreak,
                            icon: AppIcons.streakCurrent,
                            accent: p.secondary,
                          ),
                          const SizedBox(width: 10),
                          _StreakPillar(
                            label: GamificationStrings.bestStreak,
                            value: data.streaks.bestStreak,
                            icon: AppIcons.streakBest,
                            accent: p.secondary,
                          ),
                          const SizedBox(width: 10),
                          _StreakPillar(
                            label: GamificationStrings.fullDays,
                            value: data.streaks.totalFullDays,
                            icon: AppIcons.streakDays,
                            accent: p.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        GamificationStrings.badgesHeader,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: p.textLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        GamificationStrings.unlockedCount(
                          unlocked,
                          data.achievements.length,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final a in data.achievements) _AchievementCard(a),
              ],
            );
          },
        );
  }
}

class _StreakPillar extends StatelessWidget {
  const _StreakPillar({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: accent),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard(this.a);

  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final unlocked = a.isUnlocked;
    final ratio = (a.progress / a.target).clamp(0.0, 1.0);

    return Card(
      color: unlocked
          ? Color.alphaBlend(
              p.secondary.withValues(alpha: p.isDark ? 0.14 : 0.10),
              p.card,
            )
          : p.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: unlocked
              ? p.secondary
              : p.primary.withValues(alpha: p.isDark ? 0.16 : 0.10),
          width: unlocked ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SeljukMedallion(
              size: 58,
              fillColor: unlocked
                  ? p.secondary.withValues(alpha: p.isDark ? 0.25 : 0.18)
                  : p.textLight.withValues(alpha: 0.10),
              borderColor:
                  unlocked ? p.secondary : p.textLight.withValues(alpha: 0.35),
              child: Icon(
                unlocked ? AppIcons.achievement(a.id) : AppIcons.locked,
                size: 26,
                color: unlocked ? p.primary : p.textLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          GamificationStrings.achievementTitle(a.id),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: unlocked ? p.text : p.textLight,
                          ),
                        ),
                      ),
                      if (unlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.secondary.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            GamificationStrings.unlockedLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    GamificationStrings.achievementDescription(a.id),
                    style: TextStyle(color: p.textLight, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 7,
                            color: unlocked ? p.secondary : p.primary,
                            backgroundColor: p.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        GamificationStrings.progress(a.progress, a.target),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: unlocked ? p.primary : p.textLight,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
