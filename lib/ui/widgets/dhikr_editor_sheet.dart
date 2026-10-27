import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

/// Sosyal medya paylaşımından kazınan taslağı önizleme, yeni zikir ekleme veya
/// mevcut zikri düzenleme alt sayfası.
Future<DhikrItem?> showDhikrEditorSheet(
  BuildContext context, {
  DhikrDraft? initialDraft,
  DhikrItem? existingItem,
  bool startWithScraper = false,
  String? initialSharedText,
}) {
  return showModalBottomSheet<DhikrItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DhikrEditorSheet(
      initialDraft: initialDraft,
      existingItem: existingItem,
      startWithScraper: startWithScraper,
      initialSharedText: initialSharedText,
    ),
  );
}

class DhikrEditorSheet extends ConsumerStatefulWidget {
  const DhikrEditorSheet({
    super.key,
    this.initialDraft,
    this.existingItem,
    this.startWithScraper = false,
    this.initialSharedText,
  });

  final DhikrDraft? initialDraft;
  final DhikrItem? existingItem;
  final bool startWithScraper;
  final String? initialSharedText;

  @override
  ConsumerState<DhikrEditorSheet> createState() => _DhikrEditorSheetState();
}

class _DhikrEditorSheetState extends ConsumerState<DhikrEditorSheet> {
  late final TextEditingController _rawInputCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _arabicCtrl;
  late final TextEditingController _transliterationCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _countCtrl;
  late final TextEditingController _groupCtrl;
  late final TextEditingController _sourceUrlCtrl;

  PrayerType? _selectedPrayer;
  bool _analyzing = false;
  bool _wasScraped = false;
  bool _captionMissing = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    final draft = widget.initialDraft;

    _rawInputCtrl = TextEditingController(
      text: widget.initialSharedText ?? draft?.rawCaption ?? '',
    );
    _titleCtrl = TextEditingController(
      text: existing?.title ?? draft?.title ?? '',
    );
    _arabicCtrl = TextEditingController(
      text: existing?.arabic ?? draft?.arabic ?? '',
    );
    _transliterationCtrl = TextEditingController(
      text: existing?.transliteration ?? draft?.transliteration ?? '',
    );
    _meaningCtrl = TextEditingController(
      text: existing?.meaning ?? draft?.meaning ?? '',
    );
    _countCtrl = TextEditingController(
      text: '${existing?.targetCount ?? draft?.targetCount ?? 33}',
    );
    _groupCtrl = TextEditingController(
      text: existing?.groupName ?? draft?.groupName ?? DhikrGroups.general,
    );
    _sourceUrlCtrl = TextEditingController(
      text: existing?.sourceUrl ?? draft?.sourceUrl ?? '',
    );
    _selectedPrayer = existing?.prayerTime ?? draft?.prayerTime;
    _wasScraped = draft != null || widget.initialSharedText != null;

