# Veri Katmanı (SQLite)

Depolama `sqflite` iledir. Dosya adı `namaz_takip.db`, şema sürümü 1. Kod: `packages/namaz_backend/lib/src/data/app_database.dart`, `packages/namaz_backend/lib/src/data/prayer_repository.dart`. Neden `sqflite`: [[007-sqflite-secimi]].

## Şema

Tek tablo vardır:

```sql
CREATE TABLE prayers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,              -- 'yyyy-MM-dd'
  prayer TEXT NOT NULL,            -- 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha'
  status INTEGER NOT NULL DEFAULT 0,
  is_congregation INTEGER NOT NULL DEFAULT 0,
  marked_at TEXT,                  -- ISO 8601
  compensated_at TEXT,             -- yalnızca status = 3
  UNIQUE(date, prayer)
);
-- indeksler: idx_prayers_date(date), idx_prayers_status(status)
```

Kural: bir vaktin satırı yalnızca kullanıcı işaretleyince oluşur. İşaretlenmemiş vakit için satır **yoktur**; bu, kaza listesinin nasıl türetildiğini belirler: [[kaza-sistemi]], [[005-kaza-turetilir]].

## Durum kodları (`PrayerStatus`)

| Kod | Ad | Anlam | İstatistiğe girer mi |
|---|---|---|---|
| 0 | `pending` | Bekliyor (satır genelde yoktur, varsayılan değer) | Hayır |
| 1 | `performed` | Kılındı | **Evet** (zamanında kılınan) |
| 2 | `missed` | Kullanıcı "kılmadım" dedi | Hayır |
| 3 | `compensated` | Kaza edildi | Hayır (zamanında kılınmış sayılmaz) |

İstatistik ve seri yalnızca `performed` sayar: [[istatistikler]], [[seri-ve-rozetler]].

## Tarih biçimi

Tarihler `yyyy-MM-dd` metni olarak saklanır; metin sıralaması tarih sıralamasıyla aynıdır, `BETWEEN` ve `ORDER BY` doğru çalışır. Eski uygulama `dd-MM-yyyy` kullandığı için sıralama ve seri hesabı hatalıydı: [[003-iso-tarih-formati]].

Yardımcılar `packages/namaz_backend/lib/src/domain/dates.dart` içindedir: `dateKey`, `parseDateKey`, `dateOnly`, `addDays`, `daysBetween`, `daysDiff` (yaz/kış saatinden etkilenmez).

## Tekrar işaretleme

`UNIQUE(date, prayer)` ve `ConflictAlgorithm.replace` birlikte çalışır: aynı vakit tekrar işaretlenirse satır güncellenir, ikinci kayıt oluşmaz. Eski uygulamadaki "aynı vakit birden çok kez kazaya yazılıyor" hatasının çözümüdür. Test: "aynı vakit tekrar işaretlenince tek kayıt kalır".

## Repository sorguları (`PrayerRepository`)

| Metot | Ne yapar |
|---|---|
| `recordsForDate`, `recordsBetween` | Kayıtları okur |
| `markPerformed`, `markMissed`, `markCompensated` | Upsert |
| `qazaItems(firstDay, today)` | Kaza listesini türetir: [[kaza-sistemi]] |
| `dailyCounts(from, to)` | Her gün için kılınan sayısı, sıfır günler dahil |
| `performedByPrayer(from, to)` | Vakit bazında kılınan sayısı |
| `fullDays()` | 5/5 olan günler |
| `totalCongregation()`, `totalPerformed(vakit)` | Rozet verisi |

## Bozuk veritabanı kurtarma (`AppDatabase.open`)

Android'in `DefaultDatabaseErrorHandler` mekanizması, bozuk bir SQLite dosyası açıldığında hata fırlatmak yerine dosyayı sessizce silip boş bir veritabanı oluşturur. Kullanıcının geçmişini haber almadan kaybetmesini önlemek için `AppDatabase.open` şu sırayla çalışır:

1. Dosya diskte zaten varsa, `openDatabase` çağrılmadan önce ham baytları belleğe okunur.
2. İlk 16 baytın SQLite 3 imzası (`"SQLite format 3\x00"`) olup olmadığı ve dosyanın en az 100 bayt başlık taşıyıp taşımadığı kontrol edilir.
3. Başlık geçerliyse veritabanı açılır; açılış sırasında `onCreate` tetiklendiyse (Android'in dosyayı sessizce sıfırladığı durum), `openDatabase` hata fırlattıysa veya `PRAGMA integrity_check` / `prayers` tablosu kontrolü başarısız olduysa dosya bozuk kabul edilir.
4. Diskte eski yedeklerin birikmemesi için varsa önceki `namaz_takip.db.bozuk-*` dosyaları silinir; bozuk dosyanın bellekteki özgün baytları silinmeden önce aynı klasöre `namaz_takip.db.bozuk-<yyyyAAgg-SSddss>` adıyla yedeklenir; bozuk dosya (ve varsa `-wal`, `-shm`, `-journal` yan dosyaları) silinerek temiz bir veritabanı açılır.
5. Yedek dosyanın yolu `AppDatabase.corruptedBackupPath` üzerinden `SettingsRepository`'ye (`corrupted_db_backup`) kaydedilir ve ön yüzde `CorruptedDatabaseCard` ile kullanıcıya gösterilir: [[ui-ekranlar]], [[ayarlar-ve-kalicilik]].

## Şema değişikliği nasıl yapılır

1. `AppDatabase._version` artırılır.
2. `openDatabase` çağrısına `onUpgrade` eklenir ve eski sürümden geçiş yazılır.
3. Geçiş, bellek içi veritabanında test edilir (`sqflite_common_ffi`).
4. Bu sayfa ve [[log]] güncellenir.

Uygulama yayınlanmadığı için şu ana kadar veri taşıma gerekmedi.

## Test

`packages/namaz_backend/test/prayer_repository_test.dart`, `sqflite_common_ffi` ile bellek içi veritabanında sorguları ve geçici dizinde gerçek dosyalarla bozuk veritabanı yedekleme/kurtarma davranışını test eder: [[test-stratejisi]].

## İlgili sayfalar

[[mimari-genel]] · [[ayarlar-ve-kalicilik]] · [[kaza-sistemi]] · [[namaz-isaretleme]]
