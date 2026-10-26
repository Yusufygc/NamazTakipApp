# Test Stratejisi

Uygulamanın mantığı saf fonksiyonlarda ve ince katmanlarda tutulduğu için testlerin çoğu birim testtir. Arayüz ve eklenti davranışı emülatörde elle doğrulanır.

## Çalıştırma

```bash
flutter analyze   # statik analiz; temiz olmalı
flutter test      # tüm testler
```

Durum (2026-10-26): `flutter analyze` temiz, **44 test geçiyor**.

## Test dosyaları

| Dosya | Test | Kapsam |
|---|---|---|
| `test/core_test.dart` | 14 | `prayerDay` (04:00 kuralı, ay başı), `dateKey`, seri hesabı, `nextPrayer`, İstanbul vakitlerinin makul olması |
| `test/prayer_repository_test.dart` | 9 | Bellek içi SQLite: tekrar işaretleme, kaza türetme, kaza etme, `dailyCounts`, `fullDays`, `performedByPrayer` |
| `test/notification_plan_test.dart` | 9 | Bildirim kimlikleri, çift bildirim yok, geçmiş vakit, önceki vakti sorma, hatırlatma süresi, payload, 81 il |
| `test/central_system_test.dart` | 12 | Metin ve ikon sistemi, `turkishUpper`, `foldTurkish`, merkezileştirme koruma kuralları |

Sayılar 2026-10-26 itibarıyladır (toplam 44); test eklenince bu tablo güncellenir.

## Koruma testleri

`central_system_test.dart` kod tabanını tarar:

1. `lib/` içinde emoji yok.
2. `Icons.xxx` yalnızca `core/icons/app_icons.dart` içinde.
3. `lib/ui/` içinde Türkçe harf içeren sabit metin yok.

Bu üç kural [[ikon-sistemi]] ve [[metin-sistemi]] kurallarının otomatik denetimidir.

## Veritabanı testleri

`sqflite_common_ffi` ile masaüstünde bellek içi veritabanı açılır; `AppDatabase.openInMemory()` bunun içindir: [[veri-katmani]].

## Kapsanmayanlar (bilinçli)

- **Widget testi yok.** Ekranlar emülatörde elle gezilir: [[emulator-test-notlari]].
- **Riverpod sağlayıcıları** ayrıca test edilmez; mantıkları servis ve repository'dedir: [[durum-yonetimi]]. İstatistik radar paydası ve karşılaştırma farkı sağlayıcı içindedir ve testsizdir: [[istatistikler]].
- **Eklentiler** (konum, bildirim, workmanager) birim testte çağrılmaz; yalnızca etraflarındaki karar kodu testlenir: [[bildirimler]], [[konum]].
- **Aladhan karşılaştırması** otomatik değil, elle yapıldı: [[namaz-vakitleri]].

## Elle test kontrol listesi (emülatör veya cihaz)

1. Temiz kurulum → ilk açılışta boş splash yok, önce konum sonra bildirim izni: [[izinler]].
2. GPS konumu ve şehir adı; elle şehir seçimi.
3. Vakit kartları ve sayaç; Yatsı'dan sonra Sabah'a geçiş.
4. Kıldım (cemaatli/cemaatsiz), Kılmadım, tekrar işaretleme.
5. Kaza listesi, "Kaza Et"; rozetlerde cemaat sayısı.
6. Süreç: radar, ısı haritası, haftalık/aylık.
7. Ayarlar: bildirim, hatırlatma süresi, yöntem, konum modu, beş tema.
8. Bildirim: zamanında gelir, metin doğru, dokununca doğru diyalog.
9. Saati bildirim anına alma: [[gelistirme-ortami]].

## İlgili sayfalar

[[derleme-ve-yayin]] · [[emulator-test-notlari]] · [[mimari-genel]]
