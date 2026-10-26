import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../data/turkish_cities.dart';
import '../../providers/providers.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/text_utils.dart';

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
    final q = foldTurkish(_query.trim());
    final cities = [
      for (final c in kTurkishCities)
        if (q.isEmpty || foldTurkish(c.city).contains(q)) c,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(LocationStrings.cityPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(AppIcons.search),
                hintText: LocationStrings.citySearchHint,
                filled: true,
                fillColor: p.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, i) {
                final c = cities[i];
                final selected = current?.city == c.city;
                return ListTile(
                  title: Text(c.city),
                  trailing: selected ? Icon(AppIcons.selected, color: p.primary) : null,
                  onTap: () async {
                    await ref.read(settingsProvider.notifier).useManualLocation(c);
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
