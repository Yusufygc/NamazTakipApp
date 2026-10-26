import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import 'screens/about_screen.dart';
import 'screens/gamification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qaza_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';

class _Destination {
  const _Destination(this.title, this.icon, this.builder);

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<_Destination> _destinations = [
  _Destination('Namaz Takip', Icons.home_outlined, (_) => const HomeScreen()),
  _Destination('Rozetler & Seri', Icons.emoji_events_outlined, (_) => const GamificationScreen()),
  _Destination('Kaza Namazları', Icons.event_busy_outlined, (_) => const QazaScreen()),
  _Destination('Süreç', Icons.insights_outlined, (_) => const StatsScreen()),
  _Destination('Ayarlar', Icons.settings_outlined, (_) => const SettingsScreen()),
  _Destination('Hakkında', Icons.info_outline, (_) => const AboutScreen()),
];

final selectedDestinationProvider =
    NotifierProvider<_SelectedDestination, int>(_SelectedDestination.new);

class _SelectedDestination extends Notifier<int> {
  @override
  int build() => 0;

  void select(int i) => state = i;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final index = ref.watch(selectedDestinationProvider);
    final dest = _destinations[index];

    return Scaffold(
      appBar: AppBar(title: Text(dest.title)),
      drawer: NavigationDrawer(
        backgroundColor: p.background,
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(selectedDestinationProvider.notifier).select(i);
          Navigator.of(context).pop();
        },
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.paddingOf(context).top + 16, 20, 18),
            margin: const EdgeInsets.only(bottom: 8),
            color: p.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Namaz Takip',
                    style: TextStyle(
                        color: p.isDark ? p.text : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Text('🕌', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
          for (final d in _destinations)
            NavigationDrawerDestination(icon: Icon(d.icon), label: Text(d.title)),
        ],
      ),
      body: SafeArea(top: false, child: dest.builder(context)),
    );
  }
}
