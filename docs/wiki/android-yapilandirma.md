# Android Yapılandırması

Dosyalar: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`.

## Sürümler

| Öğe | Değer | Kaynak |
|---|---|---|
| Android Gradle Plugin | 9.1.0 | `settings.gradle.kts` |
| Gradle | 9.3.1 | `gradle-wrapper.properties` |
| Kotlin | 2.4.0 | `settings.gradle.kts` |
| Java | 17 | `compileOptions` |
| `compileSdk` | 36 | `flutter.compileSdkVersion` |
| `minSdk` | 24 | `flutter.minSdkVersion` (Flutter 3.47) |
| `targetSdk` | 36 | `flutter.targetSdkVersion` |
| NDK | 28.2.13676358 | `flutter.ndkVersion` |

Sürümler Flutter şablonundan gelir; Flutter yükseltilince değişebilir.

## Kimlikler

- `namespace`: `com.namaztakip.namaz_takip` (Kotlin paketi, `MainActivity.kt`).
- `applicationId`: **`com.namaztakip.app`**. Eski Expo sürümüyle aynı paket adıdır.
- Uygulama adı (`android:label`): "Namaz Takip".

`namespace` ile `applicationId` bilerek farklıdır; `namespace` değişirse `MainActivity` paketi de taşınmalıdır.

## Core library desugaring

`flutter_local_notifications` zamanlanmış bildirimler için gerektirir:

```kotlin
compileOptions { isCoreLibraryDesugaringEnabled = true ... }
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

Bu olmadan derleme hata verir.

## Manifest

İzinler ve anlamları: [[izinler]]. Eklenti alıcıları:

- `ScheduledNotificationReceiver`: zamanlanmış bildirimi gösterir.
- `ScheduledNotificationBootReceiver`: `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON` olaylarında bildirimleri yeniden kurar.

Bildirim eylem düğmeleri kullanılmadığı için `ActionBroadcastReceiver` tanımlı değildir; düğme eklenirse eklenmelidir: [[yol-haritasi]].

## İmzalama

`release` yapısı şu an **debug anahtarıyla** imzalanır (`signingConfig = signingConfigs.getByName("debug")`). Yan yükleme için yeterlidir; Play Store için release keystore gerekir: [[derleme-ve-yayin]].

## Bilinen uyarılar ve tuzaklar

- **KGP uyarısı:** `workmanager_android` eski Kotlin Gradle eklentisini uyguluyor; derleme "Future versions of Flutter will fail to build" uyarısı verir: [[bagimliliklar]].
- **SDK XML sürümü uyarısı:** Komut satırı araçları ile Android Studio farklı zamanda çıkmışsa görülür; zararsızdır: [[gelistirme-ortami]].
- **Gradle otomatik SDK kurar:** Bir eklenti daha yeni bir `compileSdk` isterse Gradle onu kurmaya çalışır; `platforms;android-37.0` gibi adla kurup `android-37` aradığı için derleme bozulabilir. `permission_handler` ile yaşandı ve paket kaldırıldı: [[emulator-test-notlari]].
- **İlk derleme uzundur** (Gradle, bağımlılıklar, NDK indirilir): ilk deneme 24 dakika sürüp yukarıdaki SDK hatasıyla düştü, düzeltilmiş ikinci deneme yaklaşık 8 dakika sürdü; sonraki artımlı derlemeler 15–75 saniye.
- Launcher ikonları `mipmap-*` ve `drawable-*` klasörlerine **üretilir**: [[uygulama-ikonu]].

## İlgili sayfalar

[[izinler]] · [[bildirimler]] · [[derleme-ve-yayin]] · [[ios-yapilandirma]]
