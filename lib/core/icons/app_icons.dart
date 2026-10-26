import 'package:flutter/material.dart';

import 'package:namaz_backend/namaz_backend.dart';

/// Uygulamanın tüm ikonları tek yerde. Ekranlarda `Icons.xxx` veya emoji
/// kullanılmaz; anlamsal ad üzerinden bu sınıfa başvurulur. Bir ikonu
/// değiştirmek için yalnızca burayı düzenlemek yeterlidir.
abstract final class AppIcons {
  // ---- Marka ----------------------------------------------------------------
  static const IconData app = Icons.mosque;

  // ---- Durum ve uyarı ---------------------------------------------------------
  static const IconData error = Icons.error_outline;
  static const IconData retry = Icons.refresh;
  static const IconData warning = Icons.warning_amber_rounded;

  // ---- Gezinme (çekmece) ------------------------------------------------------
  static const IconData navHome = Icons.home_outlined;
  static const IconData navBadges = Icons.emoji_events_outlined;
  static const IconData navQaza = Icons.event_busy_outlined;
  static const IconData navStats = Icons.insights_outlined;
  static const IconData navSettings = Icons.settings_outlined;
  static const IconData navAbout = Icons.info_outline;

  // ---- Vakit kartı ve ana ekran ------------------------------------------------
  static const IconData sunrise = Icons.wb_sunny;
  static const IconData prayerNext = Icons.hourglass_top;
  static const IconData prayerPerformed = Icons.check;
  static const IconData prayerMissed = Icons.close;
  static const IconData location = Icons.location_on;
  static const IconData locationDetect = Icons.my_location;
  static const IconData city = Icons.location_city;
  static const IconData search = Icons.search;
  static const IconData selected = Icons.check_circle;

  // ---- Namaz diyaloğu -----------------------------------------------------------
  static const IconData dialogHeader = Icons.mosque;
  static const IconData confirmPerformed = Icons.check;
  static const IconData confirmMissed = Icons.close;

  // ---- Kaza -----------------------------------------------------------------------
  static const IconData qazaItem = Icons.cancel;
  static const IconData qazaEmpty = Icons.celebration;
  static const IconData expand = Icons.expand_more;

  // ---- Süreç ----------------------------------------------------------------------
  static const IconData statsRadar = Icons.radar;
  static const IconData statsHeatmap = Icons.grid_view;
  static const IconData statsCompare = Icons.compare_arrows;
  static const IconData weekCurrent = Icons.calendar_view_week;
  static const IconData weekPrevious = Icons.history;
  static const IconData trendUp = Icons.trending_up;
  static const IconData trendDown = Icons.trending_down;
  static const IconData trendFlat = Icons.trending_flat;
  static const IconData monthPrevious = Icons.chevron_left;
  static const IconData monthNext = Icons.chevron_right;

  // ---- Seri ve rozetler --------------------------------------------------------------
  static const IconData streakCurrent = Icons.local_fire_department;
  static const IconData streakBest = Icons.emoji_events;
  static const IconData streakDays = Icons.calendar_month;
  static const IconData locked = Icons.lock;

  static IconData achievement(AchievementId id) {
    switch (id) {
      case AchievementId.firstWeek:
        return Icons.check_circle;
      case AchievementId.monthCompleter:
        return Icons.local_fire_department;
      case AchievementId.hundredDays:
        return Icons.diamond;
      case AchievementId.congregationFriendly:
        return Icons.groups;
      case AchievementId.morningHero:
        return Icons.wb_twilight;
    }
  }

  // ---- Ayarlar -----------------------------------------------------------------------
  static const IconData congregation = Icons.groups;

  /// Tema anahtarına göre tema ikonu (`default`, `dark`, `ocean`, `rose`, `gold`).
  static IconData theme(String key) {
    switch (key) {
      case 'dark':
        return Icons.dark_mode;
      case 'ocean':
        return Icons.waves;
      case 'rose':
        return Icons.local_florist;
      case 'gold':
        return Icons.auto_awesome;
      default:
        return Icons.eco;
    }
  }

  // ---- Hakkında ------------------------------------------------------------------------
  static const IconData aboutLocation = Icons.location_on;
  static const IconData aboutTracking = Icons.check_circle;
  static const IconData aboutQaza = Icons.event_busy;
  static const IconData aboutStats = Icons.insights;
  static const IconData aboutBadges = Icons.military_tech;
  static const IconData aboutThemes = Icons.palette;
  static const IconData tip = Icons.push_pin;
  static const IconData dua = Icons.volunteer_activism;
}
