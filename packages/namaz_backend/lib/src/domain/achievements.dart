import 'streaks.dart';

/// Rozet kimlikleri. Başlık, açıklama ve ikon `GamificationStrings` ile
/// `AppIcons` üzerinden bu kimliğe göre çözülür.
enum AchievementId {
  firstWeek,
  monthCompleter,
  hundredDays,
  congregationFriendly,
  morningHero,
}

class Achievement {
  const Achievement({
    required this.id,
    required this.progress,
    required this.target,
  });

  final AchievementId id;
  final int progress;
  final int target;

  bool get isUnlocked => progress >= target;
}

/// Rozet ilerlemesi saf veriden hesaplanır.
List<Achievement> buildAchievements({
  required StreakStats streaks,
  required int totalCongregation,
  required int totalFajr,
}) {
  int cap(int v, int max) => v > max ? max : v;
  return [
    Achievement(
      id: AchievementId.firstWeek,
      progress: cap(streaks.bestStreak, 7),
      target: 7,
    ),
    Achievement(
      id: AchievementId.monthCompleter,
      progress: cap(streaks.totalFullDays, 30),
      target: 30,
    ),
    Achievement(
      id: AchievementId.hundredDays,
      progress: cap(streaks.totalFullDays, 100),
      target: 100,
    ),
    Achievement(
      id: AchievementId.congregationFriendly,
      progress: cap(totalCongregation, 50),
      target: 50,
    ),
    Achievement(
      id: AchievementId.morningHero,
      progress: cap(totalFajr, 30),
      target: 30,
    ),
  ];
}
