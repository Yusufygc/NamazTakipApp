import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'islamic_pattern.dart';

Future<void> showQazaDebtSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QazaDebtSheet(),
  );
}

class _QazaDebtSheet extends ConsumerStatefulWidget {
  const _QazaDebtSheet();

  @override
  ConsumerState<_QazaDebtSheet> createState() => _QazaDebtSheetState();
}

class _QazaDebtSheetState extends ConsumerState<_QazaDebtSheet> {
  final TextEditingController _yearsCtrl = TextEditingController(text: '0');
  final TextEditingController _monthsCtrl = TextEditingController(text: '0');
  final TextEditingController _daysCtrl = TextEditingController(text: '0');
  late final Map<PrayerType, TextEditingController> _prayerCtrls;
  late int _dailyTarget;

  @override
  void initState() {
    super.initState();
    final plan = ref.read(qazaDebtProvider);
    _dailyTarget = plan.dailyTarget;
    _prayerCtrls = {
      for (final p in PrayerType.values)
        p: TextEditingController(text: '${plan.countFor(p)}'),
    };
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    _monthsCtrl.dispose();
    _daysCtrl.dispose();
    for (final c in _prayerCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyDuration() {
    final years = int.tryParse(_yearsCtrl.text.trim()) ?? 0;
    final months = int.tryParse(_monthsCtrl.text.trim()) ?? 0;
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 0;
    final addCount = (years * 365) + (months * 30) + days;
    if (addCount <= 0) return;
    setState(() {
      for (final p in PrayerType.values) {
        final current = int.tryParse(_prayerCtrls[p]!.text.trim()) ?? 0;
        _prayerCtrls[p]!.text = '${current + addCount}';
      }
      _yearsCtrl.text = '0';
      _monthsCtrl.text = '0';
      _daysCtrl.text = '0';
    });
  }

  Future<void> _save() async {
    final counts = <PrayerType, int>{
      for (final p in PrayerType.values)
        p: (int.tryParse(_prayerCtrls[p]!.text.trim()) ?? 0).clamp(0, 999999),
    };
    final notifier = ref.read(qazaDebtProvider.notifier);
    await notifier.setBacklog(counts);
    await notifier.setDailyTarget(_dailyTarget);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: p.secondary.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.textLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SeljukMedallion(
                      size: 36,
                      fillColor: p.primary.withValues(alpha: 0.14),
                      borderColor: p.secondary,
                      child: Icon(
                        AppIcons.navQazaSelected,
                        size: 18,
                        color: p.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        QazaStrings.wizardTitle,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 17.5,
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
                const SizedBox(height: 6),
                Text(
                  QazaStrings.wizardSubtitle,
                  style: TextStyle(
                    color: p.textLight,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                // Yıl / Ay / Gün hızlı hesaplama kutusu
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: p.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _NumField(
                              controller: _yearsCtrl,
                              label: QazaStrings.wizardYearsLabel,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumField(
                              controller: _monthsCtrl,
                              label: QazaStrings.wizardMonthsLabel,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumField(
                              controller: _daysCtrl,
                              label: QazaStrings.wizardDaysLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _applyDuration,
                          icon: const Icon(AppIcons.add, size: 17),
                          label: const Text(
                            QazaStrings.wizardApplyDurationButton,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // 5 Vakit bazlı borç düzenleme
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: p.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (final prayer in PrayerType.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.prayerIcon(prayer),
                                size: 18,
                                color: p.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  prayer.label,
                                  style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                child: TextField(
                                  controller: _prayerCtrls[prayer],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Günlük kaza hedefi
                Text(
                  QazaStrings.wizardDailyTargetLabel,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final n in const [1, 2, 3, 5, 10, 15, 20])
                      ChoiceChip(
                        label: Text(QazaStrings.dailyTargetValue(n)),
                        selected: _dailyTarget == n,
                        onSelected: (_) => setState(() => _dailyTarget = n),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  icon: const Icon(AppIcons.confirmPerformed),
                  label: const Text(
                    QazaStrings.wizardSaveButton,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
