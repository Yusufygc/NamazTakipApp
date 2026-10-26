import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/text_utils.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'city_picker_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(
            turkishUpper(title),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: p.textLight,
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        section(SettingsStrings.sectionNotifications),
        Card(
          color: p.card,
          child: Column(
            children: [
              SwitchListTile(
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.notifications,
                    color: p.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  SettingsStrings.notifications,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  SettingsStrings.notificationsSubtitle,
                  style: TextStyle(fontSize: 13, color: p.textLight),
                ),
                value: s.notificationsEnabled,
                onChanged: notifier.setNotifications,
              ),
              Divider(height: 1, color: p.primary.withValues(alpha: 0.10)),
              ListTile(
                enabled: s.notificationsEnabled,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(AppIcons.timer, color: p.primary, size: 20),
                ),
                title: const Text(
                  SettingsStrings.reminderDelay,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  SettingsStrings.reminderDelaySubtitle,
                  style: TextStyle(fontSize: 13, color: p.textLight),
                ),
                trailing: DropdownButton<int>(
                  value: s.reminderMinutes,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(14),
                  items: [
                    for (final m in [5, 10, 15, 20, 30, 45, 60])
                      DropdownMenuItem(
                        value: m,
                        child: Text(
                          SettingsStrings.minutes(m),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                  onChanged: s.notificationsEnabled
                      ? (v) => v == null ? null : notifier.setReminderMinutes(v)
                      : null,
                ),
              ),
            ],
          ),
        ),
        section(SettingsStrings.sectionLocation),
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
                      title: Text(
                        SettingsStrings.locationAuto,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    RadioListTile<LocationMode>(
                      value: LocationMode.manual,
                      title: const Text(
                        SettingsStrings.locationManual,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: s.manualLocation == null
                          ? null
                          : Text(s.manualLocation!.city),
                      secondary: IconButton(
                        icon: Icon(AppIcons.city, color: p.primary),
                        onPressed: () => _pickCity(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (s.location != null) ...[
                Divider(height: 1, color: p.primary.withValues(alpha: 0.10)),
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: p.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(AppIcons.location, color: p.primary, size: 20),
                  ),
                  title: Text(
                    s.location!.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    SettingsStrings.locationInUse,
                    style: TextStyle(fontSize: 12, color: p.textLight),
                  ),
                ),
              ],
              Divider(height: 1, color: p.primary.withValues(alpha: 0.10)),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(AppIcons.compass, color: p.primary, size: 20),
                ),
                title: const Text(
                  SettingsStrings.calcMethod,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DropdownButton<CalcMethod>(
                    isExpanded: true,
                    value: s.calcMethod,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(14),
                    items: [
                      for (final m in CalcMethod.values)
                        DropdownMenuItem(
                          value: m,
                          child: Text(
                            m.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                    onChanged: (m) =>
                        m == null ? null : notifier.setCalcMethod(m),
                  ),
                ),
              ),
            ],
          ),
        ),
        section(SettingsStrings.sectionDhikrAi),
        Card(
          color: p.card,
          child: ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(AppIcons.key, color: p.primary, size: 20),
            ),
            title: const Text(
              SettingsStrings.geminiKeyTitle,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              s.hasGeminiApiKey
                  ? SettingsStrings.geminiKeyConfigured
                  : SettingsStrings.geminiKeyNotConfigured,
              style: TextStyle(fontSize: 12.5, color: p.textLight),
            ),
            trailing: Icon(AppIcons.chevronRight, color: p.textLight),
            onTap: () => _showGeminiKeyDialog(context, notifier),
          ),
        ),
        section(SettingsStrings.sectionTheme),
        Column(
          children: [
            for (final t in kThemes)
              _ThemeCard(
                def: t,
                selected: t.key == s.themeKey,
                onTap: () => notifier.setTheme(t.key),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            CommonStrings.footer,
            style: TextStyle(color: p.textLight, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _pickCity(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()),
      );

  Future<void> _showGeminiKeyDialog(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final controller = TextEditingController();
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(SettingsStrings.geminiDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: SettingsStrings.geminiDialogHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              SettingsStrings.geminiDialogHelper,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('clear'),
            child: const Text(SettingsStrings.geminiClear),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text(SettingsStrings.geminiSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (action == null) return;
    if (action == 'clear') {
      await notifier.setGeminiApiKey(null);
    } else {
      await notifier.setGeminiApiKey(action);
    }
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.def,
    required this.selected,
    required this.onTap,
  });

  final AppThemeDef def;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = def.palette;
    final name = SettingsStrings.themeName(def.key);
    final subtitle = SettingsStrings.themeSubtitle(def.key);

    return Semantics(
      button: true,
      selected: selected,
      label: SettingsStrings.themeSemantics(name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          color: pal.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: selected
                  ? pal.primary
                  : pal.primary.withValues(alpha: 0.22),
              width: selected ? 2.2 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: pal.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pal.secondary.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Icon(
                      AppIcons.theme(def.key),
                      size: 20,
                      color: pal.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: pal.text,
                            fontSize: 15,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: pal.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in [
                        pal.primary,
                        pal.secondary,
                        pal.accent,
                        pal.background,
                      ])
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: pal.text.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    selected ? AppIcons.selected : AppIcons.prayerPending,
                    color: selected
                        ? pal.primary
                        : pal.textLight.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
