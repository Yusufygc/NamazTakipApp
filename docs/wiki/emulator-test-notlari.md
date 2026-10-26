# Emülatör Test Notları

Elle yapılan testlerin kaydı ve bulunan hatalar. Yeni bir test turu eklendiğinde bu sayfanın başına tarihli bölüm eklenir. Test yöntemi ve komutlar: [[gelistirme-ortami]], kontrol listesi: [[test-stratejisi]].

## Tur 3 — 2026-10-26, denetim bulguları #1–#7 düzeltmeleri (aynı emülatör)

| Alan | Sonuç |
|---|---|
| Yedekleme (#1) | `aapt2`: `allowBackup=false`, `dataExtractionRules` bağlı; `dumpsys package` bayraklarında `ALLOW_BACKUP` yok |
| İmzalama (#2) | Anahtarsız release hata verdi; `ALLOW_DEBUG_SIGNING=1` ile debug imzalı; geçici anahtarla `CN=Gecici Test` imzalı APK |
| Başlatma hatası (#6) | Veritabanı yolu klasör yapılınca `StartupErrorApp` göründü ("DatabaseException(open_failed ...)"); sorun sürerken "Tekrar dene" ekranda kaldı; dosya geri konulunca normal açıldı |
| Gün sınırı (#4) | Saat 21 Haziran 03:30: ana ekran "21 Haziran 2026"; Sabah işareti `2026-06-21\|fajr\|1` |
| Alarm izni (#3) | `appops deny`: uyarı kartı göründü, alarmlar `window=+1h`; izin verilip dönülünce kart kalktı, alarmlar `window=0` oldu |

**Beklenmedik bulgular:** (1) Bozuk (rastgele baytlı) veritabanı dosyası hata ekranı **vermedi**: Android `DefaultDatabaseErrorHandler` dosyayı sessizce silip boş veritabanı oluşturdu; kullanıcı geçmişini sessizce kaybeder. (2) Logda `yeniden planlama başarısız: Must be a date in the future`: plan uygulanırken geçmişe düşen bildirim kalan planı durduruyor. İkisi de [[bilinen-sorunlar]]'a işlendi. (3) Denetim bulgusu #7 (saat dilimi yedeği) kaynak kod okumasıyla **yanlış pozitif** çıktı: [[bildirimler]].

## Tur 2 — 2026-10-26, front/backend ayrımından sonra (aynı emülatör)

Amaç: yeniden düzenlemenin davranışı bozmadığını doğrulamak. Test edilen sürüm: debug APK, **temiz kurulum** (uninstall + install).

| Alan | Sonuç |
|---|---|
| Açılış ve izin sırası | Önce ekran, sonra konum, sonra bildirim izni; ardından "Alarms & reminders" ekranı açıldı |
| GPS konumu | `geo fix` ile "İstanbul, Türkiye"; vakitler ve geri sayım doğru |
| İşaretleme | Öğle "Kıldım + cemaatle" → veritabanında `dhuhr\|1\|1` |
| Bildirim planı | Alarmlar kayıtlı; izin verilince tam zamanlı (`window=0`) |
| Bildirim metni | Saat 06:10:30'a alınınca 06:11'de "Sabah Namazını Kıldınız mı?" geldi (metin ön yüz adaptöründen) |
| Arka plan kaydı | `NamazBackend.create` içinde kayıt, hata yok |

**Bulgu:** Taze kurulumda "Alarms & reminders" anahtarı kapalı geldi; ben geri tuşuyla çıkınca alarmlar yaklaşık zamanlı (`window=+1h`, `flags=0x20`) kuruldu ve 05:56 alarmı saatinde ateşlenmedi. `appops set com.namaztakip.app SCHEDULE_EXACT_ALARM allow` ve yeniden açılıştan sonra alarmlar tam zamanlı oldu. Bu refaktörün hatası değil, mevcut tasarımın riskidir: [[bilinen-sorunlar]], [[izinler]], [[bildirimler]].

Düzenek notu: `adb shell date` biçimi `MMDDhhmmYYYY.ss`'dir; yıl yanlış yazılınca (`3026`) saat 3026'ya gitti ve komut hata verdi: [[gelistirme-ortami]].

Bu turda görsel ekran gezisi yapılmadı; ekranlar bir önceki turdaki sürümle aynı kodu kullanıyor ve yalnızca içe aktarmaları değişti. Test edilmeyenler listesi değişmedi.

## Tur 1 — 2026-10-26 (Android 36 emülatörü, Pixel 8, `google_apis` x86_64)

Test edilen sürüm: debug APK, yalnızca **Varsayılan** tema.

### Doğrulananlar

| Alan | Sonuç | Sayfa |
|---|---|---|
| Açılış ve izin sırası | Önce ekran çizilir, sonra konum, sonra bildirim izni | [[izinler]] |
| GPS konumu | `adb emu geo fix` ile verilen koordinattan "İstanbul, Türkiye" çözüldü | [[konum]] |
| Vakitler | İstanbul 26 Eki: 05:55 / 07:21 / 12:53 / 15:46 / 18:15 / 19:35 (Aladhan ile ≤ 1 dk fark) | [[namaz-vakitleri]] |
| Geri sayım | Saniye saniye ilerliyor; ezan vakti girince kendiliğinden bir sonraki vakte geçti | [[takip-gunu-ve-sayac]] |
| İşaretleme | Kıldım, cemaatle kıldım, Kılmadım doğru yazılıyor; yeniden açılışta korunuyor | [[namaz-isaretleme]] |
| Veritabanı | `dhuhr\|1\|0`, `maghrib\|1\|1` satırları görüldü | [[veri-katmani]] |
| Kaza | "Kılmadım" denen vakit kaza listesinde "1 Kaza" olarak göründü | [[kaza-sistemi]] |
| Rozetler | Cemaatle kılınan vakit "Cemaat Dostu 1/50" olarak yansıdı | [[seri-ve-rozetler]] |
| Süreç | Radar (Öğle %100), ısı haritası (26'sı turuncu 2/5), karşılaştırma (+2 Vakit, Yükselişte) | [[istatistikler]] |
| Ayarlar | Anahtar, hatırlatma süresi, konum radyosu, yöntem, beş tema kartı görünüyor | [[ui-ekranlar]] |
| Elle şehir | Sakarya seçilince "Sakarya, Türkiye" ve vakitler değişti; Otomatik'e dönünce İstanbul | [[konum]] |
| Alarmlar | `dumpsys alarm`: tam zamanlı (`exactAllowReason=permission`) alarmlar kayıtlı: Yatsı 19:35, hatırlatma 19:50, yarın Sabah 05:56 | [[bildirimler]] |
| Bildirim ateşlenmesi | Saat 19:34:30'a alınınca 19:35'te "Yatsı Vakti" bildirimi geldi (kimlik `202610268`) | [[bildirimler]] |
| Bildirim metni | "Selamünaleyküm! Yatsı ezanı okundu. Akşam namazını kıldın mı?" | [[bildirimler]] |
| Bildirime dokunma | "AKŞAM NAMAZINI KILDINIZ MI?" diyaloğu açıldı | [[namaz-isaretleme]] |
| Yeni ikonlar ve metinler | Çekmece, rozetler, hakkında, ayarlar, diyalog yeni ikon sistemiyle doğru | [[ikon-sistemi]], [[metin-sistemi]] |
| Launcher ikonu | Uygulama çekmecesinde hilal + minare, yuvarlak maske | [[uygulama-ikonu]] |

### Bulunan ve düzeltilen hatalar

1. **Açılışta boş splash.** `main()` bildirim izni penceresi kapanana kadar `runApp`'i bekletiyordu. İzinler artık ilk ekran çizildikten sonra, sırayla isteniyor: [[izinler]].
2. **GPS alınamıyordu (emülatörde).** `LocationAccuracy.low/medium` ağ konumu ister; emülatörde ağ konumu yok, `geo fix` ise yalnızca GPS'i besler. `medium` → `high` → son bilinen konum zinciri eklendi: [[009-konum-yedek-zinciri]].
3. **Görsel kontrast.** Şeffaf kart renkleri mat görünüyor, kırmızı yazı ve "Yükselişte" yazısı soluktu: [[erisilebilirlik-ve-kontrast]].
4. **"İKINDI" başlığı** (sonradan, kod incelemesinde): Dart `toUpperCase` Türkçe `i`'yi bozuyordu; `turkishUpper` eklendi: [[metin-sistemi]].
5. **Derleme hatası.** `permission_handler` Android 37 SDK'sı isteyip ilk derlemeyi düşürdü; kullanılmadığı için paket kaldırıldı: [[bagimliliklar]], [[android-yapilandirma]].

### Test düzeneğinin kendi sorunları (uygulama hatası değil)

- Emülatör saat dilimi UTC olduğu için vakitler 3 saat kayık göründü: `cmd alarm set-timezone Europe/Istanbul`.
- `adb shell monkey` rastgele dokunuş gönderip istemeden şehir seçtirdi: kullanılmamalı.
- Ekran görüntüsü bazen önceki kareyi gösterdi; metin için `uiautomator dump` tercih edildi: [[gelistirme-ortami]].

### Test edilmeyenler

Gerçek telefon; iOS; Koyu, Okyanus, Gül, Altın temaları; arka plan görevinin periyodik tetiklenmesi; 04:00 gün geçişi; gerçek ekran okuyucu; Android 13 temalı ikon; uygulama kapalıyken (öldürülmüşken) bildirimin ateşlenmesi: [[bilinen-sorunlar]], [[yol-haritasi]].

## İlgili sayfalar

[[test-stratejisi]] · [[gelistirme-ortami]] · [[bilinen-sorunlar]]
