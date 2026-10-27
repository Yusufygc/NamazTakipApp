import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/content/dhikr_catalog.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import 'islamic_pattern.dart';

Future<void> showClassicTesbihatSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ClassicTesbihatSheet(),
  );
}

class _ClassicTesbihatSheet extends StatefulWidget {
  const _ClassicTesbihatSheet();

  @override
  State<_ClassicTesbihatSheet> createState() => _ClassicTesbihatSheetState();
}

class _ClassicTesbihatSheetState extends State<_ClassicTesbihatSheet> {
  int _stepIndex = 0;
  int _count = 0;
  bool _completedAll = false;

  ClassicTesbihatStep get _currentStep => kClassicTesbihatSteps[_stepIndex];

  void _onTapCounter() {
    if (_completedAll) return;
    final nextCount = _count + 1;
    if (nextCount >= _currentStep.targetCount) {
      HapticFeedback.heavyImpact();
      if (_stepIndex + 1 < kClassicTesbihatSteps.length) {
        setState(() {
          _stepIndex++;
          _count = 0;
        });
      } else {
        setState(() {
          _count = _currentStep.targetCount;
          _completedAll = true;
        });
      }
    } else {
      HapticFeedback.lightImpact();
      setState(() => _count = nextCount);
    }
  }

  void _resetAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _stepIndex = 0;
      _count = 0;
      _completedAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final step = _currentStep;
    final progress = _completedAll
        ? 1.0
        : (_count / step.targetCount).clamp(0.0, 1.0);

    final startColor = p.isDark ? const Color(0xFF16382B) : p.dark;
    final endColor = p.isDark ? const Color(0xFF0F261D) : p.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: p.secondary.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: MihrabArchBackdrop(
        borderRadius: 28,
        lineColor: Colors.white.withValues(alpha: 0.08),
        accentColor: p.secondary.withValues(alpha: 0.16),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // Üst başlık
                Row(
                  children: [
                    SeljukMedallion(
                      size: 38,
                      fillColor: Colors.white.withValues(alpha: 0.14),
                      borderColor: p.secondary,
                      child: Icon(AppIcons.dhikr, size: 20, color: p.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            DhikrStrings.classicTesbihatTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            DhikrStrings.classicStepIndicator(
                              _stepIndex + 1,
                              kClassicTesbihatSteps.length,
                            ),
                            style: TextStyle(
                              color: p.secondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: DhikrStrings.resetCounterButton,
                      onPressed: _resetAll,
                      icon: const Icon(AppIcons.reset, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        AppIcons.confirmMissed,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 4 Aşamalı İlerleme Çubuğu
                Row(
                  children: [
                    for (var i = 0; i < kClassicTesbihatSteps.length; i++) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _stepIndex = i;
                            _count = 0;
                            _completedAll = false;
                          }),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: i < _stepIndex || _completedAll
                                  ? p.accent
                                  : (i == _stepIndex
                                        ? p.secondary
                                        : Colors.white.withValues(alpha: 0.20)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      if (i < kClassicTesbihatSteps.length - 1)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Arapça hat ve okunuş kutusu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: p.secondary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        step.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: p.secondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.transliteration,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.meaning,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_completedAll)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.accent),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          AppIcons.selected,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          DhikrStrings.classicCompletedTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DhikrStrings.classicCompletedBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: p.secondary,
                            foregroundColor: Colors.black87,
                          ),
                          onPressed: _resetAll,
                          icon: const Icon(AppIcons.reset, size: 18),
                          label: const Text(DhikrStrings.resetCounterButton),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Dokunmatik Selçuklu Zikirmatik Madalyonu
                  GestureDetector(
                    onTap: _onTapCounter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 176,
                          height: 176,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            color: p.secondary,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        SeljukMedallion(
                          size: 148,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                          borderColor: p.secondary,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '/ ${step.targetCount}',
                                style: TextStyle(
                                  color: p.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Icon(
                                AppIcons.touch,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DhikrStrings.counterTapHint,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
