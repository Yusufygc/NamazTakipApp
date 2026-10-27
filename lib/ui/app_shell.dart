import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/icons/app_icons.dart';
import '../core/strings/strings.dart';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';
import 'screens/about_screen.dart';
import 'screens/city_picker_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/gamification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qaza_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/dhikr_counter_sheet.dart';
import 'widgets/dhikr_editor_sheet.dart';
import 'widgets/islamic_pattern.dart';
import 'widgets/qibla_compass_sheet.dart';

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

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  StreamSubscription<String>? _shareSub;

  @override
  void initState() {
    super.initState();
    final dhikrNotifier = ref.read(dhikrProvider.notifier);
    _shareSub = dhikrNotifier.sharedTexts.listen(_handleSharedText);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialShared = await dhikrNotifier.takeInitialSharedText();
      if (initialShared != null && initialShared.isNotEmpty && mounted) {
        await _handleSharedText(initialShared);
      }
    });
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  Future<void> _handleSharedText(String sharedText) async {
    if (!mounted) return;
    final saved = await showDhikrEditorSheet(
      context,
      initialSharedText: sharedText,
      startWithScraper: true,
    );
    if (saved != null && mounted) {
      await showDhikrCounterSheet(context, saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(selectedDestinationProvider);
    final current = _destinations[index];
    final p = context.palette;
    final location = ref.watch(settingsProvider.select((s) => s.location));
    final qazaCount = ref.watch(
      qazaProvider.select((async) => async.value?.length ?? 0),
    );
    final qazaBacklog = ref.watch(
      qazaDebtProvider.select((plan) => plan.totalBacklog),
    );
    final totalQazaBadge = qazaCount + qazaBacklog;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            SeljukMedallion(
              size: 32,
              fillColor: p.primary.withValues(alpha: p.isDark ? 0.22 : 0.12),
              borderColor: p.secondary.withValues(alpha: 0.65),
              child: Icon(AppIcons.app, size: 16, color: p.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                current.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        actions: [
          if (index == 0 && location != null)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: ActionChip(
                visualDensity:
                    const VisualDensity(horizontal: -3, vertical: -3),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                labelPadding: const EdgeInsets.only(right: 4),
                avatar: Icon(AppIcons.location, size: 13, color: p.primary),
                label: Text(
                  location.city,
                  style: TextStyle(
                    fontSize: 11,
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
          if (index == 0)
            IconButton(
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: HomeStrings.qiblaButton,
              icon: Icon(AppIcons.compass, size: 20, color: p.primary),
              onPressed: () => showQiblaCompassSheet(context),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: ActionChip(
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              labelPadding: const EdgeInsets.only(right: 4),
              avatar: Icon(AppIcons.navDhikr, size: 14, color: p.secondary),
              label: Text(
                DhikrStrings.topBarButton,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
              backgroundColor: p.card,
              side: BorderSide(color: p.secondary.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DhikrScreen(),
                ),
              ),
            ),
          ),
          IconButton(
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: NavStrings.about,
            icon: Icon(AppIcons.navAbout, size: 20, color: p.textLight),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text(NavStrings.about)),
                  body: const AboutScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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
                icon: _buildNavIcon(
                    _destinations[i].icon, i == 1 ? totalQazaBadge : 0, p),
                selectedIcon: _buildNavIcon(
                    _destinations[i].selectedIcon,
                    i == 1 ? totalQazaBadge : 0,
                    p),
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
