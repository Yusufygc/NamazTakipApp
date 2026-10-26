# Wiki Günlüğü

Kronolojik kayıt; en yeni kayıt en üsttedir. Biçim: `## [YYYY-AA-GG] [İŞLEM_TİPİ] | Kısa Açıklama`. İşlem tipleri: INGEST, QUERY, UPDATE, DECISION, LINT, SETUP. Kurallar: [[wiki-kullanim]]. Harita: [[index]].

## [2026-10-26] UPDATE | Geçmiş zamanlı ve hatalı bildirim öğeleri kalan planı durdurmaz
`NotificationScheduler` ve `NotificationService.apply`, plan uygulanırken zamanı geçmişe düşen bildirimleri günlüğe yazıp atlar; tek bir öğenin zamanlanmasında hata oluşursa hatayı `debugPrint` ile günlüğe yazarak kalan bildirimleri planlamaya devam eder. `notification_scheduler_test.dart` içine sahte `NotificationGateway` ile iki yeni test eklendi ve mutasyon kontrolüyle doğrulandı. Testler: ön yüz 29, backend 56 (toplam 85), `flutter analyze` temiz. Sayfalar: [[bildirimler]], [[backend-paketi]], [[bilinen-sorunlar]], [[test-stratejisi]].

## [2026-10-26] UPDATE | Bozuk veritabanı silinmeden önce yedeklenir ve kullanıcı uyarılır
`AppDatabase.open` mevcut veritabanı dosyasını açmadan önce ham baytlarını belleğe alır; SQLite 3 başlığı (`"SQLite format 3\x00"`), `PRAGMA integrity_check` veya `prayers` tablosu kontrolü başarısız olursa (ya da Android `DefaultDatabaseErrorHandler` dosyayı sıfırlarsa) özgün dosyayı `namaz_takip.db.bozuk-<zaman>` adıyla yedekler, temiz veritabanı açar ve ön yüzde `CorruptedDatabaseCard` ile kullanıcıyı bilgilendirir. Dosya tabanlı testler, mutasyon kontrolü ve Android emülatöründe (rastgele 256 baytlı bozuk dosya, SHA-256 eşleşmesi ve uyarı kartı) doğrulandı. Testler: ön yüz 29, backend 54 (toplam 83), `flutter analyze` temiz. Sayfalar: [[veri-katmani]], [[backend-paketi]], [[ayarlar-ve-kalicilik]], [[durum-yonetimi]], [[ui-ekranlar]], [[metin-sistemi]], [[bilinen-sorunlar]], [[test-stratejisi]], [[emulator-test-notlari]].

## [2026-10-26] REVIEW | Denetim raporunun yüksek öncelikli 7 bulgusu uygulandı
#1 yedekleme kapatıldı; #2 release imzası anahtarsız derlemeyi durdurur; #3 tam zamanlı alarm izni yoksa ana ekranda uyarı kartı; #4 gün sınırı `min(04:00, Sabah)`; #5 bildirim planlayıcı sıraya alındı; #6 başlangıç hata ekranı ve hata kancaları. #7 yanlış alarm çıktı (saat dilimi ve eklenti kaynağıyla doğrulandı), rapordan geri çekildi. Testler: ön yüz 27, backend 51, `flutter analyze` temiz. Doğrulanmayanlar: gerçek release anahtarı üretilmedi, gerçek cihaz yok. Yeni iki bulgu çözülmedi (bozuk veritabanı sessizce siliniyor, geçmiş zamanlı bildirim planı durduruyor): [[bilinen-sorunlar]]. Sayfalar: [[denetim-raporu-2026-10-26]], [[bildirimler]], [[takip-gunu-ve-sayac]], [[derleme-ve-yayin]], [[test-stratejisi]], [[emulator-test-notlari]].

