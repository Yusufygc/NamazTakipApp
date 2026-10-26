import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/text_utils.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

/// Elle şehir seçimi (GPS kullanılmak istenmediğinde).
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final current = ref.watch(settingsProvider).manualLocation;
    final allCities = ref.watch(citiesProvider);
    final q = foldTurkish(_query.trim());
    final cities = [
      for (final c in allCities)
        if (q.isEmpty || foldTurkish(c.city).contains(q)) c,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(LocationStrings.cityPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: Icon(AppIcons.search, color: p.primary),
                hintText: LocationStrings.citySearchHint,
                filled: true,
                fillColor: p.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: p.primary.withValues(alpha: 0.16),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: p.primary.withValues(alpha: 0.16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: p.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: cities.length,
              itemBuilder: (context, i) {
                final c = cities[i];
                final selected = current?.city == c.city;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: selected
                      ? Color.alphaBlend(
                          p.primary.withValues(alpha: 0.10),
                          p.card,
                        )
                      : p.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: selected
                          ? p.primary
                          : p.primary.withValues(alpha: 0.08),
                      width: selected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      AppIcons.location,
                      color: selected ? p.primary : p.textLight,
                      size: 20,
                    ),
                    title: Text(
                      c.city,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    trailing: selected
                        ? Icon(AppIcons.selected, color: p.primary)
                        : null,
                    onTap: () async {
                      await ref
                          .read(settingsProvider.notifier)
                          .useManualLocation(c);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
