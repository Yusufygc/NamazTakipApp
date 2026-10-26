import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite bağlantısı ve şema.
///
/// Tarihler `yyyy-MM-dd` metni olarak saklanır; böylece `ORDER BY date`
/// ve `BETWEEN` doğru çalışır.
class AppDatabase {
  AppDatabase._(this.db, {this.corruptedBackupPath});

  final Database db;

  /// Açılışta bozuk bir veritabanı dosyası tespit edilip sıfırlandıysa,
  /// silinmeden önce alınan yedeğin tam dosya yolu (`namaz_takip.db.bozuk-<zaman>`).
  /// Normal açılışta `null` döner.
  final String? corruptedBackupPath;

  static const _version = 1;
  static const fileName = 'namaz_takip.db';

  /// SQLite 3 dosya başlığının ilk 16 baytı: `"SQLite format 3\x00"`.
  static const List<int> _sqliteHeaderMagic = [
    0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
    0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
  ];
  static const int _sqliteHeaderMinLength = 100;

  static Future<AppDatabase> open({String? path, DateTime? now}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), fileName);
    if (dbPath == inMemoryDatabasePath) {
      return AppDatabase._(await _openRaw(dbPath));
    }

    final entityType = await FileSystemEntity.type(dbPath);
    if (entityType != FileSystemEntityType.file) {
      // Dosya henüz yoksa yeni oluşturulur; dizin vb. ise openDatabase uygun hatayı fırlatır.
      return AppDatabase._(await _openRaw(dbPath));
    }

    // Android'in DefaultDatabaseErrorHandler'ı bozuk dosyayı openDatabase içinde
    // sessizce silip sıfırlayabildiği için, açmadan önce ham baytları belleğe alıyoruz.
    final file = File(dbPath);
    final originalBytes = await file.readAsBytes();

    if (!_hasValidSqliteHeader(originalBytes)) {
      return _recoverFromCorruptedFile(
        dbPath: dbPath,
        originalBytes: originalBytes,
        now: now ?? DateTime.now(),
      );
    }

    var createdOnExistingFile = false;
    Database? candidate;
    try {
      candidate = await openDatabase(
        dbPath,
        version: _version,
        singleInstance: false,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          createdOnExistingFile = true;
          await _onCreate(db, version);
        },
      );
      // Var olan bir dosyada onCreate çalıştıysa Android bozuk dosyayı sessizce
      // silip yeniden oluşturmuştur. Ayrıca bütünlük ve tablo varlığını denetle.
      if (createdOnExistingFile || !await _isHealthy(candidate)) {
        await candidate.close();
        candidate = null;
      }
    } catch (_) {
      try {
        await candidate?.close();
      } catch (_) {}
      candidate = null;
    }

    if (candidate != null) {
      return AppDatabase._(candidate);
    }

    return _recoverFromCorruptedFile(
      dbPath: dbPath,
      originalBytes: originalBytes,
      now: now ?? DateTime.now(),
    );
  }

  /// Test için bellek içi veritabanı.
  static Future<AppDatabase> openInMemory() => open(path: inMemoryDatabasePath);

  static bool _hasValidSqliteHeader(Uint8List bytes) {
    if (bytes.length < _sqliteHeaderMinLength) return false;
    for (var i = 0; i < _sqliteHeaderMagic.length; i++) {
      if (bytes[i] != _sqliteHeaderMagic[i]) return false;
    }
    return true;
  }

  static Future<bool> _isHealthy(Database db) async {
    try {
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        return false;
      }
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'prayers'",
      );
      return tables.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<AppDatabase> _recoverFromCorruptedFile({
    required String dbPath,
    required Uint8List originalBytes,
    required DateTime now,
  }) async {
    await _deleteOldBackups(dbPath);
    final backupPath = '$dbPath.bozuk-${_formatTimestamp(now)}';
    await File(backupPath).writeAsBytes(originalBytes, flush: true);
    await _deleteDatabaseFiles(dbPath);
    final cleanDb = await _openRaw(dbPath);
    return AppDatabase._(cleanDb, corruptedBackupPath: backupPath);
  }

  /// Diskte eski `.bozuk-*` yedeklerinin birikmemesi için yeni yedek yazılmadan
  /// önce önceki yedekleri siler; yalnızca son bozuk kopya tutulur.
  static Future<void> _deleteOldBackups(String dbPath) async {
    final dir = File(dbPath).parent;
    if (!await dir.exists()) return;
    final prefix = '${p.basename(dbPath)}.bozuk-';
    await for (final entity in dir.list()) {
      if (entity is File && p.basename(entity.path).startsWith(prefix)) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  static Future<void> _deleteDatabaseFiles(String dbPath) async {
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File('$dbPath$suffix');
      if (await f.exists()) {
        await f.delete();
      }
    }
  }

  static String _formatTimestamp(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}${two(dt.month)}${two(dt.day)}-'
        '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}';
  }

  static Future<Database> _openRaw(String dbPath) => openDatabase(
        dbPath,
        version: _version,
        singleInstance: dbPath == inMemoryDatabasePath,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
      );

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        is_congregation INTEGER NOT NULL DEFAULT 0,
        marked_at TEXT,
        compensated_at TEXT,
        UNIQUE(date, prayer)
      )
    ''');
    await db.execute('CREATE INDEX idx_prayers_date ON prayers(date)');
    await db.execute('CREATE INDEX idx_prayers_status ON prayers(status)');
  }

  Future<void> close() => db.close();
}