## [2026-10-26] REVIEW | Denetim raporu hazırlandı (V2 şablonu + AI metodolojisi)
Kod ve süreç iki kaynak dokümana göre ölçüldü ve incelendi: 24 bulgu (kritik yok, 7 yüksek), eşik ölçümleri, metodoloji uyum denetimi. Hiçbir düzeltme uygulanmadı; onay bekleniyor. Rapor: [[denetim-raporu-2026-10-26]]. İlgili: [[bilinen-sorunlar]], [[yol-haritasi]].

## [2026-10-26] DECISION | Ön yüz ve backend ayrı paketlere bölündü
Backend `packages/namaz_backend/` paketine taşındı (pub workspace); ön yüz yalnızca `NamazBackend` arayüzünü ve sade modelleri kullanıyor. İş kuralları sağlayıcılardan backend'e taşındı, bildirim metinleri `NotificationTexts` portuna alındı, iki `architecture_test.dart` sınırı denetliyor. Wiki yolları ve mimari sayfaları güncellendi; temiz kurulumda tam zamanlı alarm izninin kapalı kalabildiği bulundu. Sayfalar: [[mimari-genel]], [[backend-paketi]], [[durum-yonetimi]], [[bildirimler]], [[test-stratejisi]], [[bilinen-sorunlar]]. Karar: [[011-front-backend-ayrimi]].

## [2026-10-26] LINT | İlk bağlantı denetimi yapıldı
47 sayfa betikle tarandı: kırık bağlantı, öksüz sayfa, dizinde eksik sayfa ve "İlgili sayfalar" bölümü eksik sayfa yok. Yazım sırasında kodla çelişen üç iddia bulunup düzeltildi (`intl` kullanımı, "sıradaki" vurgusunun tarih kontrolü, ilk derleme süreleri); eski uygulamanın `reminder_settings` tablosunun kullanılmadığı `main` branch'inde doğrulandı. Kalan bilinen sorunlar [[bilinen-sorunlar]] sayfasındadır.

## [2026-10-26] SETUP | Wiki sistemi kuruldu
`CLAUDE.md` anayasası, `docs/wiki/` (47 sayfa: index, log, proje, mimari, özellikler, arayüz, platform, süreç ve 10 karar kaydı) ve `docs/raw/` eklendi. Sayfalar kodun ve emülatör testlerinin gerçek durumundan yazıldı. Karar: [[010-wiki-sistemi]]. Başlangıç noktası: [[index]].

## [2026-10-26] UPDATE | Merkezi ikon ve modüler metin sistemi
`lib/core/icons/app_icons.dart` ve `lib/core/strings/` eklendi; tüm emoji ve sabit metinler taşındı; koruma testi yazıldı. Sayfalar: [[ikon-sistemi]], [[metin-sistemi]]. Karar: [[008-merkezi-ikon-ve-metin]].

## [2026-10-26] UPDATE | React Native kalıntıları silindi, Flutter kök dizine taşındı
Expo kaynakları ve şablon dosyaları silindi; launcher ikonları gerçek `AppIcon.png`'den üretildi. Sayfalar: [[gecis-gecmisi]], [[uygulama-ikonu]], [[derleme-ve-yayin]].

## [2026-10-26] UPDATE | Emülatör testi ve düzeltmeler
Android 36 emülatöründe test turu: izin sırası, GPS yedek zinciri ve kontrast hataları düzeltildi; bildirim zamanında ateşlendi. Sayfalar: [[emulator-test-notlari]], [[izinler]], [[konum]], [[erisilebilirlik-ve-kontrast]]. Karar: [[009-konum-yedek-zinciri]].

## [2026-10-26] DECISION | Flutter'a geçiş ve yeniden yazım
React Native/Expo yerine Flutter; vakitler cihazda, tarihler ISO, kaza türetilir, bildirim kimlikleri sabit. Kararlar: [[001-flutter-gecisi]], [[002-vakitler-cihazda-hesaplanir]], [[003-iso-tarih-formati]], [[004-sabit-bildirim-kimlikleri]], [[005-kaza-turetilir]], [[006-riverpod-durum-yonetimi]], [[007-sqflite-secimi]].
