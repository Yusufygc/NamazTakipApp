import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite bağlantısı ve şema.
///
/// Tarihler `yyyy-MM-dd` metni olarak saklanır; böylece `ORDER BY date`
/// ve `BETWEEN` doğru çalışır.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const _version = 1;
  static const fileName = 'namaz_takip.db';

  static Future<AppDatabase> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), fileName);
    final db = await openDatabase(
      dbPath,
      version: _version,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
    return AppDatabase._(db);
  }

  /// Test için bellek içi veritabanı.
  static Future<AppDatabase> openInMemory() => open(path: inMemoryDatabasePath);

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
