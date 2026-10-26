import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return ref.watch(gamificationProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(CommonStrings.error(e))),
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _StatTile(
                      label: GamificationStrings.currentStreak,
                      value: data.streaks.currentStreak,
                      icon: AppIcons.streakCurrent),
                  const SizedBox(width: 10),
                  _StatTile(
                      label: GamificationStrings.bestStreak,
                      value: data.streaks.bestStreak,
                      icon: AppIcons.streakBest),
                  const SizedBox(width: 10),
                  _StatTile(
                      label: GamificationStrings.fullDays,
                      value: data.streaks.totalFullDays,
                      icon: AppIcons.streakDays),
                ],
              ),
              const SizedBox(height: 20),
              Text(GamificationStrings.badgesHeader,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: p.textLight)),
              const SizedBox(height: 8),
              for (final a in data.achievements) _AchievementCard(a),
            ],
          ),
        );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Card(
        color: p.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: p.primary),
              const SizedBox(height: 4),
              Text('$value',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: p.primary)),
              Text(label, style: TextStyle(fontSize: 12, color: p.textLight)),
            ],
          ),
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
    return Opacity(
      opacity: a.isUnlocked ? 1 : 0.7,
      child: Card(
        color: a.isUnlocked
            ? Color.alphaBlend(p.secondary.withValues(alpha: 0.25), p.card)
            : p.card,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: a.isUnlocked ? BorderSide(color: p.secondary) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                a.isUnlocked ? AppIcons.achievement(a.id) : AppIcons.locked,
                size: 36,
                color: a.isUnlocked ? p.dark : p.textLight,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(GamificationStrings.achievementTitle(a.id),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(GamificationStrings.achievementDescription(a.id),
                        style: TextStyle(color: p.textLight, fontSize: 13)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: a.progress / a.target,
                        minHeight: 8,
                        color: p.primary,
                        backgroundColor: p.dark.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(GamificationStrings.progress(a.progress, a.target),
                        style: TextStyle(fontSize: 12, color: p.textLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
