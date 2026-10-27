# Zikir Paylaşımı (Sosyal Medyadan Yakalama)

Kullanıcı bir sosyal medya gönderisini "Paylaş → Namaz Takip" ile uygulamaya gönderir; uygulama paylaşılan metinden veya bağlantıdan zikir bilgisini ayıklayıp düzenlenebilir bir taslak gösterir. Defterin kendisi: [[ui-ekranlar]] ("Zikir ve Esma Defteri").

## Akış

1. **Android:** `AndroidManifest.xml` içindeki `ACTION_SEND` (`text/plain`) süzgeci, `MainActivity.kt` metni alır. Uygulama kapalıyken ilk metin `takeInitialSharedText` ile, açıkken `onSharedText` ile Dart'a gider (kanal `com.namaztakip.app/share`). iOS tarafı `ShareExtension` ve `namaztakip://share` URL şemasıyla yapılmıştır; iOS bu sayfada doğrulanmış sayılmaz.
2. **`ShareService`** (`packages/namaz_backend/lib/src/platform/share_service.dart`): metindeki ilk bağlantıyı bulur, sayfayı çekip `og:description`, `og:title` ve `description` etiketlerini okur (ilk 120 KB, 5-6 sn zaman aşımı).
3. **`extractDhikrDraft`** (saf Dart, `domain/dhikr_extractor.dart`): Esmaül Hüsna ve tesbihat kataloğundan eşleşme, "Ya <Esma>" kalıbı, "100 defa" gibi hedef sayı, "sabah namazından sonra" gibi vakit, Arapça blok, grup tahmini.
4. İsteğe bağlı **Gemini** zenginleştirmesi (anahtar girilmişse).
5. `DhikrEditorSheet` taslağı gösterir; kullanıcı düzenleyip kaydeder.

## Açıklaması okunamayan bağlantılar

Instagram, giriş yapmamış istemciye açıklama vermez: sayfa 200 döner ama hiç `og:` etiketi yoktur (2026-10-27'de `curl` ve uygulamanın tarayıcı kimliğiyle doğrulandı). Instagram'ın paylaş menüsü de çoğunlukla yalnızca bağlantı gönderir. Bu yüzden Instagram bağlantısından zikir **çıkarılamaz**.

Bu durum artık açıkça ele alınır:

- `isCaptionMissing(rawInput, scrapedCaption)` (saf fonksiyon): bağlantı var, bağlantı dışında kullanıcı metni yok ve kazınan açıklama boşsa `true`.
- `DhikrDraft.captionUnavailable` bu durumda `true` olur. Taslakta bilgi yoktur ("Paylaşılan Zikir", 33).
- Bu durumda Gemini'ye **istek atılmaz** (gönderilecek metin yok, bağlantı Google'a gitmez).
- Düzenleme sayfası yeşil "otomatik çıkarıldı" çubuğu yerine uyarı gösterir: açıklamayı kopyalayıp yapıştırın ve tekrar kazıyın veya elle girin; "Bağlantıyı aç ve açıklamayı kopyala" düğmesi bağlantıyı dış uygulamada açar.
- Kullanıcı açıklamayı yapıştırıp "Videodan / Metinden Kazı"ya basınca taslak dolar, uyarı kalkar (emülatörde doğrulandı).

`og:description` yayınlayan sayfalarda kazıma çalışır (yerel sunucuyla test edildi). YouTube, TikTok ve benzeri gerçek sitelerle denenmedi.

## Kazıma hatası düzeltildi

`og:description` içeriği çift tırnakla sarılıysa içindeki kesme işareti (`Ya Rezzak'ın`) eski düzenli ifadede değeri kesiyordu; Türkçe metinde çok sık görülür. Tek ve çift tırnak artık ayrı yakalanır. `share_service_test.dart` bunu denetler (eski ifadeyle düştüğü elle doğrulandı).

## Gemini (isteğe bağlı)

| Konu | Durum |
|---|---|
| Anahtar | Ayarlar → Sosyal Medya Zikir Kazıma. `SharedPreferences`'ta düz metin saklanır; yedekleme kapalı olduğu için buluta gitmez ([[android-yapilandirma]]) |
| İstek | `gemini-2.5-flash`; anahtar **başlıkta** (`x-goog-api-key`) gider, URL'de değil |
| Gizlilik | Anahtar girilirse paylaşılan metin ve kazınan açıklama Google'a gönderilir; ayar ekranındaki yardım metni bunu söyler |
| Anahtarsız | Yerleşik sözlük ve düzenli ifadeler ücretsiz çalışır |

Gizlilik politikası ve veri silme/dışa aktarma hâlâ yoktur: [[bilinen-sorunlar]].

## Testler

`packages/namaz_backend/test/dhikr_test.dart` (ayıklama, kayıt) ve `share_service_test.dart` (yerel `HttpServer` ile uçtan uca: açıklamasız sayfa, kesme işaretli ve tek tırnaklı meta, 404, düz metin, `isCaptionMissing`). Sayılar: [[test-stratejisi]].

Elle deneme (Instagram kurmadan), emülatörde:

```bash
adb shell "am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT 'Rızık için sabah namazından sonra 100 defa Ya Rezzak https://www.instagram.com/p/XXXX/' -n com.namaztakip.app/com.namaztakip.namaz_takip.MainActivity"
```

Gerçek Instagram uygulamasından paylaşım denenmedi (kurulum Google ve Instagram hesabı girişi gerektirir): [[emulator-test-notlari]].

## İlgili sayfalar

[[ui-ekranlar]] · [[backend-paketi]] · [[test-stratejisi]] · [[bilinen-sorunlar]] · [[izinler]]
