# Mimari (Genel Bakış)

Uygulama beş katmandan oluşur. Bağımlılık yönü tek yönlüdür: üst katman alttakini kullanır, tersi olmaz.

```
ui  →  providers  →  services / data  →  core
```

| Katman | Klasör | Sorumluluk | Flutter'a bağımlılığı |
|---|---|---|---|
| core | `lib/core/` | Saf mantık ve sabitler: tarih, seri, rozet, tema, vakit modelleri, metin ve ikon sistemi | Yok (ikon ve tema hariç) |
| data | `lib/data/` | SQLite şeması, repository'ler, ayar deposu, il listesi | Yalnızca depolama paketleri |
| services | `lib/services/` | Vakit hesabı, konum, bildirim planı ve uygulaması, arka plan görevi | Eklenti çağrıları |
| providers | `lib/providers/` | Riverpod durum yönetimi; servisleri ve veriyi arayüze bağlar | Riverpod |
| ui | `lib/ui/` | Ekranlar ve widget'lar | Evet |

Ayrıca `lib/main.dart` başlangıç sırasını yürütür.

## Neden böyle

- Mantık (seri, kaza türetme, sonraki vakit, bildirim planı) saf fonksiyonlardır; cihaz veya eklenti olmadan birim testle doğrulanır: [[test-stratejisi]].
- Eklentiye dokunan kod ince tutulur (`NotificationService`, `LocationService`), böylece karar veren kod ([[bildirimler]] için `buildNotificationPlan`) test edilebilir kalır.
- Aynı servis kodu hem ön planda hem arka plan izolatında çalışır: [[arka-plan-gorevleri]].

## Başlangıç sırası (`main.dart`)

1. `SharedPreferences` açılır, `SettingsRepository` kurulur.
2. Takip başlangıç günü kaydedilir (`ensureInstallDate`): [[ayarlar-ve-kalicilik]].
3. Veritabanı açılır: [[veri-katmani]].
4. `NotificationService.init()` (saat dilimi + eklenti başlatma). İzinler burada **istenmez**.
5. Arka plan görevi kaydedilir; hata olursa uygulama durmaz.
6. `ProviderScope` ayar deposu ve veritabanı override'larıyla `runApp` çağırır.
7. İlk ekran çizildikten sonra `HomeScreen` izinleri sırayla ister: [[izinler]].

## Örnek veri akışı: bir vakti işaretlemek

1. Kullanıcı vakit kartına dokunur → `HomeScreen` diyalog açar ([[namaz-isaretleme]]).
2. Sonuç `TodayRecordsNotifier.markPerformed/markMissed` ile `PrayerRepository`'ye yazılır ([[veri-katmani]]).
3. Bugünün kayıtları yeniden okunur; `StatsVersion` artırılır, böylece istatistik sağlayıcıları yenilenir ([[durum-yonetimi]]).
4. Kaza listesi geçersiz kılınır ([[kaza-sistemi]]).
5. `NotificationScheduler.reschedule()` çalışır; işaretlenen vakit için hatırlatma iptal olur ([[bildirimler]]).

## Hangi sayfaya bakmalı

| Konu | Sayfa |
|---|---|
| Veritabanı, tarih formatı | [[veri-katmani]] |
| Ayarlar, kalıcı küçük durum | [[ayarlar-ve-kalicilik]] |
| Sağlayıcılar | [[durum-yonetimi]] |
| Vakit hesabı | [[namaz-vakitleri]] |
| Gün sınırı, sayaç | [[takip-gunu-ve-sayac]] |
| Konum | [[konum]] |
| Bildirim ve izin | [[bildirimler]], [[izinler]] |
| Ekranlar ve tema | [[ui-ekranlar]], [[tema-sistemi]] |
| İkon ve metin kuralları | [[ikon-sistemi]], [[metin-sistemi]] |
| Paketler | [[bagimliliklar]] |
| Platform ayarları | [[android-yapilandirma]], [[ios-yapilandirma]] |

## İlgili sayfalar

[[proje-ozeti]] · [[durum-yonetimi]] · [[006-riverpod-durum-yonetimi]]
