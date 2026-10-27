# Güvenlik ve Kalite Analizi (Antigravity Kodu)

2026-10-27. Kapsam: `7a9a79a` (zikir yakalayıcı) ve onay bekleyen çalışma ağacındaki Antigravity kodu (widget, kıble, Hicri takvim, kaza borcu, esma kataloğu, tesbihat). Yöntem: kaynak okuma, `grep`, çalışan testler, emülatörde deneme. Bulgular düzeltildiyse "Düzeltildi" yazılıdır; diğerleri [[bilinen-sorunlar]]'dadır. Yapay zeka tarafından yazılmış kod olduğu için dış girdiye açılan her nokta ayrıca incelendi.

## Güvenlik

| # | Önem | Bulgu | Durum |
|---|---|---|---|
| 1 | Orta | `openUrl` her şemayı açıyordu (`Uri.parse(url)` + `ACTION_VIEW`). Bağlantı paylaşılan metinden veya elle yazılan alandan gelir; `file:`, `tel:`, `intent:` açılabilirdi. | **Düzeltildi:** Dart (`isSafeWebUrl`) ve Kotlin yalnızca `http`/`https` ve ana makine adı olan bağlantıyı açar. Test: `share_service_test.dart` |
| 2 | Orta | Gemini anahtarı URL'deydi (`?key=`), adres günlüklerde ve geçmişte görünebilir. | **Düzeltildi:** `x-goog-api-key` başlığı |
| 3 | Orta | Yapay zeka yanıtındaki `targetCount` doğrulanmıyordu (1e15, negatif). | **Düzeltildi:** `sanitizeTargetCount` 1-100000 dışını reddeder, yerel taslağa döner |
| 4 | Düşük | Kazıma gövdeyi `await for` ile süre sınırsız okuyordu; parça parça yavaş yanıt veren sunucu arayüzü "kazınıyor"da tutardı. | **Düzeltildi:** parçalar arası 6 sn, toplam 10 sn, 120 KB |
| 5 | Orta | Kazıma yerel ağ adreslerine (`192.168.x.x`, `127.0.0.1`, `169.254.169.254`) GET atabiliyordu, yönlendirmeler denetlenmeden izleniyordu ve paylaşım gelince kullanıcı onayı olmadan otomatik çalışıyordu (SSRF, cihaz IP'si sızması, anahtar varsa metnin Google'a gitmesi). İlk turda "kabul edildi" yazılmıştı; ikinci denetimde tetikleyicinin sıfır tıklama olduğu görülüp yükseltildi. | **Düzeltildi (2026-10-27, ikinci tur):** `url_guard.dart` ile genel olmayan adresler reddedilir, soket çözülen adrese sabitlenir, yönlendirmeler elle ve her atlamada denetlenir, `http` `https`e yükseltilir; paylaşılan içerik yalnızca kullanıcı "Kazı"ya basınca işlenir. Testler: `url_guard_test.dart`, `shared_consent_test.dart` |
| 6 | Düşük | Gemini anahtarı `SharedPreferences`'ta düz metin. | **Düzeltildi:** `flutter_secure_storage` (Keystore/Keychain); eski düz kopya otomatik taşınır ve silinir. Test: `gemini_key_storage_test.dart` |
| 7 | Düşük | `debugPrint` hata metinleri bağlantı içerebilir (`stkn=` gibi izleme parametreleri); release'te de logcat'e düşer. | Kazıma günlüğü için **düzeltildi** (yalnızca hata türü yazılır). Gemini ve diğer günlükler açık |
| 7b | Orta | iOS `openUrl` şema denetimi yapmıyordu (`UIApplication.open` doğrudan); denetim yalnızca Dart ve Kotlin'deydi. | **Düzeltildi:** `AppDelegate.swift` `isSafeWebUrl`. Derlenmedi; kaynak düzeyinde koruma testi `native_url_guard_test.dart` |
| 7c | Düşük | Gemini yanıtındaki metin alanlarının uzunluğu sınırsız; kazınan sayfa metni istemin içine girer (prompt injection). | Açık: [[zikir-paylasim]] |
| 8 | Bilgi | Widget alıcısı `exported=true` (widget için zorunlu). Özel `WIDGET_REFRESH` eylemini herhangi bir uygulama yollayabilir; sonucu yalnızca yeniden çizimdir. Sistem yayınları (`TIME_SET` vb.) açık süzgeçte. | Zararsız |
| 9 | Bilgi | SQL: tüm sorgular parametreli (`whereArgs`, `?`); dize birleştirme ile SQL yok. Gizli anahtar, ağ çağrısı veya izin genişlemesi (Konum/Bildirim/INTERNET dışında) yok. | Temiz |
| 10 | Orta | iOS paylaşım ve widget uzantıları Xcode projesine eklenmemiş; `Runner.entitlements` projeye bağlı değil (App Group etkin değil). Önceki "iOS entegrasyonu kuruldu" iddiası yanlıştı. | Belgelendi: [[ios-yapilandirma]] |

