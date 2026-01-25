import * as SQLite from 'expo-sqlite';

let db;

export const getDBConnection = async () => {
  if (!db) {
    db = await SQLite.openDatabaseSync('prayer_tracker.db');
  }
  return db;
};

export const initDB = async () => {
  const db = await getDBConnection();
  try {
    await db.execAsync(`
      PRAGMA journal_mode = WAL;
      
      CREATE TABLE IF NOT EXISTS prayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL CHECK(prayer_name IN ('Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı')),
        date TEXT NOT NULL,
        prayer_time TEXT NOT NULL,
        is_performed INTEGER DEFAULT 0,
        performed_at TEXT,
        is_congregation INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(prayer_name, date)
      );
      
      CREATE INDEX IF NOT EXISTS idx_prayers_date ON prayers(date);
      CREATE INDEX IF NOT EXISTS idx_prayers_performed ON prayers(is_performed);

      CREATE TABLE IF NOT EXISTS qaza_prayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL,
        missed_date TEXT NOT NULL,
        is_compensated INTEGER DEFAULT 0,
        compensated_at TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE INDEX IF NOT EXISTS idx_qaza_compensated ON qaza_prayers(is_compensated);

      CREATE TABLE IF NOT EXISTS prayer_times_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        city TEXT NOT NULL,
        country TEXT NOT NULL,
        fajr TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(date, city)
      );
      
      CREATE INDEX IF NOT EXISTS idx_cache_date ON prayer_times_cache(date);

      CREATE TABLE IF NOT EXISTS reminder_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reminder_type TEXT CHECK(reminder_type IN ('after_adhan', 'custom')),
        minutes_after INTEGER DEFAULT 15,
        is_active INTEGER DEFAULT 1,
        prayer_name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT UNIQUE NOT NULL,
        setting_value TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );

      INSERT OR IGNORE INTO app_settings (setting_key, setting_value) VALUES
        ('notification_enabled', '1'),
        ('location_permission', '0'),
        ('selected_city', ''),
        ('selected_country', ''),
        ('calculation_method', '13'),
        ('language', 'tr');
    `);
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization failed:', error);
    throw error;
  }
};

export const runQuery = async (query, params = []) => {
  const db = await getDBConnection();
  try {
    return await db.getAllAsync(query, params);
  } catch (error) {
    console.error('Query failed:', query, error);
    throw error;
  }
};

export const runRun = async (query, params = []) => {
    const db = await getDBConnection();
    try {
        return await db.runAsync(query, params);
    } catch (error) {
      console.error('Run failed:', query, error);
      throw error;
    }
}
