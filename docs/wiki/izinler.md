# İzinler

Uygulama üç tür izin kullanır: konum, bildirim ve (Android'de) tam zamanlı alarm. İzinler **ilk ekran çizildikten sonra**, sırayla ve kullanıcı bağlamını görerek istenir.

## İstek sırası

`HomeScreen.initState` içinde, ilk karenin ardından `_requestPermissions` çalışır:

1. **Konum:** `locationRefreshProvider.future` beklenir; bu çağrı konum iznini (ve servis kontrolünü) tetikler. Hata olursa ana ekran kendi kartıyla bilgi verir: [[konum]].
2. **Bildirim:** Bildirimler açıksa `NamazBackend.requestNotificationPermission()` (altta `NotificationService.requestPermissions()`); Android 13+ için bildirim izni, ayrıca tam zamanlı alarm izni yoksa ayarlar ekranı açılır; iOS'ta uyarı ve ses izni.
3. İzin adımından sonra `reschedule()` çağrılır: [[bildirimler]].

Neden sıralı: iki sistem izin penceresinin aynı anda istenmesi çakışma yaratır. Neden ilk ekrandan sonra: izin penceresi `main()` içinde beklenirse kullanıcı boş splash görür; bu hata emülatör testinde bulundu ve düzeltildi: [[emulator-test-notlari]].

Ayarlarda bildirimler kapalıyken açılırsa (`setNotifications(true)`) bildirim izni yeniden istenir.

## Android

`AndroidManifest.xml` içinde ([[android-yapilandirma]]):

| İzin | Ne için |
|---|---|
| `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` | Konum |
| `POST_NOTIFICATIONS` | Bildirim (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Tam zamanlı alarm; kullanıcı ayarlardan verir |
| `RECEIVE_BOOT_COMPLETED` | Yeniden başlatma sonrası bildirimlerin geri yüklenmesi |
| `VIBRATE`, `WAKE_LOCK` | Bildirim titreşimi ve uyandırma |

`SCHEDULE_EXACT_ALARM` yerine `USE_EXACT_ALARM` seçilebilirdi (kullanıcıya sormaz) ama mağaza denetimine tabidir; şimdilik ilki kullanılır. Emülatörde uygulama "Alarms & reminders" ekranını açar; önceki kurulumda anahtar açıktı, **temiz kurulumda kapalı olabilir** ve geri tuşuyla çıkılırsa alarmlar yaklaşık zamanlı kalır (gözlendi).

## iOS

`Info.plist`: `NSLocationWhenInUseUsageDescription` ("Namaz vakitlerini bulunduğunuz yere göre hesaplamak için konumunuza ihtiyacımız var."). Bildirim izni çalışma zamanında istenir. Ayrıntı: [[ios-yapilandirma]].

## Reddedilirse

| Durum | Davranış |
|---|---|
| Konum servisi kapalı / izin verilmedi / kalıcı reddedildi | Ana ekranda ilgili mesaj, "Tekrar dene" ve "Şehir seç" düğmeleri; elle şehir ile uygulama tam çalışır |
| Bildirim izni verilmedi | Uygulama çalışır, bildirim gelmez; ayarlarda anahtar açık kalabilir |
| Tam zamanlı alarm yok | Bildirimler `inexact` modda planlanır; emülatörde alarm penceresi `+1 saat` göründü, yani bildirim **bir saate kadar geç** gelebilir. Taze kurulumda izin varsayılan olarak kapalıdır ve kullanıcı ayarlar ekranında anahtarı açmalıdır: [[bilinen-sorunlar]] |

## İlgili sayfalar

[[konum]] · [[bildirimler]] · [[ui-ekranlar]]
