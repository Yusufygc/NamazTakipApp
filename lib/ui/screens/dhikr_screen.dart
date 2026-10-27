import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/text_utils.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/classic_tesbihat_sheet.dart';
import '../widgets/dhikr_card.dart';
import '../widgets/dhikr_counter_sheet.dart';
import '../widgets/dhikr_editor_sheet.dart';
import '../widgets/esma_catalog_sheet.dart';
import '../widgets/islamic_pattern.dart';

class DhikrScreen extends ConsumerStatefulWidget {
  const DhikrScreen({super.key, this.initialFilterPrayer});

  final PrayerType? initialFilterPrayer;

  @override
  ConsumerState<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends ConsumerState<DhikrScreen> {
  String _selectedGroup = DhikrStrings.allGroups;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> _buildGroupTabs(List<DhikrItem> items) {
    final customGroups = <String>{
      ...DhikrGroups.defaults,
      for (final item in items) item.groupName,
    };
    return [
      DhikrStrings.allGroups,
      DhikrStrings.favoritesGroup,
      ...customGroups,
    ];
  }

  List<DhikrItem> _filterItems(List<DhikrItem> all) {
    final q = foldTurkish(_searchQuery.trim());
    return all.where((item) {
      if (_selectedGroup == DhikrStrings.favoritesGroup && !item.isFavorite) {
        return false;
      } else if (_selectedGroup != DhikrStrings.allGroups &&
          _selectedGroup != DhikrStrings.favoritesGroup &&
          item.groupName != _selectedGroup) {
        return false;
      }
      if (q.isEmpty) return true;
      final hay = foldTurkish(
        '${item.title} ${item.transliteration} ${item.meaning} ${item.groupName}',
      );
      return hay.contains(q);
    }).toList();
  }

  Future<void> _confirmDelete(DhikrItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DhikrStrings.deleteConfirmTitle),
        content: const Text(DhikrStrings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(DhikrStrings.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(dhikrProvider.notifier).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final borderColor = p.primary.withValues(alpha: p.isDark ? 0.22 : 0.12);
    final dhikrsAsync = ref.watch(dhikrProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Row(
          children: [
            SeljukMedallion(
              size: 34,
              fillColor: p.primary.withValues(alpha: p.isDark ? 0.22 : 0.12),
              borderColor: p.secondary.withValues(alpha: 0.65),
              child: Icon(AppIcons.dhikr, color: p.primary, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              DhikrStrings.screenTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: p.text,
              ),
            ),
          ],
        ),
      ),
      body: dhikrsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (allItems) {
          final groups = _buildGroupTabs(allItems);
          final filtered = _filterItems(allItems);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _SocialScraperBanner(
                palette: p,
                onScrapeTap: () => showDhikrEditorSheet(
                  context,
                  startWithScraper: true,
                ),
                onManualAddTap: () => showDhikrEditorSheet(
                  context,
                  startWithScraper: false,
                ),
                onClassicTesbihatTap: () => showClassicTesbihatSheet(context),
                onEsmaCatalogTap: () => showEsmaCatalogSheet(context),
              ),
              const SizedBox(height: 12),
              // Arama çubuğu
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: DhikrStrings.searchHint,
                  prefixIcon: Icon(AppIcons.search, color: p.textLight),
                  filled: true,
                  fillColor: p.card,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Grup filtre çipleri
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final g = groups[idx];
                    final selected = _selectedGroup == g;
                    return ChoiceChip(
                      label: Text(
                        g,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedGroup = g),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                _EmptyDhikrView(palette: p)
              else
                for (final item in filtered) ...[
                  DhikrCard(
                    item: item,
                    palette: p,
                    onOpenCounter: () => showDhikrCounterSheet(context, item),
                    onEdit: () =>
                        showDhikrEditorSheet(context, existingItem: item),
                    onDelete: () => _confirmDelete(item),
                    onToggleFavorite: () =>
                        ref.read(dhikrProvider.notifier).toggleFavorite(item),
                    onOpenVideo: item.sourceUrl == null
                        ? null
                        : () => ref
                            .read(dhikrProvider.notifier)
                            .openUrl(item.sourceUrl!),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _SocialScraperBanner extends StatelessWidget {
  const _SocialScraperBanner({
    required this.palette,
    required this.onScrapeTap,
    required this.onManualAddTap,
    required this.onClassicTesbihatTap,
    required this.onEsmaCatalogTap,
  });

  final AppPalette palette;
  final VoidCallback onScrapeTap;
  final VoidCallback onManualAddTap;
  final VoidCallback onClassicTesbihatTap;
  final VoidCallback onEsmaCatalogTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.primary, palette.dark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.secondary.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: MihrabArchBackdrop(
        lineColor: Colors.white.withValues(alpha: 0.10),
        accentColor: palette.secondary.withValues(alpha: 0.22),
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(AppIcons.sparkle, color: palette.secondary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      DhikrStrings.socialBannerTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DhikrStrings.socialBannerSubtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.secondary,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onScrapeTap,
                      icon: const Icon(AppIcons.paste, size: 17),
                      label: const Text(
                        DhikrStrings.pasteLinkButton,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: onManualAddTap,
                    icon: const Icon(AppIcons.add, size: 17),
                    label: const Text(
                      DhikrStrings.manualAddButton,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                        side: BorderSide(
                          color: palette.secondary.withValues(alpha: 0.55),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onPressed: onClassicTesbihatTap,
                      icon: Icon(
                        AppIcons.dhikr,
                        size: 16,
                        color: palette.secondary,
                      ),
                      label: const Text(
                        DhikrStrings.classicTesbihatButton,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                        side: BorderSide(
                          color: palette.secondary.withValues(alpha: 0.55),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onPressed: onEsmaCatalogTap,
                      icon: Icon(
                        AppIcons.sparkle,
                        size: 16,
                        color: palette.secondary,
                      ),
                      label: const Text(
                        DhikrStrings.esmaCatalogButton,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDhikrView extends StatelessWidget {
  const _EmptyDhikrView({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        children: [
          Icon(AppIcons.dhikr, size: 40, color: palette.secondary),
          const SizedBox(height: 10),
          Text(
            DhikrStrings.emptyListTitle,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DhikrStrings.emptyListBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: palette.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
