# Tema Sistemi

Beş renk teması vardır; kullanıcı Ayarlar'dan seçer, seçim kalıcıdır. Kod: `lib/core/app_theme.dart`.

## Yapı

- `AppPalette` bir `ThemeExtension`'dır ve her temanın renklerini taşır: `primary`, `secondary`, `accent`, `dark`, `background`, `card`, `text`, `textLight`, `danger`, `isDark`.
- `AppThemeDef(key, palette)` bir temayı tanımlar; `kThemes` listesi beş temayı içerir. Görünen ad `SettingsStrings.themeName(key)`, ikon `AppIcons.theme(key)` ile çözülür: [[metin-sistemi]], [[ikon-sistemi]].
- `buildTheme(palette)` Material 3 `ThemeData` üretir: `ColorScheme.fromSeed` ile başlar, ana renkler paletten ezilir; AppBar, çekmece, anahtar teması paletten gelir.
- Ekranlar renge `context.palette` uzantısıyla erişir (`Theme.of(context).extension<AppPalette>()`).
- Seçim `theme` anahtarına yazılır; `paletteProvider` seçili temanın paletini verir ve `MaterialApp` bunu izler: [[ayarlar-ve-kalicilik]], [[durum-yonetimi]]. Tema değişince `AppPalette.lerp` ile yumuşak geçiş olur.

## Temalar

| Anahtar | Ad | Karakter | `primary` | `background` | Koyu mu |
|---|---|---|---|---|---|
| `default` | Varsayılan | Adaçayı yeşili | `#A5C89E` | `#FAFAFA` | Hayır |
| `dark` | Koyu | Koyu zemin, yeşil vurgu | `#5C8A6E` | `#121212` | Evet |
| `ocean` | Okyanus | Mavi | `#5B9BD5` | `#F5F9FF` | Hayır |
| `rose` | Gül Kurusu | Pembe | `#C2727A` | `#FFF5F7` | Hayır |
| `gold` | Altın | Sarı | `#C9A94E` | `#FFFEF5` | Hayır |

Renk değerleri eski React Native temalarıyla birebir aynıdır: [[gecis-gecmisi]]. Eski "Ayasofya" arka plan teması kaldırılmıştı ve taşınmadı.

## Kararlar

- Tema, sistem açık/koyu ayarını **izlemez**; yalnızca kullanıcı seçimi geçerlidir. Sistem temasını izleme fikri [[yol-haritasi]]'ndadır.
- Açık temalarda `primary` renkler açık tonlardır; üstündeki metin beyazdır. Koyu temada metin `palette.text` olur. Bu kural kartlarda ve AppBar'da `isDark` kontrolüyle uygulanır.
- Kontrast düzeltmeleri (kırmızı yazı, "Yükselişte" yeşili, şeffaf yerine harmanlanmış zemin) [[erisilebilirlik-ve-kontrast]] sayfasındadır.

## Doğrulama durumu

Yalnızca **Varsayılan** tema emülatörde gezildi ve düzeltildi. Koyu, Okyanus, Gül ve Altın temalarında her ekranın görsel kontrolü yapılmadı; kontrast sorunları çıkabilir: [[bilinen-sorunlar]], [[yol-haritasi]]. Ayarlar ekranında beş tema kartı (renk noktaları + ikon + ad) doğru görünür.

## Yeni tema ekleme

1. `kThemes` listesine `AppThemeDef('anahtar', AppPalette(...))` ekle.
2. `SettingsStrings.themeName` ve `AppIcons.theme` içindeki `switch`'lere ekle.
3. Tüm ekranları o temayla gez; özellikle kart, diyalog, grafik ve çekmece.
4. Bu sayfayı güncelle.

## İlgili sayfalar

[[ui-ekranlar]] · [[erisilebilirlik-ve-kontrast]] · [[ikon-sistemi]]
