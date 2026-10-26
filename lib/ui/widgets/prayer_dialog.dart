import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/date_utils.dart';
import '../../core/prayer.dart';

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
          const Text('🕌', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('${widget.prayer.trName.toUpperCase()} NAMAZINI',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('KILDINIZ MI?',
              style: TextStyle(fontSize: 15, color: p.textLight)),
          if (widget.date != null && widget.date != dateOnly(DateTime.now()))
            Text(formatDateTr(widget.date!),
                style: TextStyle(fontSize: 13, color: p.textLight)),
        ],
      ),
      content: CheckboxListTile(
        value: _congregation,
        onChanged: (v) => setState(() => _congregation = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('Cemaatle kıldım'),
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
          icon: const Icon(Icons.check),
          label: const Text('Kıldım'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: p.danger),
          onPressed: () =>
              Navigator.pop(context, const PrayerDialogResult(PrayerAnswer.missed)),
          icon: const Icon(Icons.close),
          label: const Text('Kılmadım'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Vazgeç', style: TextStyle(color: p.textLight)),
        ),
      ],
    );
  }
}
