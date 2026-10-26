import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/icons/app_icons.dart';
import '../core/strings/strings.dart';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';
import 'screens/about_screen.dart';
import 'screens/city_picker_screen.dart';
import 'screens/gamification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qaza_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/islamic_pattern.dart';

final selectedDestinationProvider =
    NotifierProvider<_SelectedDestination, int>(_SelectedDestination.new);

class _SelectedDestination extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

class _Destination {
  const _Destination({
    required this.title,
    required this.tabLabel,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String title;
  final String tabLabel;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() builder;
}

final List<_Destination> _destinations = [
  _Destination(
    title: NavStrings.home,
    tabLabel: NavStrings.tabHome,
    icon: AppIcons.navHome,
    selectedIcon: AppIcons.navHomeSelected,
    builder: () => const HomeScreen(),
  ),
  _Destination(
    title: NavStrings.qaza,
    tabLabel: NavStrings.tabQaza,
    icon: AppIcons.navQaza,
    selectedIcon: AppIcons.navQazaSelected,
    builder: () => const QazaScreen(),
  ),
  _Destination(
    title: NavStrings.stats,
    tabLabel: NavStrings.tabStats,
    icon: AppIcons.navStats,
    selectedIcon: AppIcons.navStatsSelected,
    builder: () => const StatsScreen(),
  ),
  _Destination(
    title: NavStrings.badges,
    tabLabel: NavStrings.tabBadges,
    icon: AppIcons.navBadges,
    selectedIcon: AppIcons.navBadgesSelected,
    builder: () => const GamificationScreen(),
  ),
  _Destination(
    title: NavStrings.settings,
    tabLabel: NavStrings.tabSettings,
    icon: AppIcons.navSettings,
    selectedIcon: AppIcons.navSettingsSelected,
    builder: () => const SettingsScreen(),
  ),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedDestinationProvider);
    final current = _destinations[index];
    final p = context.palette;
    final location = ref.watch(settingsProvider.select((s) => s.location));
    final qazaCount = ref.watch(
      qazaProvider.select((async) => async.value?.length ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            SeljukMedallion(
              size: 36,
              fillColor: p.primary.withValues(alpha: p.isDark ? 0.22 : 0.12),
              borderColor: p.secondary.withValues(alpha: 0.65),
              child: Icon(AppIcons.app, size: 18, color: p.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                current.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (index == 0 && location != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ActionChip(
                avatar: Icon(AppIcons.location, size: 16, color: p.primary),
                label: Text(
                  location.city,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                backgroundColor: p.card,
                side: BorderSide(color: p.primary.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CityPickerScreen(),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: NavStrings.about,
            icon: Icon(AppIcons.navAbout, color: p.textLight),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text(NavStrings.about)),
                  body: const AboutScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: current.builder(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: p.primary.withValues(alpha: p.isDark ? 0.20 : 0.10),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) =>
              ref.read(selectedDestinationProvider.notifier).select(i),
          destinations: [
            for (var i = 0; i < _destinations.length; i++)
              NavigationDestination(
                icon: _buildNavIcon(_destinations[i].icon, i == 1 ? qazaCount : 0, p),
                selectedIcon: _buildNavIcon(
                    _destinations[i].selectedIcon, i == 1 ? qazaCount : 0, p),
                label: _destinations[i].tabLabel,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int badgeCount, AppPalette p) {
    if (badgeCount <= 0) return Icon(icon);
    return Badge(
      backgroundColor: p.danger,
      textColor: Colors.white,
      label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
      child: Icon(icon),
    );
  }
}
