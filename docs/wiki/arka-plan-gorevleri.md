# Arka Plan Görevleri

Bildirimlerin pencere dışına taşmaması için uygulama kapalıyken de periyodik olarak yeniden planlama yapılır. Kod: `packages/namaz_backend/lib/src/application/background_service.dart`, paket: `workmanager`.

## Nasıl çalışır

- `NamazBackend.create(config)` içinde `BackgroundService.register(entryPoint)` çağrılır: `Workmanager().initialize(entryPoint)` ve ardından `registerPeriodicTask`. Giriş noktasını **ön yüz** verir (`NamazBackendConfig.backgroundEntryPoint`).
- Görev adı `namaz_takip_refresh`, sıklık **12 saat**, ilk gecikme 1 saat, `ExistingPeriodicWorkPolicy.keep` (zaten kayıtlıysa yeniden kaydetmez).
- Giriş noktası ön yüzde `namazBackgroundEntryPoint` (`@pragma('vm:entry-point')`, `lib/main.dart`) adlı üst düzey fonksiyondur; Workmanager bunu ister. İçinde `NamazBackend.handleBackgroundTasks(const AppNotificationTexts())` çağrılır. Backend ayrı izolatta `SharedPreferences` ve veritabanını yeniden açar, `NotificationScheduler.reschedule()` çağırır, veritabanını kapatır. Başarı `true`, hata `false` döner. Metinleri ön yüz verdiği için arka planda da bildirim metni doğru dildedir: [[bildirimler]].
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

## Neden giriş noktası ön yüzde

Workmanager, arka plan işleyicisinin üst düzey ve `vm:entry-point` ile işaretli bir fonksiyon olmasını ister, ve bu izolat uygulamanın bellek durumunu paylaşmaz. Metinler ön yüze ait olduğundan işleyiciyi ön yüz kaydeder; iş (planlama) backend'dedir. Bu, ön yüz ile backend arasındaki tek geri çağrı bağımlılığıdır: [[011-front-backend-ayrimi]].

## İlgili sayfalar

[[bildirimler]] · [[konum]] · [[ios-yapilandirma]] · [[backend-paketi]]
