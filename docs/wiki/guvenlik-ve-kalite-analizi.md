# Güvenlik ve Kalite Analizi (Antigravity Kodu)

2026-10-27. Kapsam: `7a9a79a` (zikir yakalayıcı) ve onay bekleyen çalışma ağacındaki Antigravity kodu (widget, kıble, Hicri takvim, kaza borcu, esma kataloğu, tesbihat). Yöntem: kaynak okuma, `grep`, çalışan testler, emülatörde deneme. Bulgular düzeltildiyse "Düzeltildi" yazılıdır; diğerleri [[bilinen-sorunlar]]'dadır. Yapay zeka tarafından yazılmış kod olduğu için dış girdiye açılan her nokta ayrıca incelendi.

## Güvenlik

| # | Önem | Bulgu | Durum |
|---|---|---|---|
| 1 | Orta | `openUrl` her şemayı açıyordu (`Uri.parse(url)` + `ACTION_VIEW`). Bağlantı paylaşılan metinden veya elle yazılan alandan gelir; `file:`, `tel:`, `intent:` açılabilirdi. | **Düzeltildi:** Dart (`isSafeWebUrl`) ve Kotlin yalnızca `http`/`https` ve ana makine adı olan bağlantıyı açar. Test: `share_service_test.dart` |
| 2 | Orta | Gemini anahtarı URL'deydi (`?key=`), adres günlüklerde ve geçmişte görünebilir. | **Düzeltildi:** `x-goog-api-key` başlığı |
| 3 | Orta | Yapay zeka yanıtındaki `targetCount` doğrulanmıyordu (1e15, negatif). | **Düzeltildi:** `sanitizeTargetCount` 1-100000 dışını reddeder, yerel taslağa döner |
| 4 | Düşük | Kazıma gövdeyi `await for` ile süre sınırsız okuyordu; parça parça yavaş yanıt veren sunucu arayüzü "kazınıyor"da tutardı. | **Düzeltildi:** parçalar arası 6 sn, toplam 10 sn, 120 KB |
| 5 | Düşük | Kazıma yalnızca `http/https` olsa da yerel ağ adreslerine (`192.168.x.x`, `127.0.0.1`) GET atabilir; `ACTION_SEND` süzgeci dışa açık olduğu için başka uygulama bağlantı yollayabilir. Yanıt yalnızca yerel taslağa (ve anahtar varsa Gemini'ye) gider, saldırgana dönmez. | Kabul edildi, belgeli. Yerel adresleri engellemek istenirse testler de (127.0.0.1 sunucusu) değişmeli |
| 6 | Düşük | Gemini anahtarı `SharedPreferences`'ta düz metin. Yedekleme kapalı ([[android-yapilandirma]]); Keystore kullanılmıyor. | Açık |
| 7 | Düşük | `debugPrint` hata metinleri bağlantı içerebilir (`stkn=` gibi izleme parametreleri); release'te de logcat'e düşer. | Açık |
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
| 18 | Orta | **Mimari ilke ihlali:** backend'de Türkçe metin (`home_widget_snapshot.dart` vakit adları, esma kataloğu, `Paylaşılan Zikir` varsayılanı) ve Kotlin'de sabit metin. Koruma testi yalnızca `lib/ui`'ı tarıyor. Düzeltme: metinler ön yüzden verilir veya koruma testi backend'e genişler. |
| 19 | Düşük | Üst çubuk düğmeleri 32 dp (önerilen 48 dp), yazılar 11-17 punto: erişilebilirlik. |
| 20 | Düşük | Dosya boyutu: `dhikr_editor_sheet.dart` 523 satır (eşik 500), `qibla_compass_sheet.dart` 494, `esma_catalog.dart` 465 (veri). Uzun `build` metotları. |
| 21 | Düşük | `HapticFeedback` `build` içinde tetikleniyor (yan etki); `initState`/dinleyici daha doğru. |
| 22 | Düşük | `home_widget_service.dart` tüm hataları sessizce yutuyor (`catch (_)`); sorun gizleniyor. |
| 23 | Bilgi | Antigravity'nin yazdığı testler çoğunlukla uygulamanın kendi çıktısını doğrular (Hicri testi Diyanet farkını yakalamıyordu). Bu turda dış doğruluk kaynaklı testler eklendi. |

Test örtüsü: Kotlin widget mantığı, Hicri, kıble sayfası, paylaşım servisi için test eklendi ([[test-stratejisi]]). Hâlâ testsiz: esma kataloğu eşleşmesi, kaza borcu arayüzü, tesbihat sayfası, iOS Swift kodu.

## İlgili sayfalar

[[bilinen-sorunlar]] · [[zikir-paylasim]] · [[ana-ekran-widget]] · [[hicri-takvim]] · [[kible-pusulasi]] · [[denetim-raporu-2026-10-26]]
