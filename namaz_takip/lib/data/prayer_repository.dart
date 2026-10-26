import 'package:sqflite/sqflite.dart';

import '../core/date_utils.dart';
import '../core/prayer.dart';
import 'app_database.dart';

class PrayerRecord {
  const PrayerRecord({
    required this.date,
    required this.prayer,
    required this.status,
    required this.isCongregation,
  });

  final DateTime date;
  final PrayerType prayer;
  final PrayerStatus status;
  final bool isCongregation;
}

/// Kaza listesindeki tek satır.
class QazaItem {
  const QazaItem(this.date, this.prayer, this.status);

  final DateTime date;
  final PrayerType prayer;

  /// `pending` = gün bitti ama işaretlenmedi, `missed` = kullanıcı "kılmadım" dedi.
  final PrayerStatus status;

  bool get isAutoDetected => status == PrayerStatus.pending;
}

/// Bir günün, kılınan vakit sayısıyla özeti.
class DayCount {
  const DayCount(this.date, this.performed);

  final DateTime date;
  final int performed;
}

class PrayerRepository {
  PrayerRepository(this._appDb);

  final AppDatabase _appDb;

  Database get _db => _appDb.db;

  PrayerRecord _fromRow(Map<String, Object?> r) => PrayerRecord(
        date: parseDateKey(r['date']! as String),
        prayer: PrayerType.fromKey(r['prayer']! as String),
        status: PrayerStatus.fromCode(r['status']! as int),
        isCongregation: (r['is_congregation'] as int? ?? 0) == 1,
      );

  Future<Map<PrayerType, PrayerRecord>> recordsForDate(DateTime date) async {
    final rows = await _db
        .query('prayers', where: 'date = ?', whereArgs: [dateKey(date)]);
    return {
      for (final r in rows) PrayerType.fromKey(r['prayer']! as String): _fromRow(r),
    };
  }

  Future<List<PrayerRecord>> recordsBetween(DateTime from, DateTime to) async {
    final rows = await _db.query(
      'prayers',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [dateKey(from), dateKey(to)],
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> _upsert(
    DateTime date,
    PrayerType prayer,
    PrayerStatus status, {
    bool congregation = false,
  }) async {
    final stamp = DateTime.now().toIso8601String();
    await _db.insert(
      'prayers',
      {
        'date': dateKey(date),
        'prayer': prayer.key,
        'status': status.code,
        'is_congregation': congregation ? 1 : 0,
        'marked_at': stamp,
        'compensated_at': status == PrayerStatus.compensated ? stamp : null,
      },
      // UNIQUE(date, prayer): aynı vakit tekrar işaretlenince çift kayıt oluşmaz.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markPerformed(DateTime date, PrayerType prayer,
          {bool congregation = false}) =>
      _upsert(date, prayer, PrayerStatus.performed, congregation: congregation);

  Future<void> markMissed(DateTime date, PrayerType prayer) =>
      _upsert(date, prayer, PrayerStatus.missed);

  Future<void> markCompensated(DateTime date, PrayerType prayer) =>
      _upsert(date, prayer, PrayerStatus.compensated);

  /// Kaza listesi: [firstDay]..[today) arasında kılınmamış/kaza edilmemiş her
  /// vakit (işaretlemeyi unutulan günler dahil) + bugün "kılmadım" denenler.
  Future<List<QazaItem>> qazaItems({
    required DateTime firstDay,
    required DateTime today,
  }) async {
    final records = await recordsBetween(firstDay, today);
    final byKey = {
      for (final r in records) '${dateKey(r.date)}|${r.prayer.key}': r,
    };
    final items = <QazaItem>[];
    for (final day in daysBetween(firstDay, today)) {
      final isToday = !day.isBefore(today);
      for (final prayer in PrayerType.values) {
        final status = byKey['${dateKey(day)}|${prayer.key}']?.status ??
            PrayerStatus.pending;
        final done = status == PrayerStatus.performed ||
            status == PrayerStatus.compensated;
        if (done) continue;
        if (isToday && status != PrayerStatus.missed) continue;
        items.add(QazaItem(day, prayer, status));
      }
    }
    items.sort((a, b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : a.prayer.index.compareTo(b.prayer.index);
    });
    return items;
  }

  /// [from]..[to] arasında her takvim günü için kılınan vakit sayısı (0 dahil).
  Future<List<DayCount>> dailyCounts(DateTime from, DateTime to) async {
    final rows = await _db.rawQuery(
      'SELECT date, COUNT(*) AS c FROM prayers '
      'WHERE status = ? AND date BETWEEN ? AND ? GROUP BY date',
      [PrayerStatus.performed.code, dateKey(from), dateKey(to)],
    );
    final map = {for (final r in rows) r['date']! as String: r['c']! as int};
    return [
      for (final d in daysBetween(from, to)) DayCount(d, map[dateKey(d)] ?? 0),
    ];
  }

  /// [from]..[to] aralığında vakit bazında kılınan sayısı.
  Future<Map<PrayerType, int>> performedByPrayer(
      DateTime from, DateTime to) async {
    final rows = await _db.rawQuery(
      'SELECT prayer, COUNT(*) AS c FROM prayers '
      'WHERE status = ? AND date BETWEEN ? AND ? GROUP BY prayer',
      [PrayerStatus.performed.code, dateKey(from), dateKey(to)],
    );
    return {
      for (final t in PrayerType.values) t: 0,
      for (final r in rows)
        PrayerType.fromKey(r['prayer']! as String): r['c']! as int,
    };
  }

  Future<List<DateTime>> fullDays() async {
    final rows = await _db.rawQuery(
      'SELECT date FROM prayers WHERE status = ? '
      'GROUP BY date HAVING COUNT(*) = 5',
      [PrayerStatus.performed.code],
    );
    return rows.map((r) => parseDateKey(r['date']! as String)).toList();
  }

  Future<int> totalCongregation() async =>
      Sqflite.firstIntValue(await _db.rawQuery(
        'SELECT COUNT(*) FROM prayers WHERE status = ? AND is_congregation = 1',
        [PrayerStatus.performed.code],
      )) ??
      0;

  Future<int> totalPerformed(PrayerType prayer) async =>
      Sqflite.firstIntValue(await _db.rawQuery(
        'SELECT COUNT(*) FROM prayers WHERE status = ? AND prayer = ?',
        [PrayerStatus.performed.code, prayer.key],
      )) ??
      0;
}
