import 'package:sqflite/sqflite.dart';

import '../domain/dhikr.dart';
import '../domain/dhikr_extractor.dart';
import '../domain/prayer.dart';
import 'app_database.dart';

/// Zikir ve Esma kayıtlarının SQLite deposu.
class DhikrRepository {
  DhikrRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// İlk kullanımda tablo tamamen boşsa başlangıç tesbihat ve esmalarını ekler.
  Future<void> seedDefaultsIfEmpty() async {
    final count = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM dhikrs'),
        ) ??
        0;
    if (count > 0) return;

    final nowIso = DateTime.now().toIso8601String();
    final starterTitles = <String>[
      'Sübhanallah',
      'Elhamdülillah',
      'Allahü Ekber',
      'Estağfirullah el-Azîm',
      'Yâ Rezzâk',
      'Yâ Şâfî',
    ];
    for (final title in starterTitles) {
      final entry = kDhikrCatalog.firstWhere((e) => e.title == title);
      await _db.insert('dhikrs', {
        'title': entry.title,
        'arabic': entry.arabic,
        'transliteration': entry.transliteration,
        'meaning': entry.meaning,
        'target_count': entry.defaultCount,
        'current_count': 0,
        'total_completed': 0,
        'group_name': entry.groupName,
        'prayer_time': entry.prayerTime?.name,
        'source_url': null,
        'is_favorite': 0,
        'created_at': nowIso,
      });
    }
  }

  Future<List<DhikrItem>> allItems() async {
    final rows = await _db.query(
      'dhikrs',
      orderBy: 'is_favorite DESC, id DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<DhikrItem?> byId(int id) async {
    final rows = await _db.query(
      'dhikrs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<DhikrItem> insertDraft(DhikrDraft draft, {DateTime? now}) async {
    final createdAt = now ?? DateTime.now();
    final id = await _db.insert('dhikrs', {
      'title': draft.title.trim().isEmpty ? 'Zikir' : draft.title.trim(),
      'arabic': draft.arabic.trim(),
      'transliteration': draft.transliteration.trim(),
      'meaning': draft.meaning.trim(),
      'target_count': draft.targetCount <= 0 ? 33 : draft.targetCount,
      'current_count': 0,
      'total_completed': 0,
      'group_name': draft.groupName.trim().isEmpty
          ? DhikrGroups.general
          : draft.groupName.trim(),
      'prayer_time': draft.prayerTime?.name,
      'source_url': draft.sourceUrl?.trim().isEmpty == true
          ? null
          : draft.sourceUrl?.trim(),
      'is_favorite': 0,
      'created_at': createdAt.toIso8601String(),
    });
    return (await byId(id))!;
  }

  Future<void> update(DhikrItem item) async {
    await _db.update(
      'dhikrs',
      {
        'title': item.title.trim(),
        'arabic': item.arabic.trim(),
        'transliteration': item.transliteration.trim(),
        'meaning': item.meaning.trim(),
        'target_count': item.targetCount <= 0 ? 33 : item.targetCount,
        'current_count': item.currentCount,
        'total_completed': item.totalCompleted,
        'group_name': item.groupName.trim().isEmpty
            ? DhikrGroups.general
            : item.groupName.trim(),
        'prayer_time': item.prayerTime?.name,
        'source_url': item.sourceUrl?.trim().isEmpty == true
            ? null
            : item.sourceUrl?.trim(),
        'is_favorite': item.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<DhikrItem?> incrementCount(int id, {int step = 1}) async {
    final item = await byId(id);
    if (item == null) return null;
    final nextCount = item.currentCount + step;
    var nextTotal = item.totalCompleted;
    var updatedCurrent = nextCount;
    if (item.targetCount > 0 && nextCount >= item.targetCount) {
      nextTotal += 1;
      updatedCurrent = item.targetCount;
    }
    await _db.update(
      'dhikrs',
      {
        'current_count': updatedCurrent,
        'total_completed': nextTotal,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return byId(id);
  }

  Future<DhikrItem?> resetCount(int id) async {
    await _db.update(
      'dhikrs',
      {'current_count': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    return byId(id);
  }

  Future<void> delete(int id) async {
    await _db.delete('dhikrs', where: 'id = ?', whereArgs: [id]);
  }

  DhikrItem _fromRow(Map<String, Object?> row) {
    final prayerStr = row['prayer_time'] as String?;
    PrayerType? prayerTime;
    if (prayerStr != null && prayerStr.isNotEmpty) {
      for (final p in PrayerType.values) {
        if (p.name == prayerStr) {
          prayerTime = p;
          break;
        }
      }
    }
    return DhikrItem(
      id: row['id'] as int,
      title: row['title'] as String? ?? '',
      arabic: row['arabic'] as String? ?? '',
      transliteration: row['transliteration'] as String? ?? '',
      meaning: row['meaning'] as String? ?? '',
      targetCount: row['target_count'] as int? ?? 33,
      currentCount: row['current_count'] as int? ?? 0,
      totalCompleted: row['total_completed'] as int? ?? 0,
      groupName: row['group_name'] as String? ?? DhikrGroups.general,
      prayerTime: prayerTime,
      sourceUrl: row['source_url'] as String?,
      isFavorite: (row['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
