# Bilinen Sorunlar ve Sınırlar

Henüz çözülmemiş sorunlar, doğrulanmamış alanlar ve bilinçli sınırlar. Çözülen bir madde buradan silinir ve [[log]] dosyasına işlenir. Önem: **Yüksek** = yayından önce çözülmeli, **Orta** = kullanıcıyı etkileyebilir, **Düşük** = kozmetik veya nadir.

## Doğrulanmamış alanlar

| Önem | Konu | Ayrıntı |
|---|---|---|
| Yüksek | iOS hiç derlenmedi | `Info.plist`, `AppDelegate`, arka plan kimliği kaynak koddan yazıldı; ilk derlemede hata olası: [[ios-yapilandirma]] |
| Yüksek | Gerçek telefonda test yok | Bildirim zamanlaması, pil kısıtlamaları (agresif tasarruf yapan üreticiler), GPS ve performans yalnızca emülatörde görüldü: [[bildirimler]] |
| Orta | Dört tema görsel test edilmedi | Koyu, Okyanus, Gül, Altın; kontrast sorunları çıkabilir: [[tema-sistemi]] |
| Orta | Arka plan görevinin periyodik tetiklenmesi gözlenmedi | 12 saatlik görev emülatör oturumuna sığmadı: [[arka-plan-gorevleri]] |
| Orta | Vakitler resmî Diyanet takvimiyle karşılaştırılmadı | Aladhan Diyanet yöntemiyle ≤ 2 dk fark ölçüldü; resmî tabloyla değil: [[namaz-vakitleri]] |
| Orta | Uygulama öldürülmüşken bildirim ateşlenmesi test edilmedi | Alarmlar sistemde kayıtlı, ama bu senaryo denenmedi: [[bildirimler]] |
| Düşük | Ekran okuyucu (TalkBack/VoiceOver) ile test yok | Etiketler koddan yazıldı: [[erisilebilirlik-ve-kontrast]] |
| Düşük | 04:00 gün geçişi canlı izlenmedi | Mantık birim testli: [[takip-gunu-ve-sayac]] |
| Düşük | Android 13 temalı ikon ve iOS ikonu görsel denenmedi | [[uygulama-ikonu]] |

## Yayın engelleri

| Önem | Konu | Ayrıntı |
|---|---|---|
| Yüksek | Release debug anahtarıyla imzalı | Play Store için keystore gerekir: [[derleme-ve-yayin]] |
| Orta | iOS bundle id Android'den farklı | `com.namaztakip.namazTakip` vs `com.namaztakip.app`: [[ios-yapilandirma]] |
| Düşük | Sürüm numarası iki yerde elle tutuluyor | `pubspec.yaml` ve `CommonStrings.version`: [[metin-sistemi]] |

## Teknik borç

| Önem | Konu | Ayrıntı |
|---|---|---|
| Orta | `workmanager_android` eski Kotlin eklentisini kullanıyor | Flutter ileride uyarıyı hataya çevirebilir; paket güncellemesi izlenmeli: [[bagimliliklar]] |
| Düşük | Widget testi yok; sağlayıcılar testsiz | Radar paydası ve karşılaştırma farkı dahil: [[test-stratejisi]], [[istatistikler]] |
| Düşük | `flutter_launcher_icons` proje dosyasını bozuyor | Her üretimde elle geri alınmalı: [[uygulama-ikonu]] |

## Arayüz tutarsızlıkları

| Önem | Konu | Ayrıntı |
|---|---|---|
| Düşük | Çekmece başlığının üstünde durum çubuğu alanı beyaz kalıyor | `NavigationDrawer` kendi güvenli alanını uyguluyor; başlık yeşil durum çubuğunun altına uzanmıyor: [[ui-ekranlar]] |
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
