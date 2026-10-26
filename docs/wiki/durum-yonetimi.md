# Durum Yönetimi (Riverpod)

Durum yönetimi ön yüzde `flutter_riverpod` 3.x ile yapılır. Tüm sağlayıcılar `lib/providers/providers.dart` dosyasındadır. Neden Riverpod: [[006-riverpod-durum-yonetimi]].

**İlke:** Sağlayıcılar iş kuralı içermez; backend'in `NamazBackend` arayüzünü Riverpod'a çeviren ince bir katmandır. Kural, hesap ve depolama [[backend-paketi]]'ndedir. (Önceki sürümde istatistik hesapları ve ayar yönetimi sağlayıcılardaydı; [[011-front-backend-ayrimi]] ile backend'e taşındı.)

## Altyapı

| Sağlayıcı | Ne |
|---|---|
| `backendProvider` | `NamazBackend`; `main.dart` içinde `overrideWithValue` ile verilir, aksi halde `UnimplementedError` atar |

Ekranlar `backendProvider`'ı yalnızca bir olay anında (izin isteme, bildirim akışı, şehir listesi, takip başlangıcı) doğrudan okur; mimari test bu kullanımı sınırlar (en çok 8 yer). Diğer her şey sağlayıcılardan gelir.

## Ayarlar ve tema

- `settingsProvider` (`SettingsNotifier`): `NamazBackend.settings` görüntüsünü (`AppSettings`) tutar. Her ayar yönteminden sonra `reload()` ile backend'den yeniden okur. Bildirimleri yeniden planlamak backend'in işidir.
- `paletteProvider`: seçili temanın `AppPalette`'i ([[tema-sistemi]]).

## Konum

- `citiesProvider`: `backend.cities` (Türkiye'nin 81 ili; `CityPickerScreen` doğrudan `backendProvider`'a dokunmadan bu sağlayıcıyı izler).
- `locationRefreshProvider` (`FutureProvider`): `backend.refreshLocation()` çağırır, sonra `settingsProvider.reload()` yapar (backend yeni GPS konumunu kaydetmiş olabilir). Elle mod, GPS, son konum yedeği ve hata davranışı backend'dedir: [[konum]].

## Bildirim ve veritabanı sağlığı

- `notificationHealthProvider` (`FutureProvider.autoDispose`): `backend.notificationHealth()`; ana ekrana dönülünce ve ayar ekranından dönülünce yenilenir. `NotificationHealthCard` bunu izler; "izin yok → var" geçişinde bir kez `rescheduleNotifications()` çağırır.
- `corruptedDbBackupProvider` (`CorruptedDbNoticeNotifier`): `backend.corruptedDatabaseBackup` değerini tutar; `CorruptedDatabaseCard` üzerinden kullanıcı "Anladım" dediğinde `dismiss()` ile `backend.dismissCorruptedDatabaseNotice()` çağrılır ve uyarı kapanır: [[veri-katmani]].

## Takip günü ve vakitler

- `trackingStartProvider`: `backend.trackingStart` (ısı haritası başlangıç sınırı için).
- `trackingDayProvider` (`TrackingDayNotifier`): takip günü; `backend.trackingDay()` değerini tutar (Sabah vaktini backend bilir). `sync()` her saniye sayaç tarafından çağrılır; gün değiştiyse durumu günceller: [[takip-gunu-ve-sayac]].
- `todayTimesProvider`: `backend.timesFor(takipGünü)`; `settingsProvider`'ı izler, ayar veya konum değişince yeniden hesaplanır.
- `upcomingDaysProvider`: dün, bugün, yarın; sıradaki vakit hesabı için.

## İşaretleme ve kaza

- `todayRecordsProvider` (`TodayRecordsNotifier`, `AsyncNotifier`): bugünün kayıtları. `markPerformed(date, vakit, congregation:)` ve `markMissed(date, vakit)` backend'i çağırır ve **tarih alır** (Sabah bildiriminden gelen "dünkü Yatsı" sorusu için). Sonrasında kayıtları yeniler, `StatsVersion`'ı artırır, kaza listesini geçersiz kılar. Bildirim planlamayı backend yapar. Bkz. [[namaz-isaretleme]].
- `qazaProvider` (`QazaNotifier`, autoDispose): `backend.qazaItems()`; `compensate(item)`. Bkz. [[kaza-sistemi]].

## İstatistik

Hepsi `autoDispose`'dur, `statsVersionProvider`'ı izler ve yalnızca backend'e delege eder:

| Sağlayıcı | Backend çağrısı |
|---|---|
| `weekComparisonProvider` | `weekComparison()` |
| `dailyCountsProvider(n)` | `dailyCounts(n)` |
| `monthCountsProvider(ay)` | `monthCounts(ay)` |
| `radarProvider(gün)` | `radar(gün)` |
| `gamificationProvider` | `gamification()` |
| `statsVersionProvider` | Backend değil; işaretleme olunca artan sayaç |

Hesap kuralları: [[istatistikler]], [[seri-ve-rozetler]].

## Desenler

- **Sürüm sayacı ile yenileme:** İstatistik sağlayıcıları veriyi doğrudan dinlemez; `StatsVersion.bump()` ile tetiklenir. Tek bir işaretleme birden çok ekranı tutarlı yeniler.
- **autoDispose + ekran değişimi:** Çekmece ekran değiştirirken eski ekranı yok eder; autoDispose sağlayıcılar her girişte taze veri okur.
- **Test:** Sağlayıcıların kendi testi yoktur; mantık backend'de testlenir. Ön yüz testleri `NamazBackend`'in sahte uygulamasıyla yazılabilir: [[test-stratejisi]].

## İlgili sayfalar

[[mimari-genel]] · [[backend-paketi]] · [[006-riverpod-durum-yonetimi]] · [[ui-ekranlar]]
