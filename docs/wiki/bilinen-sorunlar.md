# Bilinen Sorunlar ve Sınırlar

Henüz çözülmemiş sorunlar, doğrulanmamış alanlar ve bilinçli sınırlar. Çözülen bir madde buradan silinir ve [[log]] dosyasına işlenir. Önem: **Yüksek** = yayından önce çözülmeli, **Orta** = kullanıcıyı etkileyebilir, **Düşük** = kozmetik veya nadir.

## Doğrulanmamış alanlar

| Önem | Konu | Ayrıntı |
|---|---|---|
| Yüksek | iOS hiç derlenmedi | `Info.plist`, `AppDelegate`, arka plan kimliği kaynak koddan yazıldı; ilk derlemede hata olası: [[ios-yapilandirma]] |
| Orta | Tam zamanlı alarm izni kullanıcıya bağlı | Ana ekranda uyarı kartı ve "Ayarları aç" düğmesi var; izin verilince alarmlar otomatik tam zamanlıya çevrilir (emülatörde doğrulandı). Kullanıcı izni vermezse bildirimler yine **bir saate kadar geç** gelir: [[izinler]], [[bildirimler]] |
| Düşük | Ön plan ile arka plan izolatı aynı anda planlarsa serileştirme geçerli değil | `NotificationScheduler` kuyruğu tek izolat içindir; sabit kimlikler zararı sınırlar: [[bildirimler]] |
| Düşük | Gizlilik politikası ve veri silme/dışa aktarma yok | Yedekleme kapatıldı; mağaza yayını için yasal metin ve kullanıcı eylemleri gerekir: [[android-yapilandirma]], [[yol-haritasi]] |
| Orta | Instagram bağlantısından zikir çıkarılamaz | Instagram giriş yapmamış istemciye açıklama vermez; kullanıcı açıklamayı yapıştırmalıdır (uyarı ve yönlendirme var). Gerçek Instagram paylaşımı ve iOS paylaşım uzantısı denenmedi: [[zikir-paylasim]] |
| Düşük | Gemini anahtarı düz metin saklanıyor | `SharedPreferences`, yedekleme kapalı; güvenli depolama (Keystore) kullanılmıyor: [[zikir-paylasim]] |
| Orta | iOS paylaşım ve widget uzantıları Xcode projesinde yok | `project.pbxproj`'da iki hedef ve `Runner.entitlements` bağlantısı bulunmuyor; iOS'ta paylaşım ve widget çalışmaz. Mac ve Xcode gerekir: [[ios-yapilandirma]] |
| Orta | Hicri tablo 7 Mayıs 2027'de bitiyor | Sonrası Kuveyt algoritmasına düşer ve bayram/kandil bir gün kayabilir; 1449 Diyanet ilanıyla `hijri_month_starts.dart`'a eklenmeli. Tablo Diyanet'e dayanan yayınlardan derlendi, resmî tablo değil: [[hicri-takvim]] |
| Orta | Dinî içerik doğrulanmadı | Esma kataloğu (44 giriş), fazilet metinleri, ebced sayıları, kerahat süreleri (45/30/40 dk) ve kandil kuralları dinî kaynaktan onay bekliyor: [[hicri-takvim]], [[guvenlik-ve-kalite-analizi]] |
| Düşük | Pusula gerçek cihazda denenmedi | Android'de manyetik sapma düzeltiliyor ve sensör yoksa açık uyarı var; iOS `trueHeading` konum güncellemesi kapalıyken manyetik açıya düşebilir. Cihaz düz tutulmalı, tolerans ±5°: [[kible-pusulasi]] |
| Orta | Backend ve Kotlin'de sabit Türkçe metin | `home_widget_snapshot.dart`, esma kataloğu, varsayılan başlık, widget Kotlin metinleri metin sistemi dışında; koruma testi `lib/ui`'ı tarıyor: [[guvenlik-ve-kalite-analizi]] |
| Düşük | Widget Doze'da birkaç dakika gecikebilir, durdurulmuş uygulamada yenilenmez | Yaklaşık zamanlı alarm kullanılıyor (tam zamanlı alarm izni istenmedi). Gerçek cihazda üretici başlatıcıları denenmedi: [[ana-ekran-widget]] |
| Yüksek | Gerçek telefonda test yok | Bildirim zamanlaması, pil kısıtlamaları (agresif tasarruf yapan üreticiler), GPS ve performans yalnızca emülatörde görüldü: [[bildirimler]] |
| Orta | Dört tema görsel test edilmedi | Koyu, Okyanus, Gül, Altın; kontrast sorunları çıkabilir: [[tema-sistemi]] |
| Orta | Arka plan görevinin periyodik tetiklenmesi gözlenmedi | 12 saatlik görev emülatör oturumuna sığmadı: [[arka-plan-gorevleri]] |
| Orta | Vakitler resmî Diyanet takvimiyle karşılaştırılmadı | Aladhan Diyanet yöntemiyle ≤ 2 dk fark ölçüldü; resmî tabloyla değil: [[namaz-vakitleri]] |
| Orta | Uygulama öldürülmüşken bildirim ateşlenmesi test edilmedi | Alarmlar sistemde kayıtlı, ama bu senaryo denenmedi: [[bildirimler]] |
| Düşük | Ekran okuyucu (TalkBack/VoiceOver) ile test yok | Etiketler koddan yazıldı: [[erisilebilirlik-ve-kontrast]] |
| Düşük | Gün geçişi kış ve gece yarısı için canlı izlenmedi | Sabah vakti sınırı (yaz, haziran 03:30) birim testli ve emülatörde doğrulandı; kış 04:00 geçişi birim testli, canlı izlenmedi: [[takip-gunu-ve-sayac]] |
| Düşük | Android 13 temalı ikon ve iOS ikonu görsel denenmedi | [[uygulama-ikonu]] |

