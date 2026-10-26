import 'package:flutter/material.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/theme/app_theme.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

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
    return AlertDialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Icon(AppIcons.dialogHeader, size: 40, color: p.primary),
          const SizedBox(height: 8),
          Text(PrayerDialogStrings.title(widget.prayer.label),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(PrayerDialogStrings.question,
              style: TextStyle(fontSize: 15, color: p.textLight)),
          if (widget.date != null && widget.date != dateOnly(DateTime.now()))
            Text(DateStrings.long(widget.date!),
                style: TextStyle(fontSize: 13, color: p.textLight)),
        ],
      ),
      content: CheckboxListTile(
        value: _congregation,
        onChanged: (v) => setState(() => _congregation = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text(PrayerDialogStrings.congregation),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowButtonSpacing: 8,
      actions: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: p.dark),
          onPressed: () => Navigator.pop(
            context,
            PrayerDialogResult(PrayerAnswer.performed, congregation: _congregation),
          ),
          icon: const Icon(AppIcons.confirmPerformed),
          label: const Text(PrayerDialogStrings.performed),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: p.danger),
          onPressed: () =>
              Navigator.pop(context, const PrayerDialogResult(PrayerAnswer.missed)),
          icon: const Icon(AppIcons.confirmMissed),
          label: const Text(PrayerDialogStrings.missed),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(CommonStrings.dismiss, style: TextStyle(color: p.textLight)),
        ),
      ],
    );
  }
}
