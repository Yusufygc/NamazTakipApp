# Kıble Pusulası

Ana ekran üst çubuğundaki **Kıble** düğmesi pusula sayfasını açar (`lib/ui/widgets/qibla_compass_sheet.dart`). Açı ve mesafe backend'de saf fonksiyonla hesaplanır: `computeQibla(AppLocation)` (`domain/qibla_calculator.dart`).

## Hesap

- Kâbe: 21,422487° K, 39,826206° D.
- Açı: büyük daire başlangıç yönü (initial bearing), kuzeyden saat yönünde 0-360°.
- Mesafe: haversine, R = 6371 km.
- Doğrulama (elle ve testle): İstanbul 151,6° ve 2.405 km, Ankara 160,2° ve 2.162 km, Sakarya 154,7° ve 2.327 km. Emülatörde Sakarya için 155° ve 2.326 km görüldü.

## Konum yokken

Eskiden konum bilinmiyorsa sayfa sessizce **151° ve 2.400 km** (İstanbul değeri) gösteriyordu; başka şehirdeki kullanıcıya yanlış yön verirdi. Artık konum yoksa kadran ve metrikler gösterilmez, yerine "Konum belirlenmediği için Kıble yönü hesaplanamıyor..." açıklaması çıkar. `test/qibla_sheet_test.dart` bunu ve farklı şehirlerde farklı açı gösterildiğini denetler (eski davranışla düştüğü elle doğrulandı).

## Cihaz yönü

- Android: `TYPE_ROTATION_VECTOR` sensörü, `EventChannel com.namaztakip.app/compass` (`MainActivity.kt`). iOS: `CLHeading` (`AppDelegate.swift`, derlenmedi).
- **Manyetik sapma düzeltmesi (Android, 2026-10-27):** Sensör **manyetik** kuzeye göre yön verir; Kıble açısı **gerçek** kuzeye göredir. Fark manyetik sapmadır (Türkiye'de yaklaşık 5-7° doğuya). Dart dinlemeyi başlatırken geçerli konumu kanala verir (`NamazBackend.compassHeading`, konum yoksa sapma 0); Kotlin `GeomagneticField(lat, lon, 0, şimdi).declination` ile sapmayı bulup `CompassMath.trueHeading` ile ekler. Emülatörde Sakarya için sapma 6,4° bulundu (logcat etiketi `Pusula`). Eskiden sapma hiç eklenmiyordu ve ±5° hizalama toleransının tamamı bu hataya gidiyordu.
- **Sensör yoksa açık hata:** Eskiden akış sessiz kalıyordu. Artık Android ve iOS `NO_SENSOR` hatası döndürür; `compassHeadingProvider` hata durumuna geçer ve sayfa "Bu cihazda pusula sensörü yok..." uyarısı gösterip kadranı parmakla çevirmeye bırakır.
- Hizalanma toleransı ±5°; cihaz düz tutulmalıdır.
- **Sınırlar** ([[bilinen-sorunlar]]): iOS tarafında `trueHeading` kullanılır ama konum güncellemesi açık değilse sistem negatif döndürür ve kod manyetik açıya düşer; derlenmediği için doğrulanmadı. Pusula gerçek cihazda denenmedi: emülatör sanal sensörü sabit yön verir, yalnızca sapma değeri ve hata yolunun akışı denendi.

## Testler

- `test/qibla_sheet_test.dart` (6): konum yokken sahte değer yok, açı ve mesafe, şehre göre değişim, **sensör hatasında uyarı**, sensör açısıyla hizalanma, uzak açıda hizalı denmemesi.
- `CompassMathTest` (Kotlin, 5): sapma ekleme, çıkarma, 0-360 sarma, negatif açı.
- Sapmanın kendisini veren `GeomagneticField` Android sınıfıdır, birim testte çağrılmaz; emülatörde değeri görüldü.

## İlgili sayfalar

[[konum]] · [[ui-ekranlar]] · [[hicri-takvim]] · [[test-stratejisi]]