## Yayın engelleri

| Önem | Konu | Ayrıntı |
|---|---|---|
| Yüksek | Gerçek release anahtarı henüz üretilmedi | Anahtarsız release derlemesi bilerek durur (`ALLOW_DEBUG_SIGNING=1` ile yan yükleme testi mümkün). Mağaza için keystore üretilip `android/key.properties` yazılmalı: [[derleme-ve-yayin]] |
| Orta | iOS bundle id Android'den farklı | `com.namaztakip.namazTakip` vs `com.namaztakip.app`: [[ios-yapilandirma]] |
| Düşük | Sürüm numarası iki yerde elle tutuluyor | `pubspec.yaml` ve `CommonStrings.version`: [[metin-sistemi]] |

## Teknik borç

| Önem | Konu | Ayrıntı |
|---|---|---|
| Orta | `workmanager_android` eski Kotlin eklentisini kullanıyor | Flutter ileride uyarıyı hataya çevirebilir; paket güncellemesi izlenmeli: [[bagimliliklar]] |
| Düşük | Ön yüzde yalnızca üç widget/kart testi grubu var (hata ekranı, bozuk veritabanı uyarısı, bildirim sağlığı kartı); ekranların çoğu testsiz | Mantık backend'de testlidir: [[test-stratejisi]], [[backend-paketi]] |
| Düşük | Radar paydası ve karşılaştırma farkı için birim test yok | Hesap backend'de (`NamazBackendImpl`) ama doğrudan testi yok: [[istatistikler]] |
| Düşük | Backend içinde depolar için soyut arayüz yok | Sınır `NamazBackend` arayüzündedir; repository'ler somut sınıflardır: [[011-front-backend-ayrimi]] |
| Düşük | `flutter_launcher_icons` proje dosyasını bozuyor | Her üretimde elle geri alınmalı: [[uygulama-ikonu]] |

## Arayüz tutarsızlıkları

| Önem | Konu | Ayrıntı |
|---|---|---|
| Düşük | Gece 00:00–04:00 arası "sıradaki" vurgusu dünün listesinde | Vurgu vakit türüne bakar, tarihe bakmaz: [[takip-gunu-ve-sayac]] |
| Düşük | Aylık karşılaştırma grafiği alt etiket aralığı sabit (5) | 30 günlük görünümde etiketler seyrek |

## Ürün sınırları (hata değil)

- Takip başlangıcından önceki kaza namazları sistemde yok: [[kaza-sistemi]], [[yol-haritasi]].
- Bildirim pencereleri sınırlıdır (Android 10 gün, iOS 6 gün); uygulama ve arka plan görevi uzun süre çalışmazsa bildirim biter: [[bildirimler]].
- Konum adı cihazın geocoder'ına bağlıdır; Google hizmetleri yoksa il adı yerine koordinat görünebilir: [[konum]].
- Yüksek enlem kuralları ayarlanmadı; kutba yakın konumlar desteklenmez: [[namaz-vakitleri]].
- Tema sistemi açık/koyu ayarını izlemez: [[tema-sistemi]].

## İlgili sayfalar

[[yol-haritasi]] · [[emulator-test-notlari]] · [[test-stratejisi]]
