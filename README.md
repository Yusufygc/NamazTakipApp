# Namaz Takip

Günlük namazları takip eden, kaza namazlarını otomatik listeleyen ve sosyal medyadan (Instagram vb.) paylaşılan zikir/esma videolarını yakalayıp akıllı tesbihat sunan Flutter uygulaması (Android ve iOS).

## Ekran görüntüleri

Android emülatöründe (Pixel sınıfı, 1080x2400, İstanbul konumu, Diyanet yöntemi, varsayılan tema) alındı.

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/01-vakitler.png" width="200" alt="Vakitler ekranı"><br><sub><b>Vakitler</b><br>Sıradaki vakit, geri sayım, Hicri tarih</sub></td>
    <td align="center"><img src="docs/screenshots/02-namaz-isaretleme.png" width="200" alt="Namaz işaretleme penceresi"><br><sub><b>Namaz işaretleme</b><br>Kıldım, cemaatle, kılmadım</sub></td>
    <td align="center"><img src="docs/screenshots/03-kaza.png" width="200" alt="Kaza ekranı"><br><sub><b>Kaza</b><br>Otomatik liste, geçmiş borç hedefi</sub></td>
    <td align="center"><img src="docs/screenshots/04-surec.png" width="200" alt="Süreç ekranı"><br><sub><b>Süreç</b><br>Performans radarı, ısı haritası</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/05-rozetler.png" width="200" alt="Rozetler ekranı"><br><sub><b>Rozetler ve seri</b><br>Güncel seri, 5 rozet</sub></td>
    <td align="center"><img src="docs/screenshots/06-ayarlar.png" width="200" alt="Ayarlar ekranı"><br><sub><b>Ayarlar</b><br>Bildirim, konum, yöntem, widget</sub></td>
    <td align="center"><img src="docs/screenshots/07-zikirler.png" width="200" alt="Zikir ve Esma Defteri"><br><sub><b>Zikir ve Esma Defteri</b><br>Paylaşım yakalayıcı, zikirmatik</sub></td>
    <td align="center"><img src="docs/screenshots/08-kible.png" width="200" alt="Kıble pusulası"><br><sub><b>Kıble pusulası</b><br>Açı ve Kâbe mesafesi</sub></td>
  </tr>
</table>

Ekran görüntüsünü yenilemek için emülatörde uygulamayı açıp `adb exec-out screencap -p > docs/screenshots/<ad>.png` çalıştırın. Emülatör kurulumu: `docs/wiki/gelistirme-ortami.md`.

## Özellikler

- Konuma göre namaz vakitleri, cihazda hesaplanır (`adhan_dart`, varsayılan Diyanet yöntemi). İnternet gerekmez.
- Güneşin doğuşu vaktinde kerahat/işrak sınırına karşı **1.5 dakika (90 saniye)** erken ihtiyat payı uygulanır.
- Vakte dokunarak kıldım (tek başına / cemaatle) veya kılmadım işaretleme; namaz kılındığında vakte uygun tesbihat önerisi.
- **Zikir & Esma Defteri + Instagram Paylaşım Yakalayıcı:**
  - Instagram, TikTok veya YouTube Shorts'ta karşılaşılan dini videolar **"Paylaş -> Namaz Takip (Zikir Yakala)"** ile doğrudan uygulamaya gönderilebilir.
  - Video bağlantısı ve açıklamasından Esmaül Hüsna / zikir adı, Arapça metni, okunuşu, anlamı, hedef sayısı (`100 defa`, `308 kere`, `41 kez`) ve tavsiye edilen namaz vakti otomatik çıkarılır (isteğe bağlı Gemini AI desteği ile).
  - Kullanıcı zikirleri gruplayabilir (`Esmaül Hüsna`, `Sabah & Akşam`, `Rızık & Bereket`, `Şifa & Huzur`, `Namaz Tesbihatı`, `Genel Zikirler` veya özel grup), arayabilir, düzenleyebilir, silebilir ve dokunmatik **Selçuklu Zikirmatik** ile titreşimli olarak çekebilir.
  - Başka bir uygulamadan gelen içerik **otomatik işlenmez**; uyarı çıkar ve kazıma yalnızca "Kazı" düğmesiyle başlar.
