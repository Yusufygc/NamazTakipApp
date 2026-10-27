import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/text_utils.dart';
import '../../core/content/dhikr_catalog.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'dhikr_counter_sheet.dart';
import 'islamic_pattern.dart';

Future<void> showEsmaCatalogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EsmaCatalogSheet(),
  );
}

class _EsmaCatalogSheet extends ConsumerStatefulWidget {
  const _EsmaCatalogSheet();

  @override
  ConsumerState<_EsmaCatalogSheet> createState() => _EsmaCatalogSheetState();
}

class _EsmaCatalogSheetState extends ConsumerState<_EsmaCatalogSheet> {
  String _query = '';

  List<DhikrCatalogEntry> get _filtered {
    final q = foldTurkish(_query.trim());
    if (q.isEmpty) return kEsmaAndDhikrCatalog;
    return kEsmaAndDhikrCatalog.where((e) {
      final hay = foldTurkish(
        '${e.title} ${e.transliteration} ${e.meaning} ${e.groupName}',
      );
      return hay.contains(q);
    }).toList();
  }

  Future<void> _addAndStart(DhikrCatalogEntry entry) async {
    final saved = await ref
        .read(dhikrProvider.notifier)
        .saveDraft(
          DhikrDraft(
            title: entry.title,
            arabic: entry.arabic,
            transliteration: entry.transliteration,
            meaning: entry.meaning,
            targetCount: entry.defaultCount,
            groupName: entry.groupName,
            prayerTime: entry.prayerTime,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(DhikrStrings.esmaAddSuccess(entry.title)),
      ),
    );
    Navigator.of(context).pop();
    await showDhikrCounterSheet(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: p.secondary.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: p.textLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 12, 8),
                child: Row(
                  children: [
                    SeljukMedallion(
                      size: 36,
                      fillColor: p.primary.withValues(alpha: 0.14),
                      borderColor: p.secondary,
                      child: Icon(AppIcons.sparkle, size: 18, color: p.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DhikrStrings.esmaCatalogTitle,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(AppIcons.confirmMissed, color: p.textLight),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: DhikrStrings.searchHint,
                    prefixIcon: Icon(AppIcons.search, color: p.textLight),
                    filled: true,
                    fillColor: p.card,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: p.primary.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, idx) {
                    final e = items[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: p.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.title,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                e.arabic,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: p.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.meaning,
                            style: TextStyle(
                              color: p.textLight,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p.secondary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DhikrStrings.esmaEbcedLabel(e.defaultCount),
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: p.primary,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () => _addAndStart(e),
                                icon: const Icon(AppIcons.add, size: 16),
                                label: const Text(
                                  DhikrStrings.esmaAddedAction,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
