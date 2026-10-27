# Hicri Takvim ve Özel Günler

Ana ekrandaki kartta Hicri tarih, bayram/kandil rozeti ve kerahat uyarısı gösterilir. Hepsi saf Dart'tır: `packages/namaz_backend/lib/src/domain/islamic_calendar.dart` ve `hijri_month_starts.dart`. Arayüz: [[ui-ekranlar]].

## Hicri tarih nasıl bulunur

`HijriDate.fromGregorian(date)` iki kaynak kullanır:

1. **Diyanet ay başı tablosu** (`kHijriMonthStarts`): 1447 Muharrem (26 Haziran 2025) ile 1448 Zilhicce (7 Mayıs 2027) arasındaki 24 ayın ilk günü. Tarih bu aralıktaysa tablodan okunur.
2. **Kuveyt tablo algoritması:** tablo dışındaki tarihler için.

### Neden tablo?

Kuveyt algoritması Diyanet takvimiyle her ay aynı yönde sapmıyor. 2026-27 için Diyanet'e dayanan yayınlarla karşılaştırıldı (9 tarih): algoritma 3'ünü doğru, 6'sını yanlış verdi. Ramazan Bayramı'nı (1 Şevval) 19 Mart'a, Kurban Bayramı'nı (10 Zilhicce) 26 Mayıs'a, Ramazan 1448 başını 7 Şubat 2027'ye düşürüyordu; Diyanet günleri 20 Mart, 27 Mayıs ve 8 Şubat'tır. Algoritmayı tek yönde kaydırmak da çözmedi: bir gün geriye kaydırınca 2026 tarihleri doğru, 1448'in Recep-Şaban tarihleri yanlış oldu. Bu yüzden ay başları doğrudan tablodan okunur.

### Tablonun kaynağı ve sınırı

- Ay başları Diyanet takvimine dayanan yayınlardan derlendi (bayramlar, Hicri yılbaşı, üç aylar ve Ramazan başı haber ve Diyanet duyurularıyla örtüşüyor). **Resmî Diyanet tablosu değildir.** Tüm ay uzunlukları 29 veya 30 gündür ve testle denetlenir.
- **Tablo 7 Mayıs 2027'de biter.** Sonrası algoritmaya düşer ve bayram/kandil günleri bir gün kayabilir. Yeni yıl (1449) Diyanet ilan edince `hijri_month_starts.dart` içine eklenmelidir: [[bilinen-sorunlar]].
- Diyanet ilanından önce yazılan tarihler değişebilir (ay başı hilal/hesap kararıyla kesinleşir).

## Özel günler

`detectSpecialDay(date, hijri)` kurallar: Hicri yılbaşı (1 Muharrem), Aşure (10 Muharrem), Mevlid Kandili (11 Rebiülevvel, gecesi 12'sine bağlanır), Regaip, Miraç Kandili (26 Recep), Berat Kandili (14 Şaban), Ramazan başı, Kadir Gecesi (26 Ramazan), Ramazan Bayramı (1-3 Şevval), Arefe (9 Zilhicce), Kurban Bayramı (10-13 Zilhicce), Cuma.

Kandil geceleri bir sonraki Hicri günün arifesi olduğu için kuralda bir gün öncesi yazılır (Miraç: 27 Recep gecesi = 26 Recep günü). Tarihler Diyanet 2025-2027 kandilleriyle test edilir (`hijri_test.dart`).

**Regaip Kandili:** Recep'in ilk Cuma'sından önceki Perşembe gecesi. Eski kural "Recep 1-7 arası Perşembe"ydi; Recep'in 1'i Cuma ise gerçek Regaip önceki ayın son günüdür ve eski kural onu kaçırıyordu, ayrıca ikinci Perşembe'yi (7. gün) yanlış işaretliyordu. Yeni kural ertesi günün Hicri tarihine bakar.

## Kerahat vakitleri

`detectKerahat(times, now)`: güneş doğuşundan 45 dk, öğle ezanından önceki 30 dk, akşam ezanından önceki 40 dk. Süreler **koda yazıldığı gibidir; dinî kaynakla doğrulanmadı**, kaynaklar birbirini tutmuyor, karar kullanıcıya ait: [[dini-icerik-onayi]], [[bilinen-sorunlar]].

## Hicri günün başlangıcı

Kart, takip gününün Hicri tarihini gösterir; gün gece yarısı veya Sabah sınırında değişir. Hicri günün akşam ezanıyla başladığı geleneği uygulanmaz.

## Testler

`packages/namaz_backend/test/hijri_test.dart` (18 test): Diyanet bayram, Ramazan, üç aylar tarihleri; tablo kapsamında her günün bir öncekinden tam bir gün ileride olması; ay uzunlukları; kandil ve bayramların Diyanet gününe düşmesi; her Recep'te Regaip'in tam bir kez ve ilk Cuma öncesi Perşembe'ye gelmesi. Sayılar: [[test-stratejisi]].

## İlgili sayfalar

[[ui-ekranlar]] · [[namaz-vakitleri]] · [[bilinen-sorunlar]] · [[test-stratejisi]]
