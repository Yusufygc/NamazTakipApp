# Bildirimler

Uygulama yerel (cihazda zamanlanan) bildirim kullanır; sunucu veya push yoktur. Bildirim işi tamamen [[backend-paketi]]'ndedir; ön yüz yalnızca **metinleri** verir. Üç parça vardır: kararı veren saf **plan**, eklentiye dokunan ince **uygulayıcı** ve metinleri sağlayan **port**.

| Dosya | Rol |
|---|---|
| `packages/namaz_backend/lib/src/domain/notification_plan.dart` | `buildNotificationPlan`, `notificationId`, `PrayerPrompt`: saf mantık |
| `packages/namaz_backend/lib/src/application/notification_scheduler.dart` | Ayar, konum ve işaretleme durumundan planı kurup uygular |
| `packages/namaz_backend/lib/src/platform/notification_service.dart` | `flutter_local_notifications` çağrıları, izinler, dokunma olayları |
| `packages/namaz_backend/lib/src/application/namaz_backend_impl.dart` | İşaretleme ve ayar değişince yeniden planlamayı tetikler |
| `packages/namaz_backend/lib/src/domain/notification_plan.dart` içindeki `NotificationTexts` | Metin portu: backend metni **üretmez**, ön yüzden alır |
| `lib/core/strings/notification_texts_adapter.dart` | Portun ön yüz uygulaması (`AppNotificationTexts`) |
| `lib/core/strings/notification_strings.dart` | Metinlerin kendisi: [[metin-sistemi]] |

## İki tür bildirim

Her vakit için en çok iki bildirim üretilir.

1. **Ezan bildirimi** (vakit girince): "Selamünaleyküm! *X* ezanı okundu. *Önceki vakit* namazını kıldın mı?". Sorulan vakit, girilen vaktin bir öncekidir; Sabah ezanında sorulan **dünkü Yatsı**'dır. Önceki vakit zaten kılındıysa (veya kaza edildiyse) yalnızca "X vakti girdi." denir ve soru taşınmaz.
2. **Hatırlatma** (ezandan `reminder_minutes` sonra, varsayılan 15): "X Namazını Kıldınız mı? / Namazınızı işaretlemek için dokunun." Vakit zaten işaretliyse hiç üretilmez.

Bildirim başlık ve metinlerinde emoji yoktur; sistem uygulama ikonunu gösterir: [[ikon-sistemi]].

## Metinler: port ve adaptör

`buildNotificationPlan` hangi vakit için hangi bildirimin gerektiğini söyler ama metni yazmaz; `NotificationTexts` portunu çağırır (`adhanTitle`, `adhanBody`, `adhanAskBody`, `reminderTitle`, `reminderBody`, kanal adı ve açıklaması). Ön yüz `AppNotificationTexts` ile portu doldurur ve `NamazBackendConfig.notificationTexts` olarak verir; arka plan görevinde de aynı adaptör kullanılır ([[arka-plan-gorevleri]]). Böylece backend dilden bağımsızdır ve testlerde sahte metinle çalışır: [[011-front-backend-ayrimi]].

## Kimlikler

`notificationId = yyyymmdd × 10 + vakit × 2 + (hatırlatma ? 1 : 0)`; örnek: 26 Ekim 2026 Yatsı ezanı = `202610268`. Aynı vakit için her zaman aynı kimlik üretilir; bu yüzden yeniden planlama bildirimi çoğaltmaz, üzerine yazar. Eski uygulamadaki "hatırlatma aynı anda iki kez geliyor" hatasının yapısal çözümüdür: [[004-sabit-bildirim-kimlikleri]]. Değerler 32 bit işaretli sınırın altında kalır (testle doğrulanır).

## Planlama penceresi

Bugünden başlayarak `planningDays` gün planlanır: **Android 10, iOS 6**. iOS en fazla 64 bekleyen bildirim tutar; 6 gün × en çok 10 bildirim = 60: [[ios-yapilandirma]]. Geçmişteki zamanlar için bildirim üretilmez.

