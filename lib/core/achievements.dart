import 'streaks.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final int progress;
  final int target;

  bool get isUnlocked => progress >= target;
}

/// Rozet tanımları; ilerleme saf veriden hesaplanır.
List<Achievement> buildAchievements({
  required StreakStats streaks,
  required int totalCongregation,
  required int totalFajr,
}) {
  int cap(int v, int max) => v > max ? max : v;
  return [
    Achievement(
      id: 'first_week',
      title: 'İlk Hafta',
      description: '7 gün üst üste tüm namazlar',
      icon: '✅',
      progress: cap(streaks.bestStreak, 7),
      target: 7,
    ),
    Achievement(
      id: 'month_completer',
      title: 'Ay Tamamlayıcı',
      description: '30 gün tam namaz (Toplam)',
      icon: '🔥',
      progress: cap(streaks.totalFullDays, 30),
      target: 30,
    ),
    Achievement(
      id: 'hundred_days',
      title: '100 Gün',
      description: '100 gün tam namaz (Toplam)',
      icon: '💎',
      progress: cap(streaks.totalFullDays, 100),
      target: 100,
    ),
    Achievement(
      id: 'congregation_friendly',
      title: 'Cemaat Dostu',
      description: '50 vakit cemaatle namaz',
      icon: '🕌',
      progress: cap(totalCongregation, 50),
      target: 50,
    ),
    Achievement(
      id: 'morning_hero',
      title: 'Sabah Kahramanı',
      description: '30 sabah namazı',
      icon: '⏰',
      progress: cap(totalFajr, 30),
      target: 30,
    ),
  ];
}
