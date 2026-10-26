# Kaza Sistemi

Kaza listesi **türetilir**, ayrı bir tabloda tutulmaz. Neden: [[005-kaza-turetilir]]. Kod: `PrayerRepository.qazaItems`, `QazaNotifier`, `lib/ui/screens/qaza_screen.dart`.

## Algoritma

`qazaItems(firstDay, today)`:

1. `firstDay` ile `today` arasındaki kayıtlar okunur. `firstDay` = takip başlangıcı (`install_date`), `today` = takip günü: [[ayarlar-ve-kalicilik]], [[takip-gunu-ve-sayac]].
2. Aralıktaki **her gün × beş vakit** için durum bulunur; kayıt yoksa `pending` sayılır.
3. Kılınmış (1) veya kaza edilmiş (3) olanlar atlanır.
4. Takip günü için yalnızca kullanıcının "kılmadım" (2) dediği vakitler listeye girer; bugünün bekleyen vakitleri henüz kaza değildir.
5. Önceki günler için hem "kılmadım" (2) hem işaretlenmemiş (`pending`) vakitler kaza olur.
6. Sonuç yeniden eskiye, aynı gün içinde vakit sırasına dizilir.

Sonuç: kullanıcı işaretlemeyi unutsa bile geçen günler kazaya düşer; bir gün tamamen kılınmışsa listeden çıkar. İşaretlemeyi unutma durumunu kurtarmak ve geçmişe dönük düzeltme yapabilmek eski isteklerdendi: [[urun-gereksinimleri]].

## Etiketler

| Durum | Alt başlık |
|---|---|
| `pending` | "Otomatik tespit" |
| `missed` | "Kılınmadı olarak işaretlendi" |

## Kaza etmek

"Kaza Et" → onay ("X tarihli Y namazını kaza ettiniz mi?") → `markCompensated(date, vakit)` ile durum 3 olur ve listeden çıkar. Kaza edilen vakit "zamanında kılındı" sayılmaz; seri, ısı haritası ve radara girmez: [[veri-katmani]], [[istatistikler]]. (Eski uygulama kaza edileni kılınmış sayıyordu ve istatistiği şişiriyordu.)

## Arayüz

Gün kartları genişletilebilir (`ExpansionTile`): başlıkta tarih ve "N Kaza" rozeti, içinde vakit satırları ve "Kaza Et" düğmesi. Üstte "Toplam N kaza namazı • M gün" özeti. Liste boşsa "Kaza namazınız yok" mesajı gösterilir. Metinler `QazaStrings` modülündedir: [[metin-sistemi]].

## Sınırlar

- Takip başlangıcından **önceki** kazalar (eskiden borç olan namazlar) sistemde yoktur. Bunları girip günlük hedefle bitiş hesaplama fikri [[yol-haritasi]] sayfasındadır.
- Liste uzun olabilir (uzun süre işaretlenmezse her gün 5 satır); sayfalama yoktur.

## Test

`packages/namaz_backend/test/prayer_repository_test.dart`: bugünün bekleyen vakti kaza değildir; işaretlenmeyen geçmiş günler otomatik kazadır (2 gün × 5 = 10); 5/5 kılınan gün listeden çıkar; kaza edilen vakit çıkar; aynı vakit tekrar işaretlenince tek kayıt kalır.

## İlgili sayfalar

[[namaz-isaretleme]] · [[veri-katmani]] · [[ui-ekranlar]] · [[sozluk]]
