# Uygulama (Launcher) İkonu

Telefonun ana ekranında görünen ikon. Uygulama içi ikonlardan ayrıdır: [[ikon-sistemi]].

## Kaynak ve türevler

Tasarım: mor-mavi gradyan zemin üzerinde altın hilal ve minare. Tek gerçek kaynak `assets/icon/AppIcon.png`'dir (1024×1024, köşeleri beyaz, yuvarlak çerçeveli).

| Dosya | Ne |
|---|---|
| `assets/icon/AppIcon.png` | Özgün tasarım; yalnızca kaynak, doğrudan kullanılmaz |
| `assets/icon/icon_background.png` | 1024×1024 çapraz gradyan (sol üst `rgb(60,10,107)` → sağ alt `rgb(28,70,150)`) |
| `assets/icon/icon_foreground.png` | Şeffaf zemin üzerinde altın hilal ve minare (yükseklik ≈ 600 px; Android adaptive güvenli bölge içinde) |
| `assets/icon/icon_full.png` | Gradyan + altın şekil, opak, **tam taşan** (iOS ve eski Android) |
| `assets/icon/icon_monochrome.png` | Beyaz şekil, şeffaf zemin; Android 13 temalı ikon |

## Neden türev üretildi

Özgün PNG'nin köşeleri opak beyazdır. iOS ikonu tam taşmalı olmalıdır (sistem kendi maskesini uygular) ve Android adaptive ikon ayrı ön/arka katman ister. Bu yüzden altın şekil renginden maskelenip (`r − b` farkı eşik alınarak, beyaz köşeler atılarak) çıkarıldı ve gradyan zemin yeniden çizildi.

Önceki Expo sürümünde `android-icon-*` adlı üç dosya vardı; bunlar Expo şablonunun mavi ok yer tutucusuydu, gerçek ikon değildi. Silindiler: [[gecis-gecmisi]].

## Üretim

Ayar `pubspec.yaml` içindeki `flutter_launcher_icons:` bölümündedir (android, ios, `icon_full.png`, adaptive arka/ön/tek renkli katmanlar, iOS'ta alfa kaldırma).

```bash
dart run flutter_launcher_icons
```

Çıktı: `android/app/src/main/res/mipmap-*`, `drawable-*`, `mipmap-anydpi-v26/ic_launcher.xml`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`.

**Üretimden sonra zorunlu kontrol:** Araç `ios/Runner.xcodeproj/project.pbxproj` içindeki `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` değerini `AppIcon` yapıp bozar. İki satırı `YES`'e geri alın: [[ios-yapilandirma]].

## Türevleri yeniden üretmek

Üretim betiği depoda **tutulmuyor** (bir kerelik Pillow betiğiydi). `icon_*.png` dosyaları commit'lidir; `AppIcon.png` değişirse betik yeniden yazılmalıdır: gradyan arka plan, altın maske (beyaz olmayan ve `r − b` yüksek pikseller), ön katmanı 600 px yüksekliğe ölçekle, tam taşan sürüm için ≈760 px.

## Doğrulama

Android emülatörde uygulama çekmecesinde "Namaz Takip" ikonu yuvarlak adaptive maskede hilal + minare olarak göründü: [[emulator-test-notlari]]. Android 13 "temalı ikon" görünümü ve iOS ikonu görsel olarak denenmedi: [[bilinen-sorunlar]].

## İlgili sayfalar

[[android-yapilandirma]] · [[ios-yapilandirma]] · [[bagimliliklar]]