    if (widget.initialSharedText != null &&
        widget.initialSharedText!.trim().isNotEmpty &&
        draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analyzeRawInput();
      });
    }
  }

  @override
  void dispose() {
    _rawInputCtrl.dispose();
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _transliterationCtrl.dispose();
    _meaningCtrl.dispose();
    _countCtrl.dispose();
    _groupCtrl.dispose();
    _sourceUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyzeRawInput() async {
    final raw = _rawInputCtrl.text.trim();
    if (raw.isEmpty) return;
    setState(() => _analyzing = true);
    try {
      final draft = await ref.read(dhikrProvider.notifier).analyzeShared(raw);
      if (!mounted) return;
      setState(() {
        _titleCtrl.text = draft.title;
        _arabicCtrl.text = draft.arabic;
        _transliterationCtrl.text = draft.transliteration;
        _meaningCtrl.text = draft.meaning;
        _countCtrl.text = '${draft.targetCount}';
        _groupCtrl.text = draft.groupName;
        if (draft.sourceUrl != null && draft.sourceUrl!.isNotEmpty) {
          _sourceUrlCtrl.text = draft.sourceUrl!;
        }
        _selectedPrayer = draft.prayerTime;
        _wasScraped = !draft.captionUnavailable;
        _captionMissing = draft.captionUnavailable;
      });
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _applyCatalogEntry(DhikrCatalogEntry entry) {
    setState(() {
      _titleCtrl.text = entry.title;
      _arabicCtrl.text = entry.arabic;
      _transliterationCtrl.text = entry.transliteration;
      _meaningCtrl.text = entry.meaning;
      _countCtrl.text = '${entry.defaultCount}';
      _groupCtrl.text = entry.groupName;
      _selectedPrayer = entry.prayerTime;
    });
  }

  Future<void> _onSave() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final targetCount = int.tryParse(_countCtrl.text.trim()) ?? 33;
    final groupName = _groupCtrl.text.trim().isEmpty
        ? DhikrGroups.general
        : _groupCtrl.text.trim();
    final sourceUrl = _sourceUrlCtrl.text.trim().isEmpty
        ? null
        : _sourceUrlCtrl.text.trim();

    final notifier = ref.read(dhikrProvider.notifier);
    final existing = widget.existingItem;
    if (existing != null) {
      final updated = existing.copyWith(
        title: title,
        arabic: _arabicCtrl.text.trim(),
        transliteration: _transliterationCtrl.text.trim(),
        meaning: _meaningCtrl.text.trim(),
        targetCount: targetCount <= 0 ? 33 : targetCount,
        groupName: groupName,
        prayerTime: _selectedPrayer,
        clearPrayerTime: _selectedPrayer == null,
        sourceUrl: sourceUrl,
        clearSourceUrl: sourceUrl == null,
      );
      await notifier.updateItem(updated);
      if (mounted) Navigator.of(context).pop(updated);
    } else {
      final saved = await notifier.saveDraft(
        DhikrDraft(
          title: title,
          arabic: _arabicCtrl.text.trim(),
          transliteration: _transliterationCtrl.text.trim(),
          meaning: _meaningCtrl.text.trim(),
          targetCount: targetCount <= 0 ? 33 : targetCount,
          groupName: groupName,
          prayerTime: _selectedPrayer,
          sourceUrl: sourceUrl,
        ),
      );
      if (mounted) Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final borderColor = p.primary.withValues(alpha: p.isDark ? 0.24 : 0.14);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existingItem != null;

    return Container(
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  widget.startWithScraper ? AppIcons.sparkle : AppIcons.dhikr,
                  color: p.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEdit
                        ? DhikrStrings.editSheetTitle
                        : (widget.startWithScraper
                            ? DhikrStrings.scrapeSheetTitle
                            : DhikrStrings.addSheetTitle),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_captionMissing) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.accent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(AppIcons.warning, color: p.danger, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DhikrStrings.captionMissingBanner,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_sourceUrlCtrl.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => ref
                            .read(dhikrProvider.notifier)
                            .openUrl(_sourceUrlCtrl.text.trim()),
                        icon: const Icon(AppIcons.externalLink, size: 16),
                        label: const Text(DhikrStrings.openSourceToCopy),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_wasScraped) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: p.secondary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.sparkle, color: p.secondary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DhikrStrings.sharedDetectedBanner,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!isEdit) ...[
              TextField(
                controller: _rawInputCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: DhikrStrings.rawInputLabel,
                  hintText: DhikrStrings.rawInputHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _analyzing ? null : _analyzeRawInput,
                      icon: Icon(
                        _analyzing ? AppIcons.timer : AppIcons.sparkle,
                        size: 18,
                      ),
                      label: Text(
                        _analyzing
                            ? DhikrStrings.analyzing
                            : DhikrStrings.analyzeButton,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                DhikrStrings.catalogQuickPick,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: p.textLight,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kDhikrCatalog.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, idx) {
                    final entry = kDhikrCatalog[idx];
                    return ActionChip(
                      label: Text(
                        entry.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _applyCatalogEntry(entry),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: DhikrStrings.fieldTitle,
                hintText: DhikrStrings.fieldTitleHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _arabicCtrl,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: DhikrStrings.fieldArabic,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: DhikrStrings.fieldTargetCount,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _transliterationCtrl,
              decoration: const InputDecoration(
                labelText: DhikrStrings.fieldTransliteration,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _meaningCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: DhikrStrings.fieldMeaning,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DhikrStrings.fieldGroup,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: p.textLight,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final g in DhikrGroups.defaults)
                  ChoiceChip(
                    label: Text(g, style: const TextStyle(fontSize: 12)),
                    selected: _groupCtrl.text.trim() == g,
                    onSelected: (_) => setState(() => _groupCtrl.text = g),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupCtrl,
              decoration: const InputDecoration(
                hintText: DhikrStrings.fieldCustomGroupHint,
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DhikrStrings.fieldPrayerTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: p.textLight,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text(
                    DhikrStrings.prayerTimeAny,
                    style: TextStyle(fontSize: 12),
                  ),
                  selected: _selectedPrayer == null,
                  onSelected: (_) => setState(() => _selectedPrayer = null),
                ),
                for (final pr in PrayerType.values)
                  ChoiceChip(
                    label: Text(pr.label, style: const TextStyle(fontSize: 12)),
                    selected: _selectedPrayer == pr,
                    onSelected: (_) => setState(() => _selectedPrayer = pr),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sourceUrlCtrl,
              decoration: const InputDecoration(
                labelText: DhikrStrings.fieldSourceUrl,
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onSave,
              icon: const Icon(AppIcons.selected),
              label: Text(
                isEdit ? DhikrStrings.updateButton : DhikrStrings.saveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
