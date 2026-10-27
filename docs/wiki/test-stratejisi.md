# Test Stratejisi

Uygulamanın mantığı backend paketinde saf fonksiyonlarda ve ince katmanlarda tutulduğu için testlerin çoğu backend'in birim testidir. Ön yüzde yalnızca metin/ikon sistemi ve mimari sınırlar testlenir. Arayüz ve eklenti davranışı emülatörde elle doğrulanır.

## Çalıştırma

İki paket vardır ve ikisinin testi ayrı çalıştırılır:

```bash
flutter analyze                                  # tüm workspace; temiz olmalı
flutter test                                     # ön yüz testleri (kökte)
(cd packages/namaz_backend && flutter test)      # backend testleri
```

Durum (2026-10-27): `flutter analyze` temiz; ön yüz **29**, backend **76**, toplam **105 test geçiyor**.

## Test dosyaları

| Dosya | Test | Kapsam |
|---|---|---|
| `packages/namaz_backend/test/domain_test.dart` | 21 | `prayerDay` (04:00 kuralı, ay başı), `dateKey`, seri hesabı, `nextPrayer`, İstanbul vakitlerinin makul olması ve güneş doğuşu 1,5 dk ihtiyat payı |
| `packages/namaz_backend/test/prayer_repository_test.dart` | 12 | Bellek içi SQLite: tekrar işaretleme, kaza türetme, kaza etme, `dailyCounts`, `fullDays`, `performedByPrayer`; geçici dizinde gerçek dosyalarla bozuk veritabanı yedekleme ve sıfırlama |
| `packages/namaz_backend/test/notification_plan_test.dart` | 9 | Bildirim kimlikleri, çift bildirim yok, geçmiş vakit, önceki vakti sorma, hatırlatma süresi, payload, 81 il |
| `packages/namaz_backend/test/notification_scheduler_test.dart` | 9 | Planlayıcı kuyruğu: konum yok, bildirim kapalı, tek çağrı, eşzamanlı çağrı örtüşmez, hızlı çağrılar birleşir, hata sonrası kilitlenmez, geçmişe düşen ve geçmiş zaman hatası fırlatan öğeler kalan planı durdurmaz (sahte `NotificationGateway`, bellek içi SQLite, sahte `SharedPreferences`) |
| `packages/namaz_backend/test/time_zone_instant_test.dart` | 2 | `TZDateTime.from` mutlak anı korur (zamanlama `tz.local`'e bağlı değil) |
| `packages/namaz_backend/test/dhikr_test.dart` | 10 | Zikir ayıklama (Esma, sayı, vakit, bağlantı) ve zikir kaydı |
| `packages/namaz_backend/test/share_service_test.dart` | 9 | Yerel `HttpServer` ile paylaşım kazıma: açıklamasız sayfa (`captionUnavailable`), kesme işaretli ve tek tırnaklı meta, 404, düz metin, `isCaptionMissing` |
| `packages/namaz_backend/test/architecture_test.dart` | 4 | Backend arayüz paketi kullanmaz, `domain/` saf, katman yönleri, tek barrel |
| `test/central_system_test.dart` | 12 | Metin ve ikon sistemi, `turkishUpper`, `foldTurkish`, merkezileştirme koruma kuralları |
| `test/startup_error_app_test.dart` | 4 | Başlatma hata ekranı (mesaj, ayrıntı, "Tekrar dene"; veri silen eylem yok) ve bozuk veritabanı kurtarma uyarısı (`CorruptedDatabaseCard`) |
| `test/notification_health_card_test.dart` | 6 | Uyarı kartı: izin yokken görünür, izin varken/bildirim kapalıyken görünmez, düğme ayarı açar, "yok → var" geçişinde bir kez yeniden planlar (sahte `NamazBackend`) |
| `test/architecture_test.dart` | 7 | Ön yüz `src/` ve backend-only paketleri içe aktarmaz, `pubspec.yaml` temiz, `backendProvider` kullanımı sınırlı, `AppNotificationTexts` adaptörü |

Sayılar 2026-10-27 itibarıyladır; test eklenince bu tablo güncellenir.

## Koruma testleri

`central_system_test.dart` kod tabanını tarar:

1. `lib/` içinde emoji yok.
2. `Icons.xxx` yalnızca `core/icons/app_icons.dart` içinde.
3. `lib/ui/` içinde Türkçe harf içeren sabit metin yok.

Bu üç kural [[ikon-sistemi]] ve [[metin-sistemi]] kurallarının otomatik denetimidir.

## Veritabanı testleri

`sqflite_common_ffi` ile masaüstünde bellek içi veritabanı açılır; `AppDatabase.openInMemory()` bunun içindir: [[veri-katmani]].

## Kapsanmayanlar (bilinçli)

- **Widget testleri sınırlıdır:** yalnızca başlatma hata ekranı ve bildirim sağlığı kartı. Diğer ekranlar emülatörde elle gezilir: [[emulator-test-notlari]].
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
