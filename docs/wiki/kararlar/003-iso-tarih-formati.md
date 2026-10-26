# 003 — Tarihler `yyyy-MM-dd` saklanır

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Eski uygulama tarihleri `dd-MM-yyyy` metni olarak saklıyordu (Aladhan API'nin biçimi). Metin olarak sıralanınca günler önce gelir: `ORDER BY date DESC` ve `date < ?` karşılaştırmaları yanlış sonuç verir, `BETWEEN` çalışmaz. Eski seri hesabı bu yüzden kırılgandı; ısı haritası `LIKE '%-MM-yyyy'` ile çalışıyordu.

## Karar

Tüm tarihler ISO sırasıyla `yyyy-MM-dd` saklanır. Gün farkı hesapları `daysDiff` ile UTC tarih üzerinden yapılır (yaz/kış saati etkisiz).

## Sonuçlar

- `ORDER BY`, `BETWEEN`, `<` doğru çalışır: [[veri-katmani]].
- Seri ve kaza hesapları basitleşti: [[seri-ve-rozetler]], [[kaza-sistemi]].
- Uygulama yayınlanmadığı için eski biçimden veri taşıma gerekmedi.
- Yeni kod tarih biçimini elle üretmemeli; `dateKey`/`parseDateKey` kullanılmalı.

## İlgili sayfalar

[[kararlar]] · [[veri-katmani]] · [[001-flutter-gecisi]]
