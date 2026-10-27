# Ana Ekran Widget'ı

Telefon ana ekranında sıradaki vakti, günün altı saatini ve "n / 5 Eda" sayısını gösterir. Kaynak: `android/.../NamazHomeWidgetProvider.kt`, `WidgetSchedule.kt`, `res/layout/namaz_home_widget.xml`. Ayarlar ekranındaki kart widget'ı ekler ve önizler (`home_widget_preview_card.dart`). iOS tarafı derlenmez durumdadır: [[ios-yapilandirma]].

## Veri akışı

1. Dart, `NamazBackend.syncHomeWidget()` ile bir **anlık görüntü** üretir (`buildHomeWidgetSnapshot`, `domain/home_widget_snapshot.dart`) ve `com.namaztakip.app/home_widget` kanalından gönderir. Tetikleyiciler: uygulama açılışı, vakit işaretleme (planlayıcı çağrısıyla birlikte), "Güncelle" düğmesi.
2. Anlık görüntü **dünden başlayarak 7 günlük vakit programını** içerir (`schedule`: her satır bir gün, `Sabah,Güneş,Öğle,İkindi,Akşam,Yatsı` epoch ms) ve kılınma sayısının ait olduğu takip gününü (`doneDate`).
3. Android bunu `SharedPreferences`'a (`namaz_home_widget`) yazar.
4. Widget her çizimde **kendisi hesaplar** (`WidgetSchedule.compute`): sıradaki vakit, bugünün saatleri, takip günü, kılınma sayısı geçerli mi.

## Bayatlama sorunu ve çözümü (2026-10-27)

Eski sürüm yalnızca uygulama bir şey yazınca doğruydu. 30 dakikalık otomatik yenileme (`updatePeriodMillis`) aynı eski veriyi yeniden çiziyordu; bir vakit geçince "sıradaki vakit" uygulama açılana kadar yanlış kalır, gün değişince dünün saatleri görünürdü.

Şimdi:

- Sıradaki vakit ve günün saatleri programdan hesaplanır; uygulama açılmasa da 5 güne kadar doğru kalır.
- Yenileme **sıradaki vakitte veya gece yarısında** (hangisi önceyse) `AlarmManager.setAndAllowWhileIdle` ile yapılır; tam zamanlı alarm izni gerekmez (yaklaşık zamanlıdır, Doze'da birkaç dakika kayabilir).
- Saat, tarih, saat dilimi değişince ve açılışta (`TIME_SET`, `DATE_CHANGED`, `TIMEZONE_CHANGED`, `BOOT_COMPLETED`) yeniden hesaplanır.
- Kılınma sayısı yalnızca ait olduğu takip günü için gösterilir (gün sınırı `min(04:00, Sabah)`, [[takip-gunu-ve-sayac]]); yeni güne geçilince uygulama açılana kadar 0 görünür.
- Program biterse (uygulama 5+ gün açılmadıysa) sıradaki vakit "--" olur.
- Son widget kaldırılınca alarm iptal edilir.

## Doğrulama

- `WidgetScheduleTest` (Kotlin, 10 test, `./gradlew :app:testDebugUnitTest`): sıradaki vakit, vakit geçince değişim, yatsıdan sonra ertesi sabah, gün değişimi, program bitişi, takip günü sınırı (04:00 ve erken Sabah), yenileme anı, bozuk satır. Hesaplama koşulunu bozunca 6 test düştü.
- `home_widget_schedule_test.dart` (5 test): Dart'ın ürettiği program biçimi.
- Emülatör: iki widget ana ekrana eklendi; uygulama arka plandayken saat 06:00'dan 13:00'a alındı, widget "Öğle 12:47"den "İkindi 15:38"e kendiliğinden geçti. `dumpsys alarm` yenileme alarmını gösterdi.
- Denenmeyenler: gerçek cihaz/başlatıcılar (üretici başlatıcıları pil kısıtlamasıyla alarmı geciktirebilir), uygulama zorla durdurulmuşken (Android durdurulmuş uygulamaya yayın göndermez; uygulama bir kez açılana kadar widget "yükleniyor" kalır).

## Bilinen sınırlar

- Kotlin'de "Namaz Takip • şehir", "n / 5 Eda" ve vakit adları sabit Türkçe yazılıdır (metin sistemi dışında): [[bilinen-sorunlar]].
- `performedMask` ve Hicri tarih gönderilir ama Android widget kullanmaz.
- Widget'a dokununca uygulama açılır; vakit işaretlenmez.

## İlgili sayfalar

[[ui-ekranlar]] · [[bildirimler]] · [[takip-gunu-ve-sayac]] · [[hicri-takvim]] · [[test-stratejisi]]
