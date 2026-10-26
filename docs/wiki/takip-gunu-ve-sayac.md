# Takip Günü ve Geri Sayım

Uygulama iki farklı "gün" kavramı kullanır ve sıradaki vakti saate göre hesaplar.

## Takip günü

Kullanıcı gece 00:30'da Yatsı'yı kılarsa bu hâlâ "dünün" namazıdır. Bu yüzden `prayerDay(now, fajrToday:)` (`packages/namaz_backend/lib/src/domain/dates.dart`) gün sınırını **`min(04:00, o günün Sabah vakti)`** olarak alır; sınırdan önce bir önceki günü döner. `kLateNightCutoffHour = 4` üst sınırdır.

Neden Sabah vakti de sınıra giriyor: yazın Sabah 04:00'ten önce girer (İstanbul 21 Haziran 03:24). Eski sabit 04:00 kuralıyla 03:24–04:00 arasında işaretlenen Sabah **dünün** satırına yazılıyordu. Kışın Sabah geç girdiği (06:46) için sınır 04:00 kalır; yani kış davranışı değişmedi. Konum yoksa (`fajrToday` verilmez) yalnızca 04:00 kuralı uygulanır. Gerçek İslami gün akşam ezanıyla başlar; bu kural onun basit bir yaklaşımıdır ([[sozluk]]).

Ön yüz `prayerDay`'i doğrudan çağırmaz; `NamazBackend.trackingDay([now])` Sabah vaktini bilen tek yerdir ([[backend-paketi]]).

- İşaretlemeler takip gününe yazılır: [[namaz-isaretleme]].
- Ana ekranda "BUGÜNÜN NAMAZLARI • tarih" başlığı takip gününü gösterir.
- `TrackingDayNotifier.sync()` günü yeniden hesaplar; değiştiyse durumu günceller ve bağımlı sağlayıcılar (bugünün vakitleri ve kayıtları) yenilenir: [[durum-yonetimi]].

## Sıradaki vakit

`nextPrayer(now, günler)` (saf fonksiyon), verilen günlerin farz vakitleri arasından `now`'dan sonraki **ilk** vakti döner. Günler listesi dün, bugün ve yarındır (`upcomingDaysProvider`, **takvim** günü).

Sonuçları:

- Yatsı'dan sonra sıradaki vakit yarının Sabah'ıdır; sayfa yenilemek gerekmez. Eski uygulamada bu hata vardı.
- Gece yarısından sonra (00:30) sıradaki vakit o takvim gününün Sabah'ıdır.
- Güneş vakti sıradaki vakit sayılmaz; yalnızca farz vakitler.

## Geri sayım kartı

`CountdownCard` her saniye `Timer.periodic` ile `setState` yapar ve her tikte `trackingDayProvider.sync()` çağırır. Sıradaki vakit değişince `onNextChanged` ile ana ekran, "sıradaki" kartını vurgular. Ekran okuyucular için sayaç etiketi `HomeStrings.countdownSemantics` ile verilir.

Doğrulama: emülatörde saat 19:34:30'a alınınca 19:35'te Yatsı bildirimi geldi ve sayaç kendiliğinden "Sıradaki Namaz: Sabah" oldu: [[emulator-test-notlari]].

## Bilinen sınır

`todayTimesProvider` takip gününü, `upcomingDaysProvider` takvim gününü kullanır. Gece 00:00–04:00 arasında takip günü dünkü, takvim günü bugündür. Sıradaki vakit doğru hesaplanır (bugünün Sabah'ı), ama ana ekrandaki "sıradaki" vurgusu yalnızca vakit **türüne** bakar, tarihe bakmaz; bu aralıkta dünün listesindeki Sabah kartı vurgulanır. Canlı doğrulanmadı ve küçük bir tutarsızlıktır: [[bilinen-sorunlar]].

## Test

`packages/namaz_backend/test/domain_test.dart`: `prayerDay` (00:30, 03:59, 04:00, ay başı; Sabah vaktiyle: yazın 03:23/03:24/03:30, kışın 03:59/04:00/05:00, Sabah tam 04:00, yazın gece yarısı, Sabah verilmezse 04:00), `nextPrayer` (öğleden sonra, yatsıdan sonra, gece yarısından sonra).

Emülatör doğrulaması: saat 21 Haziran 03:30'a alınınca ana ekran "21 Haziran 2026" gösterdi ve Sabah işareti veritabanına `2026-06-21|fajr|1` olarak yazıldı: [[emulator-test-notlari]].

## İlgili sayfalar

[[namaz-vakitleri]] · [[namaz-isaretleme]] · [[kaza-sistemi]]
