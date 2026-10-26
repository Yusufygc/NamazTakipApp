# Mimari (Genel Bakış)

Uygulama iki **ayrı Dart paketinden** oluşur: ön yüz (front) ve backend. Aralarında tek bir sözleşme vardır: `NamazBackend` arayüzü. Karar gerekçesi: [[011-front-backend-ayrimi]].

```
┌────────────────────────── ön yüz: uygulama paketi (namaz_takip) ──────────────────────────┐
│  ui  →  providers  →  (NamazBackend arayüzü)        core: tema, ikon, metin, biçimleme    │
└──────────────────────────────────────────┬────────────────────────────────────────────────┘
                                           │  yalnızca package:namaz_backend/namaz_backend.dart
┌──────────────────────────────────────────▼────────────────────────────────────────────────┐
│  backend paketi (packages/namaz_backend)                                                  │
│  application  →  data, platform  →  domain                                                │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Ön yüz (`lib/`)

Ekranları, görünümü ve kullanıcıya görünen her şeyi bilir; iş kuralını ve altyapıyı bilmez.

| Klasör | Sorumluluk |
|---|---|
| `lib/ui/` | Ekranlar ve widget'lar: [[ui-ekranlar]] |
| `lib/providers/` | Riverpod; `NamazBackend` çağrılarını sağlayıcılara çevirir, iş kuralı içermez: [[durum-yonetimi]] |
| `lib/core/theme/` | Tema ve renk paleti: [[tema-sistemi]] |
| `lib/core/icons/` | Merkezi ikon sistemi: [[ikon-sistemi]] |
| `lib/core/strings/` | Modüler metin sistemi ve bildirim metin adaptörü: [[metin-sistemi]] |
| `lib/core/format/` | Gösterim yardımcıları (`formatTime`, `turkishUpper`, `foldTurkish`) |
| `lib/main.dart` | Backend'i kurar, `ProviderScope`'a verir; arka plan giriş noktasını tanımlar |

Ön yüzün `pubspec.yaml`'ında yalnızca arayüz paketleri vardır: `flutter_riverpod`, `fl_chart`, `namaz_backend`. SQLite, konum, bildirim, arka plan, vakit hesabı paketleri **yoktur**.

## Backend (`packages/namaz_backend/`)

Arayüz bilmez: `material`, `widgets`, Riverpod, `fl_chart` içe aktarılmaz. Ayrıntı: [[backend-paketi]].

| Katman (`lib/src/`) | Sorumluluk | Bağımlılığı |
|---|---|---|
| `domain/` | Saf Dart: modeller, tarih ve seri kuralları, vakit hesabı, bildirim planı, `NotificationTexts` portu | yalnızca `adhan_dart` |
| `data/` | SQLite şeması, repository'ler, ayar deposu, il listesi | `domain` |
| `platform/` | Konum, bildirim eklentileri | `domain` |
| `application/` | Bildirim planlama, arka plan görevi, `NamazBackend` uygulaması, istatistik kuralları | `domain`, `data`, `platform` |

`lib/namaz_backend.dart` tek herkese açık yüzdür; `src/` altındaki hiçbir dosya ön yüze açılmaz.

## Sınır nasıl korunuyor

1. **Paket sınırı:** Ön yüz backend'in iç dosyalarını (`src/`) içe aktaramaz; içe aktarırsa `flutter analyze` ve test düşer.
2. **Bağımlılık sınırı:** Konum, bildirim, depolama paketleri yalnızca backend'in `pubspec.yaml`'ındadır.
3. **Otomatik testler:** `test/architecture_test.dart` (ön yüz) ve `packages/namaz_backend/test/architecture_test.dart` (backend) sınırları denetler; ihlal eklenince düştükleri elle doğrulandı: [[test-stratejisi]].
4. **Metin ve dil kararı ön yüzdedir.** Backend bildirim metnini üretmez; `NotificationTexts` portu ile ön yüzden alır.

## Başlangıç sırası

1. `main()` → `NamazBackend.create(config)`: ayarlar (`shared_preferences`), takip başlangıç günü, veritabanı, bildirim servisi, arka plan görevi kaydı. **İzin penceresi açmaz.**
2. `ProviderScope(overrides: [backendProvider...])` ile `runApp`.
3. İlk ekran çizildikten sonra `HomeScreen` izinleri sırayla ister: [[izinler]].

## Örnek veri akışı: bir vakti işaretlemek

1. Kullanıcı kartı dokunur → `HomeScreen` diyalog açar ([[namaz-isaretleme]]).
2. Sonuç `TodayRecordsNotifier` üzerinden `NamazBackend.markPerformed(...)` çağırır.
3. Backend kaydı yazar ve bildirimleri **kendisi** yeniden planlar (ön yüz bilmez): [[bildirimler]].
4. Sağlayıcı bugünün kayıtlarını yeniden okur, `StatsVersion` sayacını artırır, kaza listesini geçersiz kılar: [[durum-yonetimi]].

## Hangi sayfaya bakmalı

| Konu | Sayfa |
|---|---|
| Backend'in herkese açık yüzü ve kuralları | [[backend-paketi]] |
| Veritabanı, tarih biçimi | [[veri-katmani]] |
| Ayarlar | [[ayarlar-ve-kalicilik]] |
| Sağlayıcılar | [[durum-yonetimi]] |
| Vakit hesabı | [[namaz-vakitleri]] |
| Gün sınırı, sayaç | [[takip-gunu-ve-sayac]] |
| Konum | [[konum]] |
| Bildirim ve izin | [[bildirimler]], [[izinler]] |
| Ekranlar ve tema | [[ui-ekranlar]], [[tema-sistemi]] |
| İkon ve metin kuralları | [[ikon-sistemi]], [[metin-sistemi]] |
| Paketler | [[bagimliliklar]] |
| Platform ayarları | [[android-yapilandirma]], [[ios-yapilandirma]] |

## İlgili sayfalar

[[proje-ozeti]] · [[backend-paketi]] · [[011-front-backend-ayrimi]] · [[006-riverpod-durum-yonetimi]]
