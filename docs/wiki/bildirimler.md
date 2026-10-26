# Bildirimler

Uygulama yerel (cihazda zamanlanan) bildirim kullanır; sunucu veya push yoktur. İki katman vardır: kararı veren saf **plan** ve eklentiye dokunan ince **uygulayıcı**.

| Dosya | Rol |
|---|---|
| `lib/services/notification_plan.dart` | `buildNotificationPlan`, `notificationId`, `PrayerPrompt`: saf mantık |
| `lib/services/notification_scheduler.dart` | Ayar, konum ve işaretleme durumundan planı kurup uygular |
| `lib/services/notification_service.dart` | `flutter_local_notifications` çağrıları, izinler, dokunma olayları |
| `lib/core/strings/notification_strings.dart` | Metinler: [[metin-sistemi]] |

## İki tür bildirim

Her vakit için en çok iki bildirim üretilir.

1. **Ezan bildirimi** (vakit girince): "Selamünaleyküm! *X* ezanı okundu. *Önceki vakit* namazını kıldın mı?". Sorulan vakit, girilen vaktin bir öncekidir; Sabah ezanında sorulan **dünkü Yatsı**'dır. Önceki vakit zaten kılındıysa (veya kaza edildiyse) yalnızca "X vakti girdi." denir ve soru taşınmaz.
2. **Hatırlatma** (ezandan `reminder_minutes` sonra, varsayılan 15): "X Namazını Kıldınız mı? / Namazınızı işaretlemek için dokunun." Vakit zaten işaretliyse hiç üretilmez.

Bildirim başlık ve metinlerinde emoji yoktur; sistem uygulama ikonunu gösterir: [[ikon-sistemi]].

## Kimlikler

`notificationId = yyyymmdd × 10 + vakit × 2 + (hatırlatma ? 1 : 0)`; örnek: 26 Ekim 2026 Yatsı ezanı = `202610268`. Aynı vakit için her zaman aynı kimlik üretilir; bu yüzden yeniden planlama bildirimi çoğaltmaz, üzerine yazar. Eski uygulamadaki "hatırlatma aynı anda iki kez geliyor" hatasının yapısal çözümüdür: [[004-sabit-bildirim-kimlikleri]]. Değerler 32 bit işaretli sınırın altında kalır (testle doğrulanır).

## Planlama penceresi

Bugünden başlayarak `planningDays` gün planlanır: **Android 10, iOS 6**. iOS en fazla 64 bekleyen bildirim tutar; 6 gün × en çok 10 bildirim = 60: [[ios-yapilandirma]]. Geçmişteki zamanlar için bildirim üretilmez.

## Uygulama (`NotificationService.apply`)

1. Plan dışında kalan bekleyen bildirimler iptal edilir (örn. artık işaretlenmiş vaktin hatırlatması).
2. Her planlanan bildirim `zonedSchedule` ile eklenir; zaman `tz.local` saat diliminde `TZDateTime`'dır.
3. Android'de tam zamanlı alarm izni varsa `exactAllowWhileIdle`, yoksa `inexactAllowWhileIdle` kullanılır.
4. Kanal: `prayer_times`, ad "Namaz Vakitleri", önem derecesi yüksek.

Bildirimler kapalıysa (`notifications_enabled = false`) tüm bekleyenler iptal edilir ve plan kurulmaz.

## Ne zaman yeniden planlanır

`NotificationScheduler.reschedule()` şu durumlarda çağrılır:

- Bir vakit işaretlenince ([[namaz-isaretleme]]).
- Bildirim, hatırlatma süresi, hesaplama yöntemi veya konum ayarı değişince ([[durum-yonetimi]]).
- Açılışta izinler istendikten sonra ([[izinler]]).
- Arka plan görevinde, 12 saatte bir ([[arka-plan-gorevleri]]).

Zamanlama ayarlardaki konumla yapılır; konum yoksa hiçbir şey planlanmaz.

## Dokunma

Bildirime dokununca payload `ask|yyyy-MM-dd|vakit` çözülür (`PrayerPrompt.decode`) ve ana ekran o tarih ve vakit için diyaloğu açar: [[namaz-isaretleme]]. Uygulama kapalıyken bildirimle başlatılırsa `launchPrompt` ilk karede işlenir. Bozuk payload sessizce yok sayılır.

## Test

- `test/notification_plan_test.dart`: kimlikler benzersiz ve kararlı; aynı kimlik iki kez yok (20 bildirim); geçmiş vakit planlanmaz; Sabah dünkü Yatsı'yı sorar, İkindi Öğle'yi sorar; kılınmış vakit için hatırlatma ve soru yok; hatırlatma N dakika sonra; payload gidiş-dönüş.
- `test/central_system_test.dart`: bildirim metinlerinde emoji yok.
- Emülatörde: 286 alarm satırı sistemde görüldü, saat Yatsı'ya alınınca bildirim zamanında ateşlendi, dokununca doğru diyalog açıldı: [[emulator-test-notlari]].

## Bilinen sınırlar

- Bazı Android üreticilerinde agresif pil tasarrufu alarmları geciktirebilir veya engelleyebilir; gerçek cihazda doğrulanmadı: [[bilinen-sorunlar]].
- Bildirimden doğrudan "Kıldım/Kılmadım" düğmesi yok: [[yol-haritasi]].
- Plan yalnızca pencere içindedir; uygulama uzun süre açılmaz ve arka plan görevi çalışmazsa bildirimler biter.

## İlgili sayfalar

[[arka-plan-gorevleri]] · [[izinler]] · [[android-yapilandirma]] · [[namaz-vakitleri]]
