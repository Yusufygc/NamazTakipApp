# Takip Günü ve Geri Sayım

Uygulama iki farklı "gün" kavramı kullanır ve sıradaki vakti saate göre hesaplar.

## Takip günü

Kullanıcı gece 00:30'da Yatsı'yı kılarsa bu hâlâ "dünün" namazıdır. Bu yüzden `prayerDay(now)` (`packages/namaz_backend/lib/src/domain/dates.dart`) saat **04:00'ten önce bir önceki günü** döner. Eşik `kLateNightCutoffHour = 4`'tür; sabah ezanı genelde 04:30'dan sonra olduğu için güvenli kabul edilir. Gerçek İslami gün akşam ezanıyla başlar; bu kural onun basit bir yaklaşımıdır ([[sozluk]]).

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

`packages/namaz_backend/test/domain_test.dart`: `prayerDay` (00:30, 03:59, 04:00, ay başı), `nextPrayer` (öğleden sonra, yatsıdan sonra, gece yarısından sonra).

## İlgili sayfalar

[[namaz-vakitleri]] · [[namaz-isaretleme]] · [[kaza-sistemi]]
