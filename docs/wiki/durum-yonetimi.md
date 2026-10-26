# Durum Yönetimi (Riverpod)

Durum yönetimi `flutter_riverpod` 3.x ile yapılır. Tüm sağlayıcılar `lib/providers/providers.dart` dosyasındadır. Neden Riverpod seçildiği: [[006-riverpod-durum-yonetimi]].

## Altyapı sağlayıcıları

`main.dart` içinde `ProviderScope.overrides` ile değer verilen iki sağlayıcı vardır; override edilmezse `UnimplementedError` atar.

| Sağlayıcı | Ne |
|---|---|
| `settingsRepositoryProvider` | `SettingsRepository` ([[ayarlar-ve-kalicilik]]) |
| `appDatabaseProvider` | Açık `AppDatabase` ([[veri-katmani]]) |
| `prayerRepositoryProvider` | `PrayerRepository` |
| `prayerTimeServiceProvider` | `PrayerTimeService` ([[namaz-vakitleri]]) |
| `locationServiceProvider` | `LocationService` ([[konum]]) |
| `notificationSchedulerProvider` | `NotificationScheduler` ([[bildirimler]]) |

## Ayarlar ve tema

- `settingsProvider` (`SettingsNotifier`): tema, bildirim açık/kapalı, hatırlatma süresi, hesaplama yöntemi, konum modu, elle konum ve **geçerli konum**. Her ayar değişikliğinde bildirimler yeniden planlanır (`_after`).
- `paletteProvider`: seçili temanın `AppPalette`'i ([[tema-sistemi]]).

## Konum

- `locationRefreshProvider` (`FutureProvider`): otomatik modda GPS'ten konumu tazeler ve kaydeder; elle modda elle konumu döner; GPS başarısızsa son konumla devam eder, o da yoksa hatayı iletir. Ana ekran açılışında ve yenilemede okunur. Ayrıntı: [[konum]].

## Takip günü ve vakitler

- `trackingDayProvider` (`TrackingDayNotifier`): takip günü. Saat 04:00'te kendiliğinden değişmez; `sync()` her saniye sayaç tarafından çağrılır ve gün değiştiyse durumu günceller: [[takip-gunu-ve-sayac]].
- `todayTimesProvider`: takip gününün vakitleri.
- `upcomingDaysProvider`: dün, bugün, yarın; sıradaki vakit hesabı için.

## İşaretleme ve kaza

- `todayRecordsProvider` (`TodayRecordsNotifier`, `AsyncNotifier`): bugünün kayıtları. `markPerformed(date, vakit, congregation:)` ve `markMissed(date, vakit)` **tarih alır**; Sabah bildiriminden gelen "dünkü Yatsı" sorusu için. İşaretleme sonrası istatistik sürümünü artırır, kaza listesini geçersiz kılar, bildirimleri yeniden planlar. Bkz. [[namaz-isaretleme]].
- `qazaProvider` (`QazaNotifier`, autoDispose): kaza listesi ve `compensate`. Bkz. [[kaza-sistemi]].

## İstatistik

Hepsi `autoDispose` ve `statsVersionProvider`'ı izler; ekrandan çıkınca atılır, tekrar girince güncel veri okunur.

| Sağlayıcı | Ne |
|---|---|
| `statsVersionProvider` | Sayaç; bir işaretleme olunca artar, bağımlı sağlayıcılar yenilenir |
| `weekComparisonProvider` | Bu hafta / geçen hafta |
| `dailyCountsProvider(n)` | Son n gün için günlük kılınan sayısı |
| `monthCountsProvider(ay)` | Bir ayın günlük sayıları (ısı haritası) |
| `radarProvider(gün)` | Vakit bazında yüzde |
| `gamificationProvider` | Seri ve rozet verisi |

Hesap kuralları: [[istatistikler]], [[seri-ve-rozetler]].

## Desenler

- **Sürüm sayacı ile yenileme:** İstatistik sağlayıcıları veriyi doğrudan dinlemez; `StatsVersion.bump()` ile tetiklenir. Böylece tek bir işaretleme birden çok ekranı tutarlı yeniler.
- **autoDispose + ekran değişimi:** Çekmece ekran değiştirirken eski ekranı yok eder; autoDispose sağlayıcılar böylece her girişte taze okunur.
- **Test:** Sağlayıcılar için ayrı test yok; mantık servis ve repository katmanında test edilir ([[test-stratejisi]]).

## İlgili sayfalar

[[mimari-genel]] · [[006-riverpod-durum-yonetimi]] · [[ui-ekranlar]]
