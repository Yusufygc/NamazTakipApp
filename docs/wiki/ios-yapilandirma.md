# iOS Yapılandırması

> **Durum: yazıldı, derlenmedi.** iOS derlemesi macOS ve Xcode ister; geliştirme makinesi Windows'tur. Aşağıdaki ayarlar paket belgelerinden ve kaynak koddan yazıldı, hiç çalıştırılmadı. İlk iOS derlemesinde hata çıkması olasıdır: [[bilinen-sorunlar]].

Dosyalar: `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner.xcodeproj/project.pbxproj`.

## Kimlikler

- Paket kimliği (bundle id): `com.namaztakip.namazTakip` (`flutter create --org com.namaztakip` ile üretildi). Android'deki `com.namaztakip.app` ile **farklıdır**; yayın öncesi birleştirmek istenirse `project.pbxproj` içinde değiştirilmelidir.
- Görünen ad: "Namaz Takip" (`CFBundleDisplayName` ve `CFBundleName`).
- Minimum iOS: 15.0 (`IPHONEOS_DEPLOYMENT_TARGET`).

## Info.plist'e eklenenler

| Anahtar | Değer | Neden |
|---|---|---|
| `NSLocationWhenInUseUsageDescription` | "Namaz vakitlerini bulunduğunuz yere göre hesaplamak için konumunuza ihtiyacımız var." | Konum izni açıklaması: [[izinler]] |
| `UIBackgroundModes` | `fetch`, `processing` | Arka plan görevi: [[arka-plan-gorevleri]] |
| `BGTaskSchedulerPermittedIdentifiers` | `namaz_takip_refresh` | `workmanager` görev kimliği; `BackgroundService` içindeki benzersiz adla **aynı** olmalı |

## AppDelegate

`didFinishLaunchingWithOptions` içinde:

```swift
UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
```

Bu, uygulama açıkken de yerel bildirimlerin gösterilmesini sağlar (`flutter_local_notifications` belgesi). Şablon Flutter 3.47'nin `FlutterImplicitEngineDelegate` ve `SceneDelegate` düzenini kullanır; eklenti kaydı `didInitializeImplicitFlutterEngine` içindedir. `workmanager` için `AppDelegate` kodu gerekmez (paket belgesi).

## iOS'a özgü davranışlar

- **64 bildirim sınırı:** iOS en fazla 64 bekleyen yerel bildirim tutar; bu yüzden iOS'ta 6 günlük pencere planlanır (6 × 10 = 60): [[bildirimler]].
- **Arka plan kısıtlı:** BGTaskScheduler görev zamanını sistem belirler; periyodik yenileme garanti değildir. Bildirimlerin sürmesi uygulamanın düzenli açılmasına da bağlıdır: [[arka-plan-gorevleri]].
- **Bildirim izni:** Çalışma zamanında istenir (uyarı ve ses): [[izinler]].
- Tam zamanlı alarm kavramı yoktur; iOS planlanan yerel bildirimi zamanında gösterir.

## Proje dosyası tuzağı

`flutter_launcher_icons` aracı `project.pbxproj` içinde `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES` ayarını `AppIcon` yapıp bozuyor. İkon üretildikten sonra iki satır `YES`'e geri alınmalıdır: [[uygulama-ikonu]].

## İlk iOS derlemesi için kontrol listesi

1. macOS'ta (veya macOS CI'da) `flutter build ios --no-codesign`.
2. Xcode'da imzalama takımı ve bundle id ayarlanır.
3. Cihazda: konum izni, bildirim izni, bildirimin zamanında gelmesi, arka plan görevi.
4. Çıkan sorunlar bu sayfaya ve [[bilinen-sorunlar]]'a işlenir.

Apple Developer hesabı olmadan: ücretsiz Apple ID ile 7 gün geçerli imzayla cihaza kurulum mümkündür (Xcode veya Sideloadly/AltStore); mağaza yayını için ücretli hesap gerekir: [[yol-haritasi]].

## İlgili sayfalar

[[android-yapilandirma]] · [[derleme-ve-yayin]] · [[bildirimler]]
