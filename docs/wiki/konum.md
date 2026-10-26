# Konum

Vakit hesabı koordinat ister. Konum iki şekilde belirlenir: GPS (otomatik) veya elle il seçimi. Kod: `packages/namaz_backend/lib/src/platform/location_service.dart`, `packages/namaz_backend/lib/src/data/turkish_cities.dart`, `NamazBackend.refreshLocation()`. Ön yüzde `locationRefreshProvider` bunu çağırır: [[backend-paketi]].

## Modlar

| Mod | Davranış |
|---|---|
| Otomatik (`auto`) | Açılışta ve yenilemede GPS'ten konum alınır, `last_location` olarak saklanır |
| Elle (`manual`) | Kullanıcı 81 ilden birini seçer; GPS kullanılmaz |

Ayarlar ekranında iki seçenek bir radyo grubudur; elle seçeneği şehir seçici ekranını açar. Seçim `location_mode` ve `manual_location` anahtarlarına yazılır: [[ayarlar-ve-kalicilik]]. "Hesapta kullanılan konum" `settings.location` (`effectiveLocation`) ile belirlenir.

## GPS yedek zinciri

`LocationService.current()` sırayla dener ([[009-konum-yedek-zinciri]]):

1. İzin ve servis kontrolü (`ensurePermission`): servis kapalı, izin reddedildi veya kalıcı reddedildi ise ilgili `LocationFailure` ile hata verir: [[izinler]].
2. `LocationAccuracy.medium`, 10 saniye: pil dostu, ağ/şehir düzeyi konum.
3. Olmazsa `LocationAccuracy.high`, 25 saniye: GPS.
4. Olmazsa `getLastKnownPosition()`.
5. Hiçbiri yoksa `LocationFailure.unavailable`.

Şehir adı `Geocoding().placemarkFromCoordinates` ile bulunur: önce `administrativeArea` (il), sonra `subAdministrativeArea`, sonra `locality`. Ad bulunamazsa koordinatlar yazılır. Ülke adı `country` alanındandır.

## Hata durumları ve ana ekran

`NamazBackend.refreshLocation()` hata verirse ve daha önce kaydedilmiş bir konum varsa onunla devam eder; yoksa hatayı iletir. Ana ekran bu durumda bir kart gösterir: mesaj (`LocationStrings`), "Tekrar dene" ve "Şehir seç" düğmeleri. Konum yokken vakit ve sayaç gösterilmez: [[ui-ekranlar]].

## Elle şehir

81 il merkezi yaklaşık koordinatlarla `kTurkishCities` içindedir. Arama Türkçe harf ve büyük/küçük farkını yok sayar (`foldTurkish`): "istanbul", "Şanlıurfa", "igdir" eşleşir: [[metin-sistemi]]. Bir test koordinatların Türkiye sınırları içinde ve 81 adet olduğunu doğrular.

## Arka planda konum

Arka plan görevi GPS kullanmaz; son kayıtlı konumu kullanır. Böylece arka plan konum izni gerekmez: [[arka-plan-gorevleri]].

## Emülatörde test (önemli)

- Emülatör PC'nin konumunu **kullanmaz**; kendi sanal GPS'i vardır. Konum `adb emu geo fix <boylam> <enlem>` ile verilir: [[gelistirme-ortami]].
- Emülatörde ağ konumu yoktur; `medium` zaman aşımına uğrar ve `high` (GPS) yedeği devreye girer. `geo fix` yalnızca GPS sağlayıcısını besler. Bu yüzden yedek zinciri emülatörde de çalışır: [[emulator-test-notlari]].
- Gerçek telefonda ağ konumu çoğu zaman `medium` adımında sonuç verir.

## İlgili sayfalar

[[namaz-vakitleri]] · [[izinler]] · [[arka-plan-gorevleri]] · [[009-konum-yedek-zinciri]]
