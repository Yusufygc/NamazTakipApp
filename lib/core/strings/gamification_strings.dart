import '../achievements.dart';

/// Seri ve rozetler.
abstract final class GamificationStrings {
  static const currentStreak = 'Güncel Seri';
  static const bestStreak = 'En İyi Seri';
  static const fullDays = 'Tam Gün';
  static const badgesHeader = 'ROZETLER';

  static String progress(int value, int target) => '$value / $target';

  static String achievementTitle(AchievementId id) {
    switch (id) {
      case AchievementId.firstWeek:
        return 'İlk Hafta';
      case AchievementId.monthCompleter:
        return 'Ay Tamamlayıcı';
      case AchievementId.hundredDays:
        return '100 Gün';
      case AchievementId.congregationFriendly:
        return 'Cemaat Dostu';
      case AchievementId.morningHero:
        return 'Sabah Kahramanı';
    }
  }

  static String achievementDescription(AchievementId id) {
    switch (id) {
      case AchievementId.firstWeek:
        return '7 gün üst üste tüm namazlar';
      case AchievementId.monthCompleter:
        return '30 gün tam namaz (Toplam)';
      case AchievementId.hundredDays:
        return '100 gün tam namaz (Toplam)';
      case AchievementId.congregationFriendly:
        return '50 vakit cemaatle namaz';
      case AchievementId.morningHero:
        return '30 sabah namazı';
    }
  }
}
