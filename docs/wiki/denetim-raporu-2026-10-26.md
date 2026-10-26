# Denetim Raporu — 2026-10-26

İki kaynak dokümana göre yapılan analiz: **V2-GenelSablon** (kapsamlı sistem denetimi şablonu: kod kalitesi, mimari, güvenlik, test, production) ve **AI-Gelistirme-Metodolojisi** (wiki, inceleme, plan/onay, doğrulama ve commit disiplini). Bu rapor yalnızca bulguları sunar; hiçbir düzeltme uygulanmamıştır. Düzeltmeler onaydan sonra, her biri ayrı adım olarak yapılır (metodoloji 2.3).

Denetlenen durum: `flutter-migration` branch'i, commit `564245e`.

> **Uygulama durumu (2026-10-26, sonradan eklendi):** #1–#7 onaylı plana göre uygulandı. #1, #2, #3, #4, #5, #6 düzeltildi ve doğrulandı. **#7 yanlış pozitif çıktı** (aşağıda). Doğrulama sırasında üç yeni bulgu çıktı ([[bilinen-sorunlar]]): bozuk veritabanının sessizce silinmesi, geçmişe düşen bildirimin planı durdurması, çapraz-izolat serileştirme sınırı. Ayrıntı: [[emulator-test-notlari]] Tur 3. Ölçüm ve kanıt toplama betikleriyle yapıldı; ölçülemeyen metrikler açıkça belirtilmiştir.

## Tarama planı ve dizin ağacı

| Klasör | Dosya | Not |
|---|---|---|
| `lib/` (ön yüz) | 32 Dart | `ui` 11, `core` 19, `providers` 1, `main.dart` |
| `packages/namaz_backend/` | 26 | 18 kaynak Dart + 4 test + pubspec/analysis |
| `test/` | 2 | ön yüz testleri |
| `android/`, `ios/` | ≈110 | şablon + elle yapılandırma (izin, manifest, plist) |
| `docs/wiki/` | 49 | bilgi tabanı |
| `assets/icon/` | 5 | ikon kaynakları |

Sıra: giriş noktası (`main.dart`) → backend giriş (`namaz_backend_impl.dart`) → çekirdek mantık (`domain/`, `data/`) → platform servisleri → ekranlar → testler → manifest/Gradle → süreç dosyaları (commit geçmişi, README, wiki).

**Hariç tutulanlar:** `build/`, `.dart_tool/`, `.git/`, `android/.gradle/`, üretilen launcher ikonları, `pubspec.lock` (yalnızca varlığı raporlandı: iki paket tek lock dosyasında).

## Ölçüm sonuçları (eşiklere göre)

Kaynak 4.523 satır, test 751 satır (oran 0,17).

| Metrik (eşik) | Sonuç |
|---|---|
| Dosya > 500 satır | **1**: `lib/ui/screens/stats_screen.dart` (519) |
| Fonksiyon > 50 satır | **7** `build` metodu: `settings_screen.dart:15` (122), `stats_screen.dart:59` (89), `:304` (82), `about_screen.dart:11` (78), `prayer_card.dart:29` (74), `home_screen.dart:95` (67), `stats_screen.dart:177` (60) |
| Sınıf > 300 satır | 0 (en uzun: `_ComparisonTabState` 219, `NamazBackendImpl` 235) |
| Sınıf metodu > 20 | **1**: `NamazBackendImpl` (≈23) |
| Parametre > 5 | `AppPalette` 10, `PrayerCard` 8, `AppSettings` 7, `DayTimes` 7, `buildNotificationPlan` 6 |
| İç içe derinlik > 4 (UI dışı) | 0 |
| Import > 25 | 0 (en çok 19: `namaz_backend_impl.dart`) |
| Cyclomatic / kognitif karmaşıklık | **Ölçülemedi**: Dart için kurulu metrik aracı yok; yalnızca yapısal ölçümler yapıldı |
| Ölü kod | 0 üretim sembolü; yalnızca test için `AppDatabase.openInMemory` ve kullanılmayan `cupertino_icons` bağımlılığı |

---

## Bölüm A — Yönetici Özeti

