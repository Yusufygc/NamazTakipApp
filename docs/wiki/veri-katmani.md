# Veri Katmanı (SQLite)

Depolama `sqflite` iledir. Dosya adı `namaz_takip.db`, şema sürümü 1. Kod: `lib/data/app_database.dart`, `lib/data/prayer_repository.dart`. Neden `sqflite`: [[007-sqflite-secimi]].

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

Yardımcılar `lib/core/date_utils.dart` içindedir: `dateKey`, `parseDateKey`, `dateOnly`, `addDays`, `daysBetween`, `daysDiff` (yaz/kış saatinden etkilenmez).

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

## Şema değişikliği nasıl yapılır

1. `AppDatabase._version` artırılır.
2. `openDatabase` çağrısına `onUpgrade` eklenir ve eski sürümden geçiş yazılır.
3. Geçiş, bellek içi veritabanında test edilir (`sqflite_common_ffi`).
4. Bu sayfa ve [[log]] güncellenir.

Uygulama yayınlanmadığı için şu ana kadar veri taşıma gerekmedi.

## Test

`test/prayer_repository_test.dart`, `sqflite_common_ffi` ile bellek içi veritabanında çalışır: [[test-stratejisi]].

## İlgili sayfalar

[[mimari-genel]] · [[ayarlar-ve-kalicilik]] · [[kaza-sistemi]] · [[namaz-isaretleme]]
