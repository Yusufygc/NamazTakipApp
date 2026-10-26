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

Release derlemesi şu an **debug anahtarıyla** imzalanır. Yan yükleme için yeterlidir. Play Store yayını için:

1. Bir keystore üret (`keytool -genkey -v -keystore upload-keystore.jks ...`) ve güvenli yerde sakla; **depoya koyma**.
2. `android/key.properties` dosyası oluştur (yine depoya koyma, `.gitignore`'a ekle).
3. `android/app/build.gradle.kts` içinde `signingConfigs.release` bloğunu bu dosyadan okuyacak şekilde yaz ve `buildTypes.release.signingConfig`'i ona bağla.
4. `flutter build appbundle --release`.
5. Play Console'da uygulama kaydı, mağaza metinleri, gizlilik politikası (konum izni kullanıldığı için gerekir) ve test kanalı.

Henüz yapılmadı: [[yol-haritasi]].

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
