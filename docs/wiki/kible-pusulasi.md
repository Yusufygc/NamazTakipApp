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
- Sensör yoksa akış sessiz kalır; sayfa kadranı parmakla çevirmeye izin verir.
- **Sınırlar** ([[bilinen-sorunlar]]): sensör **manyetik** kuzeyi verir ve manyetik sapma düzeltilmez (Türkiye'de yaklaşık 5°); hizalanma toleransı ±5°. Cihaz düz tutulmalıdır. Pusula gerçek cihazda denenmedi, yalnızca açı hesabı ve sayfa emülatörde görüldü.

## İlgili sayfalar

[[konum]] · [[ui-ekranlar]] · [[hicri-takvim]] · [[test-stratejisi]]
