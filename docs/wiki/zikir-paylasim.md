# Zikir Paylaşımı (Sosyal Medyadan Yakalama)

Kullanıcı bir sosyal medya gönderisini "Paylaş → Namaz Takip" ile uygulamaya gönderir; uygulama paylaşılan metinden veya bağlantıdan zikir bilgisini ayıklayıp düzenlenebilir bir taslak gösterir. Defterin kendisi: [[ui-ekranlar]] ("Zikir ve Esma Defteri").

## Akış

1. **Android:** `AndroidManifest.xml` içindeki `ACTION_SEND` (`text/plain`) süzgeci, `MainActivity.kt` metni alır. Uygulama kapalıyken ilk metin `takeInitialSharedText` ile, açıkken `onSharedText` ile Dart'a gider (kanal `com.namaztakip.app/share`). iOS için kaynak dosyalar yazılmıştır ama uzantı hedefleri Xcode projesine eklenmemiştir; iOS'ta paylaşım şu an çalışmaz: [[ios-yapilandirma]].
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

## Güvenlik önlemleri

Paylaşım kapısı dışa açıktır (`ACTION_SEND` süzgeci), bu yüzden gelen metin güvenilmez sayılır. Ayrıntılı analiz: [[guvenlik-ve-kalite-analizi]].

- **Bağlantı açma:** yalnızca `http`/`https` ve ana makine adı olan bağlantılar dış uygulamada açılır (`isSafeWebUrl`, hem Dart'ta hem `MainActivity.kt`'de). `file:`, `tel:`, `intent:`, `javascript:` açılmaz.
- **Kazıma:** yalnızca `https` (`http` bağlantı otomatik `https`e yükseltilir); parçalar arası 6 sn, toplam 10 sn zaman aşımı, en çok 120 KB.
- **SSRF koruması (`url_guard.dart`):** soket açılmadan önce ad çözülür ve bütün adresler genel internette değilse bağlanılmaz (loopback, `10/8`, `172.16/12`, `192.168/16`, `169.254/16` bulut metadata, CGNAT, çoklu yayın, IPv6 `::1`/`fc00::/7`/`fe80::/10` ve IPv6 içine gömülü iç IPv4). Soket çözülen adrese sabitlenir (`HttpClient.connectionFactory`), sertifika özgün ana makine adına karşı doğrulanır; denetimle bağlantı arasında DNS değişemez. Yönlendirmeler elle izlenir (en çok 4), her atlama şema ve adres denetiminden yeniden geçer. Sistem vekil sunucusu kullanılmaz.
- **Kullanıcı onayı:** başka bir uygulamadan (Android `ACTION_SEND`, iOS `namaztakip://share`) gelen içerik otomatik çözümlenmez. Düzenleme sayfası metni gösterir ve "bağlantı internetten okunur, anahtar varsa Google'a gider" uyarısı verir; kazıma yalnızca "Videodan / Metinden Kazı" düğmesiyle başlar.
- **Yapay zeka yanıtı:** hedef sayı `sanitizeTargetCount` ile 1-100000 arasına zorlanır; yanıt zaten kullanıcıya düzenlenebilir taslak olarak gösterilir, doğrudan kaydedilmez.
- **Fazilet iddiası:** Gemini istemi "fazilet veya sevap iddiası ekleme" der; yapay zeka kaynaksız dinî iddia üretmesin diye anlam alanı yalnızca anlamdır: [[dini-icerik-onayi]].
- **Kalan risk:** kazınan sayfa metni Gemini isteminin içine girer (prompt injection); yanıttaki `targetCount` doğrulanır ama metin alanlarının uzunluğu sınırlı değil. Taslak kaydedilmeden önce kullanıcı görür.

## Gemini (isteğe bağlı)

| Konu | Durum |
|---|---|
| Anahtar | Ayarlar → Sosyal Medya Zikir Kazıma. Platform anahtar deposunda saklanır (`flutter_secure_storage`: Android Keystore, iOS Keychain `first_unlock_this_device`, iCloud'a eşitlenmez); `SharedPreferences`'ta tutulmaz. Eski sürümde düz yazılmış anahtar ilk açılışta depoya taşınır ve düz kopya silinir ([[ayarlar-ve-kalicilik]], [[android-yapilandirma]]) |
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
