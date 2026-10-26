# Tema Sistemi

Beş renk teması vardır; kullanıcı Ayarlar'dan seçer, seçim kalıcıdır. Kod: `lib/core/theme/app_theme.dart`.

## Yapı

- `AppPalette` bir `ThemeExtension`'dır ve her temanın renklerini taşır: `primary`, `secondary`, `accent`, `dark`, `background`, `card`, `text`, `textLight`, `danger`, `isDark`.
- `AppThemeDef(key, palette)` bir temayı tanımlar; `kThemes` listesi beş temayı içerir. Görünen ad `SettingsStrings.themeName(key)`, ikon `AppIcons.theme(key)` ile çözülür: [[metin-sistemi]], [[ikon-sistemi]].
- `buildTheme(palette)` Material 3 `ThemeData` üretir: `ColorScheme.fromSeed` ile başlar, ana renkler paletten ezilir; AppBar, çekmece, anahtar teması paletten gelir.
- Ekranlar renge `context.palette` uzantısıyla erişir (`Theme.of(context).extension<AppPalette>()`).
- Seçim `theme` anahtarına yazılır; `paletteProvider` seçili temanın paletini verir ve `MaterialApp` bunu izler: [[ayarlar-ve-kalicilik]], [[durum-yonetimi]]. Tema değişince `AppPalette.lerp` ile yumuşak geçiş olur.

## Temalar

| Anahtar | Ad (`themeName`) | Alt Başlık (`themeSubtitle`) | `primary` | `secondary` | `background` | Koyu mu |
|---|---|---|---|---|---|---|
| `default` | Varsayılan | Selçuklu Zümrüdü | `#1B5E43` | `#C89D3C` | `#F8F5EE` | Hayır |
| `dark` | Koyu | Gece Kubbesi | `#38B281` | `#E2B553` | `#0C1411` | Evet |
| `ocean` | Okyanus | İznik Çinisi | `#175D85` | `#2EA3B8` | `#F3F8FB` | Hayır |
| `rose` | Gül Kurusu | Bordo & Gül | `#8C3747` | `#C87A82` | `#FCF6F7` | Hayır |
| `gold` | Altın | Tezhip Altını | `#8E6918` | `#D1A234` | `#FAF6EC` | Hayır |

Beş tema anahtarı backend kalıcılığıyla birebir uyumludur; renk paletleri Selçuklu/Osmanlı İslami sanat tonlarıyla (zümrüt, gece kubbesi, İznik çinisi, gül kurusu, tezhip altını) ve yüksek kontrastla güncellenmiştir. `lib/ui/widgets/islamic_pattern.dart` içindeki `MihrabArchBackdrop` ve `SeljukMedallion` bileşenleri `CustomPainter` ile 8 köşeli Selçuklu yıldızı (*Rub el-Hizb*) ve sivri mihrap kemeri motiflerini çizer.

## Kararlar

- Tema, sistem açık/koyu ayarını **izlemez**; yalnızca kullanıcı seçimi geçerlidir. Sistem temasını izleme fikri [[yol-haritasi]]'ndadır.
- Açık temalarda `primary` doygun/koyu tonlardır (`#1B5E43`, `#175D85`, `#8C3747`, `#8E6918`), `secondary` ise altın/turkuaz/gül vurgu rengidir; `AppBar` arka planla bütünleşir ve ana hero kartları `dark` → `primary` gradyanı üzerinde beyaz metin kullanır.
- Kontrast düzeltmeleri [[erisilebilirlik-ve-kontrast]] sayfasındadır.

## Doğrulama durumu

**Varsayılan** (Selçuklu Zümrüdü), **Koyu** (Gece Kubbesi) ve **Okyanus** (İznik Çinisi) temaları emülatörde gezildi ve doğrulandı. Ayarlar ekranında beş tema kartı (ikon, ad, alt başlık ve dört renk örneği) doğru görünür.

## Yeni tema ekleme

1. `kThemes` listesine `AppThemeDef('anahtar', AppPalette(...))` ekle.
2. `SettingsStrings.themeName` ve `AppIcons.theme` içindeki `switch`'lere ekle.
3. Tüm ekranları o temayla gez; özellikle kart, diyalog, grafik ve çekmece.
4. Bu sayfayı güncelle.

## İlgili sayfalar

[[ui-ekranlar]] · [[erisilebilirlik-ve-kontrast]] · [[ikon-sistemi]]
