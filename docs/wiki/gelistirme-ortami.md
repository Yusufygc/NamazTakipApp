# Geliştirme Ortamı (Windows)

Geliştirme makinesi Windows 11'dir. Bu sayfa kurulumu, günlük komutları ve emülatör kullanımını anlatır. Elle yapılması gereken her şey burada toplanır ki ortam yeniden kurulabilsin.

## Kurulu araçlar

| Araç | Konum | Nasıl kuruldu |
|---|---|---|
| Flutter SDK 3.47.8 (Dart 3.13.7) | `C:\src\flutter` | `git clone -b stable https://github.com/flutter/flutter.git` (winget'te resmî paket yok) |
| Android Studio 2026.2.1.8 | `C:\Program Files\Android\Android Studio` | `winget install Google.AndroidStudio` |
| Android SDK | `%LOCALAPPDATA%\Android\Sdk` | `sdkmanager` ile (aşağıda) |
| JDK | Android Studio'nun JBR'si: `...\Android Studio\jbr` | Android Studio ile gelir; Windows'taki Java 8 Flutter için yetersizdir |
| Emülatör AVD `namaz_test` | `~/.android/avd/namaz_test.avd` | Pixel 8, Android 36, `google_apis` x86_64 |

Flutter, `flutter config --android-sdk "%LOCALAPPDATA%\Android\Sdk" --jdk-dir "C:\Program Files\Android\Android Studio\jbr"` ile bu yollara bağlandı.

**PATH:** `C:\src\flutter\bin` kalıcı PATH'e **eklenmedi**. Her komutta oturum içinde eklenir: PowerShell'de `$env:Path = "C:\src\flutter\bin;" + $env:Path`, Git Bash'te `export PATH="/c/src/flutter/bin:$PATH"`.

## Android SDK bileşenleri

Komut satırı araçları `https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip` adresinden indirilip `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest` içine açıldı (SHA-256 `90ae805d…b04a`, Google'ın sayfasındaki değerle eşleşti). Kurulanlar:

```bash
sdkmanager --sdk_root=$SDK "platform-tools" "platforms;android-36" "build-tools;36.0.0" \
           "emulator" "system-images;android-36;google_apis;x86_64"
```

Lisanslar kabul edildi (`yes | sdkmanager --licenses`). `sdkmanager` için `JAVA_HOME` JBR'ye ayarlanmalıdır. `flutter doctor` tüm kategorilerde yeşildir.

## Tedarik zinciri kontrolü

Kurulumdan sonra yapıldı (önce yapılmamıştı): cmdline-tools hash'i Google sayfasıyla eşleşti; `studio64.exe` ve `adb.exe` Authenticode imzaları geçerli ("Google LLC"); Flutter deposunun `origin` adresi `github.com/flutter/flutter`; Android Studio'yu winget kurdu ve kurucu hash'ini doğruladı. Flutter commit'i resmî yayın listesiyle karşılaştırılmadı; pub.dev paketlerinin kaynakları incelenmedi: [[bagimliliklar]].

## Günlük komutlar

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Derleme ve yayın ayrıntısı: [[derleme-ve-yayin]]. Testler: [[test-stratejisi]].

## Emülatör

```bash
# Başlat (SDK\emulator\emulator.exe)
emulator -avd namaz_test -no-snapshot -no-audio

# Kur ve aç
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.namaztakip.app/com.namaztakip.namaz_takip.MainActivity
```

- **Donanım hızlandırma:** WHPX kullanılabilir (`emulator -accel-check`).
- **Konum:** Emülatör PC'nin konumunu kullanmaz. `adb emu geo fix 28.9784 41.0082` (boylam, enlem; İstanbul). Konum bir uygulama GPS isterken verilmelidir; uygulama `high` doğrulukta GPS ister: [[konum]].
- **Saat dilimi:** Emülatör varsayılan olarak UTC'dir ve vakitler 3 saat kayık görünür. `adb shell cmd alarm set-timezone Europe/Istanbul` ile düzeltilir: [[namaz-vakitleri]].
- **Saati değiştirmek (bildirim testi):** `adb root` (yalnızca `google_apis` imajlarında), `adb shell settings put global auto_time 0`, `adb shell date MMDDhhmmYYYY.ss` (örn. `102619342026.30`). Test sonunda `auto_time 1` ve `adb unroot`.
- **Ekran görüntüsü:** `adb exec-out screencap -p > ekran.png`. Ekran metinleri: `adb shell uiautomator dump`.
- **Veritabanını okuma (root ile):** `adb shell sqlite3 /data/data/com.namaztakip.app/databases/namaz_takip.db "select * from prayers"`. Root yokken `run-as com.namaztakip.app` ile ayarlar dosyası okunabilir.
- **Alarmları görmek:** `adb shell dumpsys alarm | grep com.namaztakip.app`.

## Tuzaklar

- **`adb shell monkey ...` kullanmayın.** `monkey -p paket -c LAUNCHER 1` açılışa ek olarak **rastgele dokunuş** gönderir; test sırasında istemeden "Şehir seç"i açıp bir il seçti. Uygulamayı `am start -n ...` ile açın.
- Emülatör yavaş güncellenirse ekran görüntüsü bir önceki kareyi gösterebilir; `uiautomator dump` metni daha güvenilirdir.
- Git "Filename too long" uyarısı `build/` klasöründeki derin Gradle yollarından gelir; zararsızdır, `build/` zaten yok sayılır.
- Bash'te uzun çok satırlı dosya yazarken here-document bazen takılır; dosyaları editörle yazın.
- `flutter_launcher_icons` iOS proje dosyasını bozar: [[uygulama-ikonu]].
- Windows'ta `rmdir` bir klasörü "kullanımda" diye silmeyebilir (oturumun çalışma dizini); oturumu kapatınca silinir.

## İlgili sayfalar

[[derleme-ve-yayin]] · [[test-stratejisi]] · [[emulator-test-notlari]] · [[android-yapilandirma]]