Mimari temel sağlam: ön yüz ile backend paket düzeyinde ayrılmış, sınır testle zorlanıyor, iş mantığı saf fonksiyonlarda ve testli. Bugün düzeltilmesi gereken **kritik (🔴) bulgu yok**. Yüksek öncelikli bulgular üç grupta toplanıyor: (1) yayın öncesi yasal/üretim riskleri (din verisinin bulut yedeğine girmesi, debug anahtarıyla imzalı release), (2) güvenilirlik (tam zamanlı alarm izninin sessizce kapalı kalması, eşzamanlı yeniden planlama yarışı, saat dilimi alınamazsa UTC'de bildirim), (3) bir mantık hatası (04:00 sabit gün sınırı yaz aylarında Sabah namazını önceki güne yazar). Orta öncelik: backend'in tek facade sınıfı test edilmiyor, test oranı düşük, bir dosya eşiği aşıyor. Süreç tarafında metodolojiyle çelişen iki uygulama var: commit mesajları İngilizce ve AI referansı taşıyor, büyük mimari değişiklik plan/onay akışı olmadan yapıldı.

| # | Bulgu | Öncelik | Boyut | Efor | Etki |
|---|---|---|---|---|---|
| 1 | Din verisi Android bulut yedeğine giriyor | 🟠 | Güvenlik/Yasal | S | Yüksek |
| 2 | Release derlemesi debug anahtarıyla imzalı | 🟠 | Production | M | Yüksek |
| 3 | Tam zamanlı alarm izni reddedilince bildirim 1 saate kadar geç | 🟠 | Production/Mantık | M | Yüksek |
| 4 | 04:00 sabit gün sınırı: yazın Sabah önceki güne yazılıyor | 🟠 | Mantık | M | Yüksek |
| 5 | Eşzamanlı `reschedule` yarışı: işaretlenmiş vaktin hatırlatması geri gelir | 🟠 | Mantık/Race | M | Orta |
| 6 | Başlatma hatası yakalanmıyor, çökme izlenmiyor | 🟠 | Production | S | Yüksek |
| 7 | Saat dilimi alınamazsa bildirimler sessizce UTC'de kurulur | 🟠 | Hata yönetimi | S | Orta |
| 8 | Her uygulama dönüşünde GPS + tam yeniden planlama | 🟡 | Performans | S | Orta |
| 9 | `NamazBackendImpl`: 7 sorumluluk, 23 metot, 0 test, singleton bağımlılığı | 🟡 | Mimari/Test | L | Orta |
| 10 | Test oranı 0,17; kritik sınıflar testsiz | 🟡 | Test | L | Orta |
| 11 | `stats_screen.dart` 519 satır; 7 uzun `build` | 🟡 | Kod kalitesi | M | Düşük |
| 12 | Yanlış/otomatik kaza kaydını düzeltme yolu yok | 🟡 | Mantık/Ürün | M | Orta |
| 13 | Sessiz yutulan hatalar, yetersiz loglama | 🟡 | Hata yönetimi | S | Orta |
| 14 | Ayarlar başlıkları "BILDIRIMLER" (Türkçe `i` bozuk) | 🟡 | Yerel bağlam | S | Düşük |
| 15 | Commit mesajları İngilizce ve AI referanslı (metodoloji 6) | 🟡 | Süreç | S | Düşük |
| 16 | Büyük özellik için plan/onay akışı atlandı (metodoloji 4) | 🟡 | Süreç | — | Orta |
| 17 | README ve `build_apk.md` eskimiş; pubspec açıklaması bozuk | 🟡 | Dokümantasyon | S | Düşük |
| 18 | CI/CD yok | 🟡 | Production | M | Orta |
| 19 | DRY: ısı haritası renkleri iki kez, 13 sabit renk | 🟢 | Kod kalitesi | S | Düşük |
| 20 | Shotgun surgery: yöntem 3, tema 3, rozet 4 dosya | 🟢 | Mimari | M | Düşük |
| 21 | Haftalık karşılaştırma takip öncesi günleri 0 sayar | 🟢 | Mantık | S | Düşük |
| 22 | `cupertino_icons` kullanılmıyor; LICENSE yok; lisans/CVE taranmadı | 🟢 | Güvenlik | S | Düşük |
| 23 | Mimari testler çalışma dizinine bağlı | 🟢 | Test | S | Düşük |
| 24 | Wiki metodolojiden sapıyor (rules.md yok, REVIEW tipi yok, CLAUDE.md uzun) | 🟢 | Süreç | S | Düşük |

---

## Bölüm B — Korunması Gereken İyi Pratikler

1. **Ön yüz/backend sınırı otomatik zorlanıyor.** İki `architecture_test.dart` var; ihlal eklenince düştükleri elle doğrulandı. `domain/` saf Dart. Refactor sırasında bu sınıra dokunulmamalı: [[backend-paketi]], [[011-front-backend-ayrimi]].
2. **Bildirim planı saf fonksiyon ve kimlikler sabit.** `buildNotificationPlan` testli, kimlik `yyyymmdd*10+vakit*2+tür` ile çift bildirim yapısal olarak engelleniyor: [[004-sabit-bildirim-kimlikleri]].
3. **Tarih ISO biçiminde ve `UNIQUE(date, prayer)`.** Sıralama, aralık sorgusu ve tekrar işaretleme sorunları kökten çözülmüş: [[003-iso-tarih-formati]].
4. **Merkezi ikon/metin sistemi koruma testiyle.** Emoji, sabit metin, `Icons.xxx` sızıntısı testle yakalanıyor: [[008-merkezi-ikon-ve-metin]].
5. **Dürüst doğrulama kaydı.** Wiki'de doğrulananlar ve doğrulanmayanlar ayrı tutuluyor, emülatör turları tarihli: [[emulator-test-notlari]], [[bilinen-sorunlar]]. Metodoloji madde 7 ("doğrulanamayanı doğrulanmış gibi sunma") bu sayede karşılanıyor.

---

## Bölüm C — İncelenmedi Listesi

| Konu | Neden |
|---|---|
| `ios/` altı derleme davranışı | Windows'ta derlenemiyor; yalnızca `Info.plist` ve `AppDelegate` okundu |
| Bağımlılık CVE taraması | Tarama aracı ve ağ erişimi bu oturumda kullanılmadı |
| Bağımlılık lisans uyumu | Paket lisansları tek tek okunmadı |
| Cyclomatic/kognitif karmaşıklık | Dart için metrik aracı kurulu değil |
| Gerçek cihaz davranışı (pil kısıtı, OEM) | Cihaz yok; yalnızca emülatör |
| Widget ağaçlarının iç içe derinliği | Widget ağaçları doğası gereği derin; ölçüme dahil edilmedi |
| Wiki'nin her cümlesi | Betikle bağlantı/öksüz taraması ve örnek doğrulama yapıldı; tam anlam denetimi yapılmadı |
| `pubspec.lock` içeriği | Yalnızca varlığı ve tek lock olduğu raporlandı |

---

## Bölüm D — Detaylı Bulgular

### [🟠] 1. Din verisi Android bulut yedeğine giriyor
- **Persona:** DevSecOps. **Dosya:** `android/app/src/main/AndroidManifest.xml:10` (`<application` etiketi), `packages/namaz_backend/lib/src/data/settings_repository.dart` (`last_location`).
- **Kategori:** Güvenlik / Yasal.
- **Sorun:** `android:allowBackup`, `android:fullBackupContent` ve `android:dataExtractionRules` tanımlı değil. Android varsayılanı yedeklemeye izin verir; namaz kayıtları (`namaz_takip.db`) ve son konum (`shared_preferences`, düz metin) kullanıcının Google hesabına yedeklenir. Namaz takibi dini inanç bilgisi taşır ve KVKK m.6 kapsamında özel nitelikli kişisel veri sınıfına girer.
- **Etki:** Uygulama yayınlandığında kullanıcı verisi, kullanıcının bilgisi dışında bulutta ve yeni cihaza aktarımda kopyalanır; açık rıza ve aydınlatma metni yoktur. Yayın günü bu bulgu 🔴 olur.
- **Kanıt:**
```xml
<application
    android:label="Namaz Takip"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">   <!-- allowBackup yok -->
```
- **Çözüm:**
```xml
<application android:allowBackup="false"
    android:dataExtractionRules="@xml/data_extraction_rules" ...>
```
  Kullanıcı verisini bilinçli yedeklemek isterse yalnızca şifreli dışa aktarma sunulur. Ayrıca gizlilik politikası ve uygulama içi "verilerimi sil/dışa aktar" eylemi gerekir.
- **Düzeltme Eforu:** S (manifest); M (gizlilik politikası + silme/dışa aktarma).
- **Bağımlılık:** Yayın kontrol listesi ([[derleme-ve-yayin]]); cihaz değiştirince verinin taşınmaması kullanıcı beklentisiyle birlikte düşünülmeli.

### [🟠] 2. Release derlemesi debug anahtarıyla imzalı
- **Persona:** DevSecOps / SRE. **Dosya:** `android/app/build.gradle.kts:38`. **Kategori:** Production.
- **Sorun:** `buildTypes.release` `signingConfigs.getByName("debug")` kullanıyor. Debug anahtarı herkes tarafından üretilebilir ve mağaza kabul etmez.
- **Etki:** Play Store'a yüklenemez; yan yüklenen APK'ya başkası aynı anahtarla imzalı sahte sürüm yapıp güncelleme olarak sunabilir.
- **Kanıt:**
```kotlin
release { signingConfig = signingConfigs.getByName("debug") }
```
- **Çözüm:** `key.properties` (depoya girmez, `.gitignore`'a eklenir) okuyan `signingConfigs.release` bloğu; adımlar [[derleme-ve-yayin]] sayfasında.
- **Düzeltme Eforu:** M. **Bağımlılık:** Keystore'un güvenli yedeği; kaybolursa güncelleme yayınlanamaz.

### [🟠] 3. Tam zamanlı alarm izni reddedilince bildirim bir saate kadar geç gelir
- **Persona:** SRE. **Dosya:** `packages/namaz_backend/lib/src/platform/notification_service.dart:76,98`. **Kategori:** Production / Mantık.
- **Sorun:** Taze kurulumda `SCHEDULE_EXACT_ALARM` kapalı. Uygulama izin ekranını açıyor ama kullanıcı anahtarı açmadan dönerse `inexactAllowWhileIdle`'a düşüyor ve kullanıcıya hiçbir uyarı gösterilmiyor.
- **Etki:** Emülatörde ölçüldü: alarm penceresi `window=+1h`, 05:56 alarmı saatinde ateşlenmedi; izin verilince `window=0`. Namaz vakti bildirimi için bir saat gecikme ürünün amacını bozar.
- **Kanıt:**
```dart
final exactOk = await android?.canScheduleExactNotifications() ?? true;
final mode = exactOk ? exactAllowWhileIdle : inexactAllowWhileIdle;  // sessiz düşüş
```
- **Çözüm:** `NamazBackend`'e `exactAlarmsAllowed` ekle; Ayarlar'da izin yoksa kalıcı uyarı kartı ve "Ayarlara git" düğmesi göster; ilk açılışta izni gerekçesiyle açıkla. Alternatif olarak mağaza politikası uygunsa `USE_EXACT_ALARM`.
- **Düzeltme Eforu:** M. **Bağımlılık:** [[izinler]], arayüz metinleri ([[metin-sistemi]]).

### [🟠] 4. 04:00 sabit gün sınırı: yaz aylarında Sabah namazı önceki güne yazılır
- **Persona:** Kıdemli Mimar (mantık). **Dosya:** `packages/namaz_backend/lib/src/domain/dates.dart:4,24-27`. **Kategori:** Mantık.
- **Sorun:** `prayerDay` saat 04:00'e kadar dünü döndürür. Haziranda İstanbul'da Sabah vakti 03:24, Ankara'da 03:17'dir ([[namaz-vakitleri]] tablosu). 03:24 ile 04:00 arasında Sabah vakti girmiştir ama takip günü hâlâ dündür.
- **Etki:** Kullanıcı 03:30'da Sabah'ı "kıldım" işaretlerse kayıt **dünün** Sabah satırına yazılır; bugünün Sabah'ı bekliyor kalır ve ertesi gün otomatik kaza olur. Seri ve istatistik yanlış gün sayar.
- **Kanıt:**
```dart
const int kLateNightCutoffHour = 4;
DateTime prayerDay(DateTime now) =>
    now.hour < kLateNightCutoffHour ? addDays(dateOnly(now), -1) : dateOnly(now);
```
- **Çözüm:** Gün sınırını sabit saat yerine o günün Sabah vaktine bağla: `now < bugününFecri` ise dün. `prayerDay(now, fajrToday)` biçiminde saf fonksiyon; `NamazBackend` vakitleri bildiğinden `trackingDay(now)` olarak sunulur. Birim test: haziran 03:30.
- **Düzeltme Eforu:** M. **Bağımlılık:** `TrackingDayNotifier`, kaza hesabı, bildirim "dünkü Yatsı" mantığı ([[takip-gunu-ve-sayac]]).

### [🟠] 5. Eşzamanlı `reschedule` yarışı: işaretlenmiş vaktin hatırlatması geri gelir
- **Persona:** SRE / QA. **Dosya:** `namaz_backend_impl.dart:160,166,253-257`, `notification_service.dart:114-129`. **Kategori:** Mantık / Race.
- **Sorun:** `markPerformed` ve `markMissed` `unawaited` bir `reschedule()` başlatır. `apply` önce plan dışı bildirimleri iptal eder, sonra planı sırayla (≈70 platform çağrısı) `zonedSchedule` eder. İki işaretleme art arda gelirse A, B'nin iptal ettiği hatırlatmayı sonradan yeniden ekler.
- **Etki:** Kod okumasından çıkarım, yeniden üretilmedi: art arda iki vakit işaretlenince (geçmiş vakitleri toplu işaretleme) ikinci vaktin hatırlatması, vakit kılınmış olduğu hâlde yine gelir.
- **Kanıt:**
```dart
unawaited(_scheduler.reschedule().catchError(...));  // seri hale getirilmemiş
```
- **Çözüm:** `reschedule`'u tek kuyrukta serileştir (önceki bitmeden yenisini başlatma, bitince bir kez daha çalıştır). Test: iki eşzamanlı çağrı sonrası bekleyen kimlikler son plana eşit.
- **Düzeltme Eforu:** M. **Bağımlılık:** `NotificationScheduler`, arka plan görevi ([[bildirimler]]).

### [🟠] 6. Başlatma hatası yakalanmıyor, çökme izlenmiyor
- **Persona:** SRE. **Dosya:** `lib/main.dart:18-26`. **Kategori:** Production.
- **Sorun:** `NamazBackend.create` (veritabanı açma, `shared_preferences`, bildirim ve Workmanager başlatma) hata verirse istisna `main`'den kaçar; `runApp` hiç çağrılmaz. `FlutterError.onError`, `runZonedGuarded` veya hata ekranı yok.
- **Etki:** Bozuk veritabanı dosyası veya dolu disk durumunda uygulama açılışta boş ekranla kalır; kullanıcı ve geliştirici neden olduğunu göremez.
- **Kanıt:**
```dart
final backend = await NamazBackend.create(...);   // try/catch yok
runApp(...);
```
- **Çözüm:** `try/catch` ile `runApp(StartupErrorApp(error))` (yeniden dene / verileri sıfırla seçenekleri), `FlutterError.onError` ve `PlatformDispatcher.instance.onError` ile merkezi günlük.
- **Düzeltme Eforu:** S. **Bağımlılık:** Günlükleme altyapısı (bkz. #13).

### [🟠→✅ yanlış pozitif] 7. Saat dilimi alınamazsa bildirimler sessizce UTC'de kurulur
- **Düzeltme notu (2026-10-26):** Bu bulgunun etki iddiası **yanlıştı**. `timezone` paketinde `TZDateTime.from` mutlak anı korur ve `flutter_local_notifications` native tarafa bölge adıyla aynı bölgedeki duvar saatini gönderir; `tz.local` UTC kalsa bile tek seferlik bildirimler doğru ana kurulur. Kod okumasından çıkardığım sonucu doğrulamadan raporlamıştım. Sonuç: yedek mekanizma yazılmadı; varsayımı koruyan `time_zone_instant_test.dart` ve açıklayıcı bir yorum eklendi. Aşağıdaki özgün metin tarihsel kayıt olarak bırakıldı.

- **Persona:** Kıdemli Mimar (yerel bağlam). **Dosya:** `notification_service.dart:37-44`. **Kategori:** Hata yönetimi.
- **Sorun:** `FlutterTimezone.getLocalTimezone()` hata verirse yalnızca `debugPrint` yazılır; `tz.local` `timezone` paketinin varsayılanı olan UTC'de kalır ve `zonedSchedule` bu bölgeyle çalışır.
- **Etki:** UTC+3 cihazda tüm bildirimler 3 saat kayık kurulur; kullanıcıya ve loga görünür bir işaret yoktur (release'te `debugPrint` günlüğü okunmaz).
- **Kanıt:**
```dart
} catch (e) { debugPrint('[Notifications] timezone alınamadı: $e'); }  // tz.local = UTC
```
- **Çözüm:** Hatayı yutma; cihaz zaman farkından (`DateTime.now().timeZoneOffset`) sabit ofsetli bir `tz.Location` kur veya planlamayı iptal edip ayarlarda uyarı göster.
- **Düzeltme Eforu:** S. **Bağımlılık:** #13.

### [🟡] 8. Her uygulama dönüşünde GPS ve tam yeniden planlama
- **Persona:** DevOps (performans). **Dosya:** `lib/ui/screens/home_screen.dart:66-69`, `namaz_backend_impl.dart:131-135`. **Kategori:** Performans.
- **Sorun:** `AppLifecycleState.resumed` her seferinde `locationRefreshProvider`'ı geçersiz kılar; otomatik modda bu 10 sn (`medium`) + 25 sn (`high`) konum denemesi ve başarıda `_afterSettingsChange` ile tam yeniden planlama (iptal döngüsü + ≈70 `zonedSchedule`) demektir; konum değişmemiş olsa bile.
- **Etki:** Uygulamaya her dönüşte pil ve GPS kullanımı. Süre ölçülmedi; yapı statik olarak gösteriyor.
- **Kanıt:**
```dart
if (state == AppLifecycleState.resumed) { ref.invalidate(locationRefreshProvider); ... }
```
- **Çözüm:** Konumu en çok 30 dakikada bir tazele; yeni konum kayıtlı konumdan 5 km'den az farklıysa yeniden planlama yapma.
- **Düzeltme Eforu:** S. **Bağımlılık:** #5 (planlama kuyruğu).

### [🟡] 9. `NamazBackendImpl`: yedi sorumluluk, 23 metot, test yok, singleton bağımlılığı
- **Persona:** Kıdemli Mimar. **Dosya:** `namaz_backend_impl.dart:24-259`. **Kategori:** Mimari / Test.
- **Sorun:** Tek sınıf ayar, konum, vakit, takip, kaza, istatistik ve bildirimi yönetiyor (235 satır, ≈23 metot; eşik 20). Bağımlılıklarını kendi üretiyor (`const PrayerTimeService()`, `const LocationService()`, `NotificationService.instance`); kurucu özel, sahte (fake) enjekte edilemiyor.
- **Etki:** Radar paydası, karşılaştırma farkı, konum yedeği ve yeniden planlama tetikleyicileri birim testle doğrulanamıyor (0 test). Bu mantık projenin kuralları, ama test dışında.
- **Kanıt:**
```dart
final NotificationService _notifications = NotificationService.instance;
```
- **Çözüm:** Facade'ı ince tut, kuralları `StatsService`, `QazaService`, `LocationCoordinator` sınıflarına böl; bağımlılıkları kurucudan enjekte et (`NotificationService` için arayüz).
- **Düzeltme Eforu:** L. **Bağımlılık:** `NamazBackend` arayüzü değişmez; `architecture_test` katman kuralları geçerli kalmalı.

### [🟡] 10. Test oranı 0,17; kritik sınıflar testsiz
- **Persona:** QA. **Dosya:** `test/`, `packages/namaz_backend/test/`. **Kategori:** Test.
- **Mevcut durum:** 55 test (ön yüz 19, backend 36); piramit: birim ağırlıklı, entegrasyon yok (repository testi gerçek SQLite kullanır, bu entegrasyona yakın), e2e yok. UI'da widget testi 0.
- **Testsiz sınıflar:** `NamazBackendImpl`, `LocationService`, `NotificationService`, `NotificationScheduler`, `SettingsRepository`, tüm ekranlar.
- **En kritik 5 fonksiyon için eklenecek test durumları:**
  1. `prayerDay`: haziran 03:30 (Sabah vakti girmiş) → bugün; kış 03:30 → dün (#4).
  2. `NamazBackendImpl.radar`: kurulumdan 3 gün sonra 30 günlük aralıkta payda 3; boş veri → 0.
  3. `NotificationScheduler.reschedule`: konum yok → hiçbir şey planlanmaz; bildirim kapalı → hepsi iptal; iki eşzamanlı çağrı (#5).
  4. `LocationService.current`: `medium` zaman aşımı → `high`; ikisi de başarısız → son konum; hiçbiri yok → `unavailable`.
  5. `SettingsRepository.effectiveLocation`: elle mod + elle konum yok → son konuma düş; bozuk JSON → `null`.
- **Edge case'ler:** boş/null konum, dolu disk, yetki reddi, eşzamanlı işaretleme, gece yarısı sınırı.
- **Flaky belirtisi:** `time.sleep` veya gerçek ağ çağrısı yok ✓.
- **Düzeltme Eforu:** L. **Bağımlılık:** #9 (enjeksiyon olmadan yazılamaz).

### [🟡] 11. `stats_screen.dart` 519 satır; yedi uzun `build`
- **Persona:** Kıdemli Mimar. **Dosya:** `lib/ui/screens/stats_screen.dart` (519), `settings_screen.dart:15` (122 satır), `about_screen.dart:11` (78), `prayer_card.dart:29` (74). **Kategori:** Kod kalitesi.
- **Sorun:** Üç sekme (radar, ısı haritası, karşılaştırma) tek dosyada; `_ComparisonTabState` 219 satır; `build` metodları 60-122 satır (eşik 50). `PrayerCard` 8 parametre (eşik 5).
- **Etki:** Bir sekmeyi değiştirmek 500 satırlık dosyayı yeniden okutur; widget testi yazmak zor.
- **Çözüm:** `lib/ui/screens/stats/` altında `radar_tab.dart`, `heatmap_tab.dart`, `comparison_tab.dart`; grafik kurucularını (`_bar`, `_line`) ayrı widget'lara çıkar; `settings_screen` bölümlerini widget'laştır.
- **Düzeltme Eforu:** M. **Bağımlılık:** Yok (yalnızca taşıma); `central_system_test` yolları değişmez.

### [🟡] 12. Yanlış veya otomatik kaza kaydını düzeltme yolu yok
- **Persona:** QA / Ürün mantığı. **Dosya:** `lib/ui/screens/qaza_screen.dart`, `QazaNotifier.compensate`. **Kategori:** Mantık.
- **Sorun:** Geçmiş bir gün için tek eylem "Kaza Et" (durum 3, "zamanında kılınmadı" sayılır). Takip başlangıç gününün Sabah/Öğle'si, uygulama kurulmadan önce geçmiş olsa da otomatik kaza olarak listelenir; "bu zamanında kılınmıştı" veya "bu kayıt hatalı, sil" seçeneği yoktur. Ana ekran yalnızca bugünü düzenler.
- **Etki:** Kullanıcı 21:00'de kurarsa ertesi gün 5 vakit "otomatik tespit" kaza görür, yanlış borç hissi doğar; yanlışlıkla "Kılmadım" basılan geçmiş gün düzeltilemez, seriyi ve rozetleri bozar.
- **Çözüm:** Kaza satırında ikinci eylem "Vaktinde kılmıştım" (durum 1) ve "Kaydı kaldır"; takip başlangıcında kurulum saatinden önceki vakitleri hariç tut.
- **Düzeltme Eforu:** M. **Bağımlılık:** `NamazBackend` yeni yöntem, [[kaza-sistemi]].

### [🟡] 13. Sessiz yutulan hatalar ve yetersiz loglama
- **Persona:** SRE. **Dosya:** `settings_repository.dart:68` (`catch (_)` → `null`), `notification_plan.dart:55`, `location_service.dart:64` (geocoding hatası), `home_screen.dart:46,110`, `notification_service.dart:42`. **Kategori:** Hata yönetimi / Production.
- **Sorun:** On `catch` bloğundan beşi hatayı atıp yalnızca varsayılan döner; günlükleme yalnızca beş `debugPrint` çağrısıdır (seviye, yapı, korelasyon kimliği yok). Özel istisna sınıfı yalnızca `LocationException`.
- **Etki:** Bozuk kayıtlı konum JSON'u sessizce silinmiş sayılır; geocoding çökerse kullanıcı şehir adı yerine koordinat görür ve neden bilinmez.
- **Çözüm:** Küçük bir `Log` yardımcısı (seviye + etiket), yutulan her hata en az `warning` olarak yazılsın; kayıt bozulması için `StorageException`.
- **Düzeltme Eforu:** S. **Bağımlılık:** #6, #7.

### [🟡] 14. Ayarlar başlıkları "BILDIRIMLER" (Türkçe büyük harf bozuk)
- **Persona:** Kıdemli Mimar (yerel bağlam). **Dosya:** `lib/ui/screens/settings_screen.dart:22`. **Kategori:** Yerel bağlam.
- **Sorun:** `title.toUpperCase()` Dart'ın yerel-bağımsız çevirisini kullanır: "Bildirimler" → "BILDIRIMLER", "Konum ve Vakitler" → "KONUM VE VAKITLER". Aynı hata diyalog başlığında `turkishUpper` ile düzeltilmişti; burası atlandı.
- **Etki:** Emülatör ekran görüntüsünde görüldü: noktasız büyük I. `central_system_test` bunu yakalamıyor.
- **Kanıt:**
```dart
child: Text(title.toUpperCase(), ...)
```
- **Çözüm:** `turkishUpper(title)`; koruma testine `lib/ui` içinde `.toUpperCase()`/`.toLowerCase()` yasağı ekle.
- **Düzeltme Eforu:** S. **Bağımlılık:** [[metin-sistemi]].

### [🟡] 15. Commit mesajları İngilizce ve AI referanslı (metodoloji 6)
- **Persona:** Süreç. **Dosya:** `git log` (bu branch'teki 5 commit). **Kategori:** Süreç.
- **Sorun:** Metodoloji: mesajlar Türkçe, Türkçe karakterli, "Co-Authored-By/Generated with/🤖" yok. Tüm commit'ler (`ebce2b2`, `0d94fbc`, `bb1ab70`, `d46cb18`, `564245e`) İngilizce ve `Co-Authored-By: Claude ...` satırı taşıyor.
- **Etki:** Kullanıcının tanımladığı disiplinle çelişki; geçmiş okunurluğu.
- **Kanıt:** `git log --format=%B -1` çıktısında `Co-Authored-By: Claude Sonnet 5.5`.
- **Çözüm:** Commit'ler henüz push edilmedi; `git filter-branch --msg-filter` ile mesajları Türkçe ve referanssız yeniden yazmak güvenlidir. Bundan sonraki commit'ler kurala uyar.
- **Düzeltme Eforu:** S. **Bağımlılık:** Yalnızca geçmiş yeniden yazılır; kod değişmez. **Onay gerekir.**
- **Not:** Commit öncesi `git status`/`.gitignore` kontrolü (metodoloji 6) bu turda gerekliydi: `564245e`'e backend test derleme çıktıları girmişti (`packages/namaz_backend/build/`); fark edildi, `**/build/` yok sayıldı ve commit düzeltildi.

### [🟡] 16. Büyük özellik için plan/onay akışı atlandı (metodoloji 4)
- **Persona:** Süreç. **Kategori:** Süreç.
- **Sorun:** Metodoloji, 3+ dosyayı etkileyen ve birden çok makul yaklaşımı olan işlerde netleştirici soru → plan → onay → sıralı uygulama ister. Ön yüz/backend ayrımı (≈45 dosya, paket workspace, port tasarımı) ve RN→Flutter yeniden yazımı doğrudan uygulandı; kapsam dışı bırakmalar (backend içi port yok, tema anahtarı backend'de) yalnızca uygulamadan sonra ADR'ye yazıldı.
- **Etki:** Kullanıcı seçenekleri (paket mi klasör mü, tema anahtarı nerede) önceden görmedi.
- **Çözüm:** Bundan sonra aynı büyüklükte işler plan modunda, kapsam dışı kararlar planda gerekçeli sunulur. Düzeltilecek kod yok.
- **Düzeltme Eforu:** — (süreç). **Bağımlılık:** [[wiki-kullanim]].

### [🟡] 17. README ve `build_apk.md` eskimiş; pubspec açıklaması bozuk
- **Persona:** Kıdemli Mimar (dokümantasyon). **Dosya:** `README.md` ("Proje yapısı"), `../.agent/workflows/build_apk.md`, `pubspec.yaml:2`. **Kategori:** Dokümantasyon.
- **Sorun:** README hâlâ `lib/data/`, `lib/services/`, `lib/core/` ağacını ve tek `flutter test` komutunu gösteriyor; bunlar ayrımdan sonra yok (`packages/namaz_backend/` yok). `build_apk.md` yalnızca ön yüz testini anıyor. `pubspec.yaml` açıklaması "Namaz takip ve kaza namazi sayaci" (ASCII, "namazı" yerine). Metodoloji: kod değişikliği ile doküman aynı turda güncellenir; wiki güncellendi, README güncellenmedi.
- **Kanıt:**
```
lib/
  data/        SQLite (sqflite), repository'ler, il listesi
  services/    vakit hesabı, konum, bildirim, arka plan görevi
```
- **Çözüm:** README'yi iki paketli yapıya ve iki test komutuna göre güncelle; `build_apk.md`'ye backend testi ekle; açıklamayı düzelt.
- **Düzeltme Eforu:** S. **Bağımlılık:** Yok.

### [🟡] 18. CI/CD yok
- **Persona:** SRE / DevOps. **Dosya:** `.github/` yok. **Kategori:** Production.
- **Sorun:** Analiz, iki paketin testi ve derleme yalnızca elle çalıştırılıyor; derleme tek komutla çalışıyor ✓ ve `pubspec.lock` var ✓ (tekrarlanabilir), ama otomatik kapı yok. dev/staging/prod ayrımı yok (ağsız uygulama için tek ortam yeterli); `DEBUG` sızıntı riski yok.
- **Etki:** Mimari sınır testleri ve analiz yalnızca geliştirici hatırlarsa çalışır.
- **Çözüm:** GitHub Actions: `flutter analyze`, `flutter test`, `cd packages/namaz_backend && flutter test`, `flutter build apk --debug`.
- **Düzeltme Eforu:** M. **Bağımlılık:** Depo barındırma kararı. Geri alma stratejisi mağaza yayını öncesi tanımlanmalı.

### [🟢] 19. DRY: ısı haritası renkleri iki kez, 13 sabit renk
- **Dosya:** `lib/ui/screens/stats_screen.dart:170-173` ve `:228-231`, ayrıca `prayer_card.dart`. **Kategori:** Kod kalitesi.
- **Sorun:** Dört renk (`0xFF4CAF50`, `0xFFFFC107`, `0xFFFF9800`, `0xFFEF5350`) hücre rengi ve açıklamada ayrı ayrı yazılı; arayüzde toplam 13 sabit `Color(0x...)` var, tema dışı.
- **Çözüm:** `HeatLevel` enum'ı veya `AppPalette`'e `heat*` alanları.
- **Düzeltme Eforu:** S.

### [🟢] 20. Shotgun surgery: hesaplama yöntemi 3, tema 3, rozet 4 yer
- **Dosya:** `prayer_time_service.dart` (`CalcMethod.params`), `settings_strings.dart` (`calcMethodName`), `AppIcons.theme`, `GamificationStrings`. **Kategori:** Mimari.
- **Sorun:** Yeni varyant eklemek birden çok dosyayı değiştirir (Open/Closed ihlali). `switch` ifadeleri derleyiciyle zorunlu kılındığı için unutulmaz; maliyet dosya sayısıdır.
- **Çözüm:** Bir kayıt tablosu (`CalcMethodInfo(key, params)`); metin/ikon yine ön yüzde kalır. Düşük öncelik: yeni varyant sık eklenmiyor.
- **Düzeltme Eforu:** M.

### [🟢] 21. Haftalık karşılaştırma takip öncesi günleri 0 sayar
- **Dosya:** `namaz_backend_impl.dart:185-191`. **Kategori:** Mantık.
- **Sorun:** Son 14 gün sabit alınır; kurulumdan önceki günler 0 işlenir. İlk hafta kılan kullanıcı "Yükselişte +N Vakit" görür. Radar paydası bu durumu doğru ele alıyor (`trackingStart`), karşılaştırma almıyor.
- **Çözüm:** Önceki hafta tamamen takip öncesindeyse "Veri yok" göster.
- **Düzeltme Eforu:** S.

### [🟢] 22. `cupertino_icons` kullanılmıyor; LICENSE yok; lisans ve CVE taranmadı
- **Dosya:** `pubspec.yaml`, depo kökü. **Kategori:** Güvenlik.
- **Sorun:** `cupertino_icons` bildirilmiş, `lib/` içinde 0 kullanım. 19 bağımlılık `^` aralığındadır; `pubspec.lock` ile sabitlenmiş olduğundan yeniden üretilebilir. Depoda `LICENSE` dosyası yok. Bağımlılık CVE ve lisans uyumu denetlenmedi (bkz. Bölüm C). Git geçmişinde sır/anahtar deseni taraması: 0 sonuç ✓; kaynakta sabit parola/anahtar yok ✓.
- **Çözüm:** `cupertino_icons`'u kaldır; yayın öncesi lisans listesi çıkar (`flutter pub deps` + paket lisansları); LICENSE ekle.
- **Düzeltme Eforu:** S.

### [🟢] 23. Mimari testler çalışma dizinine bağlı
- **Dosya:** `test/architecture_test.dart`, `packages/namaz_backend/test/architecture_test.dart` (`Directory('lib')`). **Kategori:** Test.
- **Sorun:** Yol göreli; backend testi kökten çalıştırılırsa (`flutter test packages/namaz_backend/...`) yanlış klasörü tarar.
- **Çözüm:** Yolu test dosyasının konumundan çöz (`Platform.script`) veya testlerin hangi dizinden çalışacağını wiki'de sabitle (sabitlendi: [[test-stratejisi]]).
- **Düzeltme Eforu:** S.

### [🟢] 24. Wiki metodolojiden üç noktada sapıyor
- **Dosya:** `CLAUDE.md`, `docs/wiki/log.md`. **Kategori:** Süreç.
- **Sorun:** (a) Metodoloji anayasayı `docs/wiki/rules.md` olarak ister ve `CLAUDE.md`'yi kısa bir giriş kapısı sayar; bu projede tüm anayasa `CLAUDE.md` içinde ve `rules.md` yok. (b) Log işlem tipleri metodolojide `INGEST/REVIEW/LINT`; projede `UPDATE/DECISION/SETUP/QUERY` de kullanılıyor, `REVIEW` ilk kez bu denetimle girer. (c) Syntax örnekleri inline code içinde ✓, öksüz sayfa 0 ✓, index tam ✓.
- **Çözüm:** `docs/wiki/rules.md` oluştur (anayasa buraya), `CLAUDE.md`'yi giriş kapısına indir; log tip listesini metodolojiyle hizala.
- **Düzeltme Eforu:** S.

---

## Bölüm E — Kriz Yönetimi / Aksiyon Planı

### 🚨 24 saat içinde (yangın söndürme)
Kritik bulgu yok; yayın yakın olmadığı için "yangın" yok. En değerli üç hızlı iş:

| # | Eylem | Beklenen sonuç | Bağımlılık | Risk |
|---|---|---|---|---|
| 1 | `allowBackup="false"` + `dataExtractionRules` (#1) | Din verisi buluta çıkmaz | Yok | Cihaz değişiminde veri taşınmaz; beklenen |
| 2 | Başlatma `try/catch` + hata ekranı (#6) | Açılış çökmesi görünür ve kurtarılabilir | Yok | Hata ekranı yanlış tetiklenirse normal açılışı engeller; testle sınırlanır |
| 3 | `turkishUpper` ayarlar başlıklarında (#14) | "BİLDİRİMLER" doğru | Yok | Yok |

### 📅 Bu hafta (stabilizasyon)
| # | Eylem | Beklenen sonuç | Bağımlılık | Risk |
|---|---|---|---|---|
| 1 | Gün sınırını Sabah vaktine bağla + test (#4) | Yaz aylarında doğru gün | `TrackingDayNotifier`, kaza | Gün sınırı değişince mevcut kayıtlar kaymaz (veri eski kuralla yazılmıştır, yayınlanmadı) |
| 2 | `reschedule` kuyruğu (#5) | Eşzamanlı çağrı yarışı kalkar | `NotificationScheduler` | Kuyruk takılırsa bildirim güncellenmez; zaman aşımı koru |
| 3 | Alarm izni uyarısı (#3) | İzin yokken kullanıcı bilgilenir | Ayarlar ekranı, metinler | Gereksiz uyarı yorgunluğu; yalnızca izin yokken göster |
| 4 | Saat dilimi hatasında yedek (#7) + `Log` (#13) | Sessiz kayma kalkar | — | Yedek ofset yanlışsa bildirim kayar; `DateTime.now().timeZoneOffset` ile doğrulanır |
| 5 | README/`build_apk.md`/pubspec düzeltmesi (#17) | Doküman gerçeği gösterir | — | Yok |

### 🗓 Bu ay (sağlamlaştırma)
| # | Eylem | Beklenen sonuç | Bağımlılık | Risk |
|---|---|---|---|---|
| 1 | `NamazBackendImpl`'i böl, bağımlılıkları enjekte et, testlerini yaz (#9, #10) | Kurallar test altında | #4, #5 sonrası | Arayüz değişmediği sürece düşük; mimari testler kapıdır |
| 2 | Kaza düzeltme eylemleri (#12) | Yanlış kayıt düzeltilir | `NamazBackend` yeni yöntem | Seri hesabı değişir; testle |
| 3 | GitHub Actions CI (#18) | Otomatik kapı | Depo barındırma | Yok |
| 4 | Release imzalama + gizlilik politikası (#2, #1) | Yayına hazır | Keystore yedeği | Anahtar kaybı güncellemeyi engeller |
| 5 | `stats_screen` bölme + `HeatLevel` (#11, #19) | Dosya < 500 satır | — | Yok (taşıma) |

Geri kalan düşük öncelikli bulgular (#20-#24) fırsat oldukça. Commit geçmişinin yeniden yazılması (#15) onay bekliyor.

---

## Bölüm F — Sonraki Adımlar

Hangi bulgudan başlamak istersin? Seçtiğin maddenin detaylı refactor planını, etkilenecek dosyaları ve örnek before/after kodunu üretebilirim.

## İlgili sayfalar

[[bilinen-sorunlar]] · [[yol-haritasi]] · [[test-stratejisi]] · [[mimari-genel]] · [[wiki-kullanim]]
