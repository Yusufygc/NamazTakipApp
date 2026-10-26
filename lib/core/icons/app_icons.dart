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

  // ---- Gezinme (alt çubuk ve üst bar) -----------------------------------------
  static const IconData navHome = Icons.mosque_outlined;
  static const IconData navHomeSelected = Icons.mosque;
  static const IconData navBadges = Icons.workspace_premium_outlined;
  static const IconData navBadgesSelected = Icons.workspace_premium;
  static const IconData navQaza = Icons.history_edu_outlined;
  static const IconData navQazaSelected = Icons.history_edu;
  static const IconData navStats = Icons.insights_outlined;
  static const IconData navStatsSelected = Icons.insights;
  static const IconData navSettings = Icons.tune_outlined;
  static const IconData navSettingsSelected = Icons.tune;
  static const IconData navAbout = Icons.info_outline;
  static const IconData navDhikr = Icons.auto_awesome_outlined;

  // ---- Vakit kartı ve ana ekran ------------------------------------------------
  static const IconData sunrise = Icons.wb_sunny_outlined;
  static const IconData prayerNext = Icons.schedule_rounded;
  static const IconData prayerPerformed = Icons.check_rounded;
  static const IconData prayerMissed = Icons.close_rounded;
  static const IconData prayerPending = Icons.radio_button_unchecked_rounded;
  static const IconData location = Icons.place_outlined;
  static const IconData locationDetect = Icons.my_location_rounded;
  static const IconData city = Icons.location_city_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData selected = Icons.check_circle_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData notifications = Icons.notifications_active_outlined;
  static const IconData timer = Icons.timer_outlined;
  static const IconData compass = Icons.explore_outlined;

  /// Vakit türüne göre atmosfer ikonu.
  static IconData prayerIcon(PrayerType prayer) {
    switch (prayer) {
      case PrayerType.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerType.dhuhr:
        return Icons.light_mode_rounded;
      case PrayerType.asr:
        return Icons.wb_sunny_outlined;
      case PrayerType.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerType.isha:
        return Icons.bedtime_outlined;
    }
  }

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

  // ---- Zikir & Tesbihat --------------------------------------------------------------
  static const IconData dhikr = Icons.grain_rounded;
  static const IconData share = Icons.ios_share_rounded;
  static const IconData paste = Icons.content_paste_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData favorite = Icons.bookmark_rounded;
  static const IconData favoriteBorder = Icons.bookmark_border_rounded;
  static const IconData externalLink = Icons.open_in_new_rounded;
  static const IconData reset = Icons.restart_alt_rounded;
  static const IconData sparkle = Icons.auto_awesome_rounded;
  static const IconData folder = Icons.folder_outlined;
  static const IconData key = Icons.vpn_key_outlined;
  static const IconData touch = Icons.touch_app_rounded;

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