## Uygulama (`NotificationService.apply`)

1. Plan dışında kalan bekleyen bildirimler iptal edilir (örn. artık işaretlenmiş vaktin hatırlatması).
2. Her planlanan bildirim `zonedSchedule` ile eklenir; zaman `tz.local` saat diliminde `TZDateTime`'dır.
3. Android'de tam zamanlı alarm izni varsa `exactAllowWhileIdle`, yoksa `inexactAllowWhileIdle` kullanılır. **Yaklaşık modda sistem alarmı bir saate kadar kaydırabilir:** emülatörde izin verilmeyince alarmlar `window=+1h` (yaklaşık) göründü, izin verilince `window=0` (tam zamanlı). Bu, bir namaz uygulaması için ciddi bir risktir: [[bilinen-sorunlar]], [[izinler]].
4. Kanal: `prayer_times`, ad "Namaz Vakitleri", önem derecesi yüksek.

Bildirimler kapalıysa (`notifications_enabled = false`) tüm bekleyenler iptal edilir ve plan kurulmaz.

## Ne zaman yeniden planlanır

`NotificationScheduler.reschedule()` şu durumlarda çağrılır. İlk üçünü backend **kendisi** yapar, ön yüz bilmez:

- Bir vakit işaretlenince (`markPerformed`/`markMissed`, [[namaz-isaretleme]]).
- Bildirim, hatırlatma süresi, hesaplama yöntemi veya konum ayarı değişince, ve GPS'ten yeni konum alınınca ([[durum-yonetimi]]).
- Arka plan görevinde, 12 saatte bir ([[arka-plan-gorevleri]]).
- Açılışta izinler istendikten sonra, ön yüz `rescheduleNotifications()` çağırır ([[izinler]]).

Zamanlama ayarlardaki konumla yapılır; konum yoksa hiçbir şey planlanmaz.

## Dokunma

Bildirime dokununca payload `ask|yyyy-MM-dd|vakit` çözülür (`PrayerPrompt.decode`) ve ana ekran o tarih ve vakit için diyaloğu açar: [[namaz-isaretleme]]. Uygulama kapalıyken bildirimle başlatılırsa `launchPrompt` ilk karede işlenir. Bozuk payload sessizce yok sayılır.

## Test

- `packages/namaz_backend/test/notification_plan_test.dart`: kimlikler benzersiz ve kararlı; aynı kimlik iki kez yok (20 bildirim); geçmiş vakit planlanmaz; Sabah dünkü Yatsı'yı sorar, İkindi Öğle'yi sorar; kılınmış vakit için hatırlatma ve soru yok; hatırlatma N dakika sonra; payload gidiş-dönüş.
- Backend testleri metni `_TestTexts` sahtesiyle üretir; backend gerçek metin sistemine bağlı değildir.
- `test/central_system_test.dart`: bildirim metinlerinde emoji yok. `test/architecture_test.dart`: `AppNotificationTexts` adaptörü beklenen Türkçe cümleleri üretir.
- Emülatörde: alarmlar sistemde kayıtlıydı, saat Yatsı'ya alınınca bildirim zamanında ateşlendi, dokununca doğru diyalog açıldı. Front/backend ayrımından sonra da hatırlatma ("Sabah Namazını Kıldınız mı?") adaptör üzerinden zamanında geldi: [[emulator-test-notlari]].

## Bilinen sınırlar

- Bazı Android üreticilerinde agresif pil tasarrufu alarmları geciktirebilir veya engelleyebilir; gerçek cihazda doğrulanmadı: [[bilinen-sorunlar]].
- Bildirimden doğrudan "Kıldım/Kılmadım" düğmesi yok: [[yol-haritasi]].
- Plan yalnızca pencere içindedir; uygulama uzun süre açılmaz ve arka plan görevi çalışmazsa bildirimler biter.

## İlgili sayfalar

[[arka-plan-gorevleri]] · [[izinler]] · [[android-yapilandirma]] · [[namaz-vakitleri]]
