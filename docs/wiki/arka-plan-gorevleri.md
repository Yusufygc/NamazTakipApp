# Arka Plan Görevleri

Bildirimlerin pencere dışına taşmaması için uygulama kapalıyken de periyodik olarak yeniden planlama yapılır. Kod: `lib/services/background_service.dart`, paket: `workmanager`.

## Nasıl çalışır

- `BackgroundService.register()` `main.dart` içinde çağrılır: `Workmanager().initialize(backgroundDispatcher)` ve ardından `registerPeriodicTask`.
- Görev adı `namaz_takip_refresh`, sıklık **12 saat**, ilk gecikme 1 saat, `ExistingPeriodicWorkPolicy.keep` (zaten kayıtlıysa yeniden kaydetmez).
- `backgroundDispatcher` (`@pragma('vm:entry-point')`) ayrı bir izolatta çalışır: `SharedPreferences` ve veritabanını yeniden açar, `NotificationScheduler.reschedule()` çağırır, veritabanını kapatır. Başarı `true`, hata `false` döner.
- Görev **GPS kullanmaz**; son kayıtlı konumu kullanır. Arka plan konum izni gerekmez: [[konum]].
- Kayıt başarısız olursa (örn. desteklenmeyen platform) uygulama durmaz; hata günlüğe yazılır.

## Platform farkları

| | Android | iOS |
|---|---|---|
| Alt sistem | WorkManager | BGTaskScheduler |
| Sıklık | En az 15 dk; 12 saat istenir | `frequency` kullanılmaz; `initialDelay` ipucudur, sistem karar verir |
| Kimlik | Benzersiz ad | `namaz_takip_refresh`, `Info.plist` içindeki `BGTaskSchedulerPermittedIdentifiers` ile **aynı** olmalı |
| Ek kurulum | Yok | `UIBackgroundModes: fetch, processing`; `AppDelegate` kodu gerekmez |

iOS arka plan çalışmasında Android'den daha kısıtlıdır; bildirimlerin sürmesi uygulamanın düzenli açılmasına da bağlıdır: [[ios-yapilandirma]].

## Neden gerekli

Android'de 10, iOS'ta 6 günlük pencere vardır ([[bildirimler]]). Kullanıcı uygulamayı açmasa bile görev pencereyi kaydırır ve işaretleme durumuna göre bildirim içeriğini tazeler.

## Doğrulama durumu

Kayıt koduna ve `flutter analyze`'a kadar doğrulandı. Görevin gerçekten tetiklendiği **gözlenmedi** (12 saatlik periyot emülatör oturumuna sığmadı): [[bilinen-sorunlar]], [[yol-haritasi]]. Test edilecek yol: `adb shell cmd jobscheduler` ile işi zorla çalıştırmak veya `Workmanager().registerOneOffTask` ile kısa süreli deneme.

## Uyarı

`workmanager_android` eski Kotlin Gradle eklentisini uyguluyor; derleme uyarı verir: [[bagimliliklar]], [[android-yapilandirma]].

## İlgili sayfalar

[[bildirimler]] · [[konum]] · [[ios-yapilandirma]]
