# Derleme ve Yayın

Komutlar depo kökünden (`pubspec.yaml`'ın olduğu klasör) çalıştırılır. Aynı adımların kısa hâli `.agent/workflows/build_apk.md` dosyasındadır (depo dışında, üst klasörde).

## Android

| Amaç | Komut | Çıktı |
|---|---|---|
| Debug APK | `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` (≈165 MB) |
| Release APK | `flutter build apk --release` | `app-release.apk` |
| Mimariye göre küçük APK | `flutter build apk --release --split-per-abi` | `app-arm64-v8a-release.apk` vb. |
| Play Store paketi | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| Cihaza/emülatöre kur | `adb install -r <apk>` | |
| Derle, kur, çalıştır | `flutter run [--release]` | |

Ön koşullar ve ortam: [[gelistirme-ortami]]. Yapılandırma: [[android-yapilandirma]].

## İmzalama durumu

`android/app/build.gradle.kts` release imzasını `android/key.properties` dosyasından okur. Dosya yoksa **release derlemesi bilerek durur** ve nedenini yazar; böylece debug imzalı bir sürüm yanlışlıkla üretilmez (denetim bulgusu #2: [[denetim-raporu-2026-10-26]]).

| Durum | Sonuç |
|---|---|
| `android/key.properties` var | `assembleRelease`/`bundleRelease` gerçek anahtarla imzalar |
| Yok, ortam değişkeni yok | Derleme hata verir: "Release imza anahtarı yok..." |
| Yok, `ALLOW_DEBUG_SIGNING=1` | Debug anahtarıyla derler (yalnızca yan yükleme testi; mağazaya yüklenemez) |

Yan yükleme testi için (PowerShell): `$env:ALLOW_DEBUG_SIGNING = "1"; flutter build apk --release`. Git Bash: `ALLOW_DEBUG_SIGNING=1 flutter build apk --release`.

**Gerçek anahtarı üretmek (sen yaparsın; şifreleri ve keystore'u ben üretmem):**

1. Keystore üret ve güvenli yerde yedekle; kaybolursa uygulamayı güncelleyemezsin, **depoya koyma**:
   ```bash
   keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   (`keytool`, Android Studio'nun `jbr/bin` klasöründedir.)
2. `android/key.properties` dosyasını oluştur (`android/.gitignore` zaten yok sayar):
   ```
   storeFile=C:/yol/upload-keystore.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. `flutter build appbundle --release`; imzayı `apksigner verify --print-certs` ile kontrol et (DN "Android Debug" olmamalı).
4. Play Console'da uygulama kaydı, mağaza metinleri, **gizlilik politikası** (konum izni ve dini veri nedeniyle zorunlu), test kanalı.

Doğrulama (2026-10-26): anahtarsız derleme hata verdi; `ALLOW_DEBUG_SIGNING=1` ile `CN=Android Debug` imzalı APK çıktı; geçici (depoya girmeyen) bir test anahtarıyla `CN=Gecici Test` imzalı APK çıktı. Gerçek anahtar henüz üretilmedi: [[yol-haritasi]].

## Sürüm numarası

`pubspec.yaml` içindeki `version: 1.0.0+1`; `+` öncesi görünen sürüm, sonrası derleme numarasıdır (Android `versionCode`). Mağazaya her yüklemede derleme numarası artmalıdır. Arayüzde gösterilen sürüm (`CommonStrings.version`) elle yazılıdır ve `pubspec.yaml` ile birlikte güncellenmelidir: [[metin-sistemi]], [[bilinen-sorunlar]].

## iOS

Windows'ta iOS derlenemez. İhtiyaç: macOS + Xcode (`flutter build ios --release`) veya macOS CI (GitHub Actions macOS runner, Codemagic). İmzasız `.ipa` ücretsiz Apple ID ile cihaza kurulabilir (7 gün); mağaza için ücretli Apple Developer hesabı gerekir. Ayrıntı: [[ios-yapilandirma]].

## Yayın öncesi kontrol listesi

1. `flutter analyze` temiz, `flutter test` geçiyor: [[test-stratejisi]].
2. Gerçek cihazda bildirim, konum ve arka plan testi: [[yol-haritasi]].
3. Beş temanın hepsinde görsel kontrol: [[tema-sistemi]].
4. Release imzalama ve App Bundle.
5. iOS derlemesi ve testi.
6. Sürüm numarası ve wiki [[log]] güncel.

## Eski sistem

Önceki Expo sürümü EAS Build ile derleniyordu (`eas build -p android --profile preview`). Artık kullanılmıyor; EAS, `eas.json` ve Expo bağımlılıkları silindi: [[gecis-gecmisi]].

## İlgili sayfalar

[[gelistirme-ortami]] · [[android-yapilandirma]] · [[ios-yapilandirma]] · [[uygulama-ikonu]]
