import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../data/settings_repository.dart';
import '../../providers/providers.dart';
import '../../services/prayer_time_service.dart';
import 'city_picker_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: p.textLight)),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        section('Bildirimler'),
        Card(
          color: p.card,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Bildirimler'),
                subtitle: const Text('Ezan vakti ve "kıldın mı" hatırlatmaları'),
                value: s.notificationsEnabled,
                onChanged: notifier.setNotifications,
              ),
              ListTile(
                enabled: s.notificationsEnabled,
                title: const Text('Hatırlatma süresi'),
                subtitle: const Text('Ezandan kaç dakika sonra'),
                trailing: DropdownButton<int>(
                  value: s.reminderMinutes,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final m in [5, 10, 15, 20, 30, 45, 60])
                      DropdownMenuItem(value: m, child: Text('$m dk')),
                  ],
                  onChanged: s.notificationsEnabled
                      ? (v) => v == null ? null : notifier.setReminderMinutes(v)
                      : null,
                ),
              ),
            ],
          ),
        ),
        section('Konum ve Vakitler'),
        Card(
          color: p.card,
          child: Column(
            children: [
              RadioGroup<LocationMode>(
                groupValue: s.locationMode,
                onChanged: (m) {
                  if (m == LocationMode.auto) {
                    notifier.useAutoLocation();
                    ref.invalidate(locationRefreshProvider);
                  } else if (m == LocationMode.manual) {
                    _pickCity(context);
                  }
                },
                child: Column(
                  children: [
                    const RadioListTile<LocationMode>(
                      value: LocationMode.auto,
                      title: Text('Otomatik (GPS)'),
                    ),
                    RadioListTile<LocationMode>(
                      value: LocationMode.manual,
                      title: const Text('Elle şehir seç'),
                      subtitle: s.manualLocation == null
                          ? null
                          : Text(s.manualLocation!.city),
                    ),
                  ],
                ),
              ),
              if (s.location != null)
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(s.location!.label),
                  subtitle: const Text('Vakit hesabında kullanılan konum'),
                ),
              ListTile(
                title: const Text('Hesaplama yöntemi'),
                trailing: DropdownButton<CalcMethod>(
                  value: s.calcMethod,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final m in CalcMethod.values)
                      DropdownMenuItem(value: m, child: Text(m.trName)),
                  ],
                  onChanged: (m) => m == null ? null : notifier.setCalcMethod(m),
                ),
              ),
            ],
          ),
        ),
        section('Tema'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in kThemes)
              _ThemeChip(
                def: t,
                selected: t.key == s.themeKey,
                onTap: () => notifier.setTheme(t.key),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: Text('Versiyon 1.0.0  •  Geliştirici: MYY',
              style: TextStyle(color: p.textLight, fontSize: 12)),
        ),
      ],
    );
  }

  void _pickCity(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()),
      );
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({required this.def, required this.selected, required this.onTap});

  final AppThemeDef def;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = def.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Tema: ${def.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pal.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? pal.primary : pal.dark.withValues(alpha: 0.25),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in [pal.primary, pal.secondary, pal.accent, pal.dark])
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${def.icon} ${def.name}',
                  style: TextStyle(
                      color: pal.text,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
