# Namaz Vakitleri

Vakitler cihazda, internet kullanılmadan hesaplanır. Kod: `lib/services/prayer_time_service.dart`. Karar gerekçesi: [[002-vakitler-cihazda-hesaplanir]].

## Nasıl hesaplanır

`PrayerTimeService.compute(konum, gün, yöntem)` bir `DayTimes` döner (`lib/core/prayer.dart`): fecr, güneş, öğle, ikindi, akşam, yatsı. Altta `adhan_dart` paketinin `PrayerTimes` sınıfı çalışır.

- Paket zamanları **UTC** `DateTime` olarak verir; servis `.toLocal()` ile cihaz saat dilimine çevirir. Bu yüzden vakitler cihazın saat dilimine göre görünür (emülatörde UTC iken vakitler 3 saat kaymış görünmüştü; saat dilimi İstanbul yapılınca doğru oldu: [[emulator-test-notlari]]).
- Yalnızca tarih kısmı kullanılır; `compute` içinde gün `dateOnly` ile sadeleştirilir.
- `precision: false` olduğundan zamanlar dakikaya yuvarlanır.

## Hesaplama yöntemleri

`CalcMethod` enum'ı (`diyanet`, `mwl`, `egyptian`, `karachi`, `ummalqura`, `isna`) ayarlanabilir; varsayılan Diyanet. Görünen adlar `SettingsStrings.calcMethodName` içindedir ([[metin-sistemi]]), seçim `calc_method` anahtarında saklanır ([[ayarlar-ve-kalicilik]]).

Diyanet yöntemi `CalculationMethodParameters.turkiye()` ile uygulanır: fecr 18°, yatsı 17°; güneş −7, öğle +5, ikindi +4, akşam +7 dakika düzeltmesi. Paket bunu "Diyanet yönteminin bir yaklaşımı" olarak tanımlar ve Türkiye dışında daha az doğru olduğunu belirtir.

## Doğruluk kontrolü (2026-10-26)

Yerel hesap, eski uygulamanın kullandığı Aladhan API'sinin Diyanet yöntemiyle (method 13) karşılaştırıldı. Saatler `HH:mm`, İstanbul UTC+3.

| Yer / Tarih | Hesap | Aladhan 13 | Fark |
|---|---|---|---|
| İstanbul 26 Eki | 05:55 07:21 12:53 15:46 18:15 19:35 | 05:55 07:21 12:53 15:47 18:15 19:35 | İkindi 1 dk |
| İstanbul 21 Haz | 03:24 05:25 13:11 17:11 20:47 22:38 | aynı | 0 |
| İstanbul 21 Ara | 06:46 08:18 13:07 15:25 17:46 19:13 | aynı | 0 |
| Ankara 26 Eki | 05:40 07:04 12:38 15:32 18:01 19:19 | 05:40 07:04 12:38 15:34 18:01 19:20 | İkindi 2 dk, yatsı 1 dk |
| Ankara 21 Haz | 03:17 05:13 12:55 16:53 20:28 22:15 | aynı | 0 |
| Ankara 21 Ara | 06:29 08:00 12:52 15:13 17:34 18:59 | 06:29 07:59 12:52 15:13 17:34 18:59 | Güneş 1 dk |

En büyük fark 2 dakikadır ve genelde ikindide görülür. **Resmî Diyanet takvimiyle birebir karşılaştırma yapılmadı**; Diyanet kendi tablolarında ilçe bazlı değerler yayımlar. Emülatörde İstanbul için uygulama 05:55 / 07:21 / 12:53 / 15:46 / 18:15 gösterdi.

## Yüksek enlemler

Türkiye için gerekli değildir; paket `HighLatitudeRule` sunar ancak uygulama bunu ayarlamaz. Kutba yakın konumlarda vakit hesabı doğrulanmamıştır.

## Test

`test/core_test.dart`: İstanbul için vakitlerin sıralı ve makul olduğu (haziran, UTC dönüşümü) doğrulanır. Doğruluk karşılaştırması elle yapıldı ve bu sayfadadır; otomatik testte API çağrısı yoktur.

## İlgili sayfalar

[[takip-gunu-ve-sayac]] · [[konum]] · [[bildirimler]] · [[gecis-gecmisi]]
