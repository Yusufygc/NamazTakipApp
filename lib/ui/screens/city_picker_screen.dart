import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../data/turkish_cities.dart';
import '../../providers/providers.dart';

/// Elle şehir seçimi (GPS kullanılmak istenmediğinde).
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _query = '';

  // Türkçe büyük/küçük harf farkını (I/ı, İ/i) yok sayan basit eşleştirme.
  String _norm(String s) => s
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('â', 'a');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final current = ref.watch(settingsProvider).manualLocation;
    final q = _norm(_query.trim());
    final cities = [
      for (final c in kTurkishCities)
        if (q.isEmpty || _norm(c.city).contains(q)) c,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Şehir Seç')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Şehir ara',
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
                  trailing: selected ? Icon(Icons.check_circle, color: p.primary) : null,
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