## Doğruluk (işlevsel kalite)

| # | Önem | Bulgu | Durum |
|---|---|---|---|
| 11 | Yüksek | Android widget bayatlıyordu | **Düzeltildi:** [[ana-ekran-widget]] |
| 12 | Yüksek | Hicri takvim bayramları 1 gün erken veriyordu | **Düzeltildi:** [[hicri-takvim]] |
| 13 | Orta | Kıble konum yokken sabit 151° / 2.400 km gösteriyordu | **Düzeltildi:** [[kible-pusulasi]] |
| 14 | Orta | Regaip kuralı Recep'in 1'i Cuma ise kaçırıyor, 7. günü yanlış işaretliyordu | **Düzeltildi** |
| 15 | Orta | Pusula manyetik kuzeyi kullanıyor, sapma düzeltmesi yok; sensör yoksa akış sessiz | **Düzeltildi (Android):** `GeomagneticField` sapması eklenir, sensör yoksa `NO_SENSOR` hatası ve arayüz uyarısı. iOS derlenmedi: [[kible-pusulasi]] |
| 16 | Orta | Dinî içerik (esma, zikir metinleri, ebced sayıları, kerahat süreleri) kullanıcı onayı bekliyor | **Kısmen:** esma kataloğu 99 isme tamamlandı ve iç tutarlılık testlendi, fazilet ifadeleri kaldırıldı; dinî onay açık: [[dini-icerik-onayi]] |
| 17 | Düşük | Esma anahtar kelimeleri kelime sınırı olmadan alt dizge eşleşir (`ya nur`, `ya semi` başka kelimelerin içinde eşleşebilir) | Açık |

## Kod kalitesi

| # | Önem | Bulgu |
|---|---|---|
| 18 | Orta | **Mimari ilke ihlali:** backend'de Türkçe metin (widget vakit adları, esma kataloğu, `Paylaşılan Zikir` varsayılanı) ve Kotlin'de sabit metin; koruma testi yalnızca `lib/ui`'ı tarıyordu. | **Düzeltildi:** metinler `HomeWidgetTexts` ve `DhikrContent` portlarıyla ön yüzden gelir, Kotlin metin üretmez, backend koruma testi eklendi. Kalan izinli istisnalar: [[metin-sistemi]] |
| 19 | Düşük | Üst çubuk düğmeleri 32 dp (önerilen 48 dp), yazılar 11-17 punto: erişilebilirlik. |
| 20 | Düşük | Dosya boyutu: `dhikr_editor_sheet.dart` 523 satır (eşik 500), `qibla_compass_sheet.dart` 494, `dhikr_catalog.dart` (veri). Uzun `build` metotları. |
| 21 | Düşük | `HapticFeedback` `build` içinde tetikleniyor (yan etki); `initState`/dinleyici daha doğru. |
| 22 | Düşük | `home_widget_service.dart` tüm hataları sessizce yutuyor (`catch (_)`); sorun gizleniyor. |
| 23 | Bilgi | Antigravity'nin yazdığı testler çoğunlukla uygulamanın kendi çıktısını doğrular (Hicri testi Diyanet farkını yakalamıyordu). Bu turda dış doğruluk kaynaklı testler eklendi. |

Test örtüsü: Kotlin widget mantığı, Hicri, kıble sayfası, paylaşım servisi için test eklendi ([[test-stratejisi]]). Hâlâ testsiz: esma kataloğu eşleşmesi, kaza borcu arayüzü, tesbihat sayfası, iOS Swift kodu.

## İlgili sayfalar

[[bilinen-sorunlar]] · [[zikir-paylasim]] · [[ana-ekran-widget]] · [[hicri-takvim]] · [[kible-pusulasi]] · [[denetim-raporu-2026-10-26]]
