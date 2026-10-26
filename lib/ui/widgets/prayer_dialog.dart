import 'package:flutter/material.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import 'islamic_pattern.dart';

enum PrayerAnswer { performed, missed }

class PrayerDialogResult {
  const PrayerDialogResult(this.answer, {this.congregation = false});

  final PrayerAnswer answer;
  final bool congregation;
}

/// "X namazını kıldınız mı?" sorusu. Vazgeçilirse null döner.
Future<PrayerDialogResult?> showPrayerDialog(
  BuildContext context, {
  required PrayerType prayer,
  DateTime? date,
}) {
  return showDialog<PrayerDialogResult>(
    context: context,
    builder: (_) => _PrayerDialog(prayer: prayer, date: date),
  );
}

class _PrayerDialog extends StatefulWidget {
  const _PrayerDialog({required this.prayer, this.date});

  final PrayerType prayer;
  final DateTime? date;

  @override
  State<_PrayerDialog> createState() => _PrayerDialogState();
}

class _PrayerDialogState extends State<_PrayerDialog> {
  bool _congregation = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Dialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: p.secondary.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeljukMedallion(
              size: 64,
              fillColor: p.primary.withValues(alpha: p.isDark ? 0.24 : 0.10),
              borderColor: p.secondary,
              child: Icon(
                AppIcons.prayerIcon(widget.prayer),
                size: 28,
                color: p.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              PrayerDialogStrings.title(widget.prayer.label),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: p.text,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              PrayerDialogStrings.question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.textLight,
                letterSpacing: 0.8,
              ),
            ),
            if (widget.date != null && widget.date != dateOnly(DateTime.now()))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateStrings.long(widget.date!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.primary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            // Cemaatle kıldım seçim kartı
            Material(
              color: _congregation
                  ? p.primary.withValues(alpha: p.isDark ? 0.22 : 0.10)
                  : p.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _congregation
                      ? p.primary
                      : p.primary.withValues(alpha: 0.18),
                  width: _congregation ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _congregation = !_congregation),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.congregation,
                        color: _congregation ? p.primary : p.textLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PrayerDialogStrings.congregation,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: p.text,
                              ),
                            ),
                            Text(
                              PrayerDialogStrings.congregationHint,
                              style: TextStyle(
                                fontSize: 12,
                                color: p.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: _congregation,
                        activeColor: p.primary,
                        onChanged: (v) =>
                            setState(() => _congregation = v ?? false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.danger,
                      side: BorderSide(color: p.danger.withValues(alpha: 0.65)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      const PrayerDialogResult(PrayerAnswer.missed),
                    ),
                    icon: const Icon(AppIcons.confirmMissed, size: 18),
                    label: const Text(PrayerDialogStrings.missed),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      PrayerDialogResult(
                        PrayerAnswer.performed,
                        congregation: _congregation,
                      ),
                    ),
                    icon: const Icon(AppIcons.confirmPerformed, size: 18),
                    label: const Text(PrayerDialogStrings.performed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                CommonStrings.dismiss,
                style: TextStyle(color: p.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
