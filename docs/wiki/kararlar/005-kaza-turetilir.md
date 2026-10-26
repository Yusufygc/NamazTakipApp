# 005 — Kaza listesi türetilir

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Eski uygulama iki tablo tutuyordu: `prayers` (gün gün vakitler) ve `qaza_prayers` (kaza kayıtları). Kaza ekranı iki kaynağı birleştirip tekilleştiriyordu; "kılmadım" denince kaza satırı ekleniyor, kullanıcının işaretlemeyi unuttuğu günler ise yalnızca `prayers` içinde `is_performed = 0` satırı varsa yakalanıyordu. Aynı vakit birden çok kez kazaya yazılabiliyordu. Kaza edilen vakit `prayers` içinde kılınmış sayılıyordu.

## Karar

Kaza ayrı tabloda tutulmaz. Tek `prayers` tablosunda bir durum alanı vardır (bekliyor, kılındı, kılmadım, kaza edildi); liste, takip başlangıcından bugüne her gün × beş vakitten **türetilir**: kılınmamış ve kaza edilmemiş her vakit kazadır (bugün için yalnızca "kılmadım" denenler).

## Sonuçlar

- Çift kayıt imkânsızdır (`UNIQUE(date, prayer)`): [[veri-katmani]].
- İşaretlemeyi unutulan günler kendiliğinden listede görünür, satır oluşturmak gerekmez: [[kaza-sistemi]].
- Kaza edilen vakit ayrı durumdur ve istatistiğe girmez; eski şişirme düzeldi.
- Takip başlangıcından önceki kazalar sistemde yoktur; ileride ayrı "birikmiş kaza" özelliği olarak eklenmelidir: [[yol-haritasi]].
- Liste her açılışta hesaplanır; çok uzun geçmişte maliyeti artar (sınır yok, günde 5 satır).

## İlgili sayfalar

[[kararlar]] · [[kaza-sistemi]] · [[veri-katmani]]
