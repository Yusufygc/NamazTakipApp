# Backend Paketi (`namaz_backend`)

`packages/namaz_backend/` ayrı bir Dart/Flutter paketidir. Uygulamanın arayüz dışındaki her şeyini içerir: vakit hesabı, veritabanı, ayarlar, konum, bildirim, arka plan görevi, kaza ve istatistik kuralları. Genel resim: [[mimari-genel]]. Karar: [[011-front-backend-ayrimi]].

Paket, kök `pubspec.yaml`'daki `workspace:` bölümüyle uygulamaya bağlanır; tek `flutter pub get` ve tek `pubspec.lock` kullanılır. Ön yüz bağımlılığı `namaz_backend:` satırıdır (yol yazılmaz, workspace çözer).

## Herkese açık yüz

Ön yüz yalnızca `package:namaz_backend/namaz_backend.dart` dosyasını içe aktarır. Bu dosya şunları dışa açar:

| Grup | Öğeler |
|---|---|
| Arayüz | `NamazBackend`, `NamazBackendConfig` |
| Port | `NotificationTexts` (bildirim metinleri) |
| Modeller | `PrayerType`, `PrayerStatus`, `DayTimes`, `NextPrayer`, `PrayerRecord`, `QazaItem`, `DayCount`, `WeekComparison`, `GamificationData`, `AppSettings`, `AppLocation`, `CalcMethod`, `LocationMode`, `LocationFailure`, `LocationException`, `PrayerPrompt`, `StreakStats`, `Achievement`, `AchievementId` |
| Saf yardımcılar | `prayerDay(now, {fajrToday})`, `nextPrayer`, `dateOnly`, `dateKey`, `parseDateKey`, `addDays`, `daysBetween`, `daysDiff`, `computeStreaks`, `buildAchievements` |

`PrayerTimeService`, repository'ler, veritabanı, bildirim servisi, konum servisi **açılmaz**.

## `NamazBackend` arayüzü

| Alan | Üyeler |
|---|---|
| Kurulum | `NamazBackend.create(config)`, `NamazBackend.handleBackgroundTasks(texts)` |
| Ayarlar | `settings`, `setTheme`, `setNotificationsEnabled`, `setReminderMinutes`, `setCalcMethod`, `useManualLocation`, `useAutoLocation`, `cities` |
| Konum ve vakit | `refreshLocation()`, `timesFor(day)`, `trackingDay([now])` (gün sınırı `min(04:00, Sabah)`) |
| Takip | `recordsForDate`, `markPerformed`, `markMissed` (ikisi de bildirimleri yeniden planlar) |
| Kaza | `qazaItems()`, `compensate(item)` |
| İstatistik | `trackingStart`, `weekComparison()`, `dailyCounts(n)`, `monthCounts(ay)`, `radar(gün)`, `gamification()` |
| Bildirim | `notificationPrompts`, `takeLaunchPrompt()`, `requestNotificationPermission()`, `rescheduleNotifications()`, `notificationHealth()` (`NotificationHealth.exactAlarmsAllowed`), `openExactAlarmSettings()` |

Arayüz yöntemleri düz Dart modelleri döner; SQL, eklenti sınıfı veya `Stream` dışında reaktif nesne sızmaz. Ön yüz bu arayüzün sahte (fake) bir uygulamasıyla test edilebilir.

## Kurulum ayarı (`NamazBackendConfig`)

| Alan | Ne |
|---|---|
| `notificationTexts` | `NotificationTexts` uygulaması; ön yüzde `AppNotificationTexts` ([[metin-sistemi]]) |
| `backgroundEntryPoint` | `@pragma('vm:entry-point')` ile işaretli üst düzey fonksiyon; ön yüzde `namazBackgroundEntryPoint` ([[arka-plan-gorevleri]]) |

## Katman kuralları

`lib/src/` içinde izin verilen bağımlılıklar:

```
domain      →  (yalnızca adhan_dart)
data        →  domain
platform    →  domain
application →  domain, data, platform
```

Ek kurallar: `domain/` Flutter paketi içe aktarmaz; backend hiçbir yerde `material`/`widgets`/Riverpod/`fl_chart` kullanmaz; `lib/` altında yalnızca `namaz_backend.dart` bulunur. Bunların hepsi `packages/namaz_backend/test/architecture_test.dart` tarafından denetlenir: [[test-stratejisi]].

## Port: bildirim metinleri

Bildirimin **hangi** vakit için gerektiği backend'in, **ne yazacağı** ön yüzün kararıdır. `buildNotificationPlan` metni kendisi üretmez; `NotificationTexts` portunu çağırır:

```dart
abstract interface class NotificationTexts {
  String get channelName;  String get channelDescription;
  String adhanTitle(PrayerType prayer);
  String adhanBody(PrayerType prayer);
  String adhanAskBody(PrayerType prayer, PrayerType asked);
  String reminderTitle(PrayerType prayer);  String get reminderBody;
}
```

Backend testleri portu basit bir sahte ile doldurur (`_TestTexts`), böylece backend metin sistemine bağlı kalmaz: [[bildirimler]].

## Backend'e özellik eklemek

1. Kuralı `domain/` içinde saf fonksiyon olarak yaz ve `packages/namaz_backend/test/` altında test et.
2. Veri gerekiyorsa `data/` içinde repository sorgusu ekle (SQL yalnızca burada).
3. `NamazBackend` arayüzüne yöntemi ekle, `application/namaz_backend_impl.dart` içinde uygula.
4. Yeni model ön yüzün görmesi gerekiyorsa `lib/namaz_backend.dart` barrel'ına ekle.
5. Ön yüzde sağlayıcı ve ekran ekle: ekranlar `backendProvider`'ı değil sağlayıcıları kullanır ([[durum-yonetimi]]).
6. `flutter analyze` ve iki paketin `flutter test`'i geçmeli; bu sayfa ve [[log]] güncellenir.

## Test

Backend testleri paketin kendi klasöründe çalışır: `cd packages/namaz_backend && flutter test`. 51 test: tarih/seri/vakit/gün sınırı mantığı, bellek içi SQLite repository'si, bildirim planı, planlayıcı kuyruğu (sahte `NotificationGateway`), saat dilimi anı, mimari kuralları: [[test-stratejisi]].

## İlgili sayfalar

[[mimari-genel]] · [[011-front-backend-ayrimi]] · [[durum-yonetimi]] · [[bagimliliklar]]