- Kıble pusulası (manyetik sapma düzeltmeli), Hicri takvim ile kandil ve bayram günleri, Android ana ekran widget'ı.
- İşaretlenmeyen geçmiş günler kaza listesine otomatik düşer; vakit vakit kaza edilebilir.
- Ezan vaktinde "önceki namazı kıldın mı?" bildirimi ve ezandan sonra hatırlatma.
- Süreç: performans radarı, aylık ısı haritası, haftalık/aylık karşılaştırma.
- Seri ve rozetler.
- 5 İslami sanat teması (`Selçuklu Zümrüdü`, `Gece Kubbesi`, `İznik Çinisi`, `Bordo & Gül`, `Tezhip Altını`), elle şehir seçimi (81 il), hesaplama yöntemi ve hatırlatma süresi ayarı.

## Gizlilik ve güvenlik

- Namaz kayıtları cihazdan çıkmaz; Android bulut yedeği ve cihazdan cihaza aktarım kapalıdır (dini inanç verisi, KVKK m.6).
- Konum yalnızca vakit hesabı içindir. Vakitler cihazda hesaplanır.
- Bağlantı kazıma yalnızca `https` ile ve genel internet adreslerine yapılır; yerel ağ, loopback ve bulut metadata adresleri engellenir, yönlendirmeler her adımda yeniden denetlenir.
- Gemini API anahtarı isteğe bağlıdır ve platform anahtar deposunda (Android Keystore, iOS Keychain) saklanır. Anahtar girilirse paylaşılan metin Google'a gönderilir.
- Release derlemesi imza anahtarı olmadan bilerek durur. Ayrıntı: `docs/wiki/guvenlik-ve-kalite-analizi.md`.

## Çalıştırma

Flutter SDK 3.47 veya üzeri gerekir.

```bash
flutter pub get
flutter run
```

Test ve analiz:

```bash
flutter analyze
flutter test
cd packages/namaz_backend && flutter test
```

Debug APK:

```bash
flutter build apk --debug
```

## Proje yapısı

```
lib/
  core/        tema, biçimlendirme, merkezi ikon ve metin sistemi
    icons/     merkezi ikon sistemi (AppIcons)
    strings/   modüler merkezi metin sistemi
  providers/   Riverpod durum yönetimi
  ui/          ekranlar ve Selçuklu/Osmanlı desenli widget'lar
packages/
  namaz_backend/
    lib/src/
      domain/      saf Dart modelleri, vakit hesabı, zikir/esma kazıyıcı (dhikr_extractor)
      data/        SQLite (prayers ve dhikrs tabloları), SharedPreferences
      platform/    konum, bildirim ve sosyal medya paylaşım (ShareService) kanalları
      application/ NamazBackend uygulaması ve bildirim zamanlayıcı
```

## İkon ve metin sistemi

- **İkonlar:** `lib/core/icons/app_icons.dart`. Ekranlarda emoji veya `Icons.xxx` kullanılmaz,
  anlamsal ad üzerinden `AppIcons.xxx` kullanılır (ör. `AppIcons.navQaza`).
- **Metinler:** `lib/core/strings/`. Her modül kendi dosyasındadır (`home_strings.dart`,
  `dhikr_strings.dart`, `qaza_strings.dart`, `settings_strings.dart` ...); ekranlar yalnızca `strings.dart`'ı içe aktarır.
  Yeni metni ilgili modüle ekleyin; ekranlara sabit metin yazmayın.
- `test/central_system_test.dart` bu kuralları denetler: `lib/` içinde emoji, `app_icons.dart`
  dışında `Icons.xxx` ve `lib/ui/` içinde Türkçe sabit metin bulunursa test başarısız olur.
- Büyük harfe çevirme için `turkishUpper` (`İkindi` → `İKİNDİ`), arama için `foldTurkish` kullanın.
