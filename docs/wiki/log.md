# Wiki Günlüğü

Kronolojik kayıt; en yeni kayıt en üsttedir. Biçim: `## [YYYY-AA-GG] [İŞLEM_TİPİ] | Kısa Açıklama`. İşlem tipleri: INGEST, QUERY, UPDATE, DECISION, LINT, SETUP. Kurallar: [[wiki-kullanim]]. Harita: [[index]].

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
