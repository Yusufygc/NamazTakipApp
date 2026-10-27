# Ayarlar ve Küçük Kalıcı Durum

Ayarlar ve küçük durumlar `shared_preferences` ile saklanır; kod `packages/namaz_backend/lib/src/data/settings_repository.dart`. Büyük ve ilişkisel veri SQLite'tadır: [[veri-katmani]]. Depo backend'dedir; ön yüz ayarları `NamazBackend.settings` (`AppSettings`) ile görür, `settingsProvider` bu görüntüyü tutar: [[durum-yonetimi]], [[backend-paketi]]. `theme` anahtarı backend için anlamsız bir metindir; yalnızca kalıcılığı sağlar.

> **Gizli değerler:** Gemini API anahtarı `SharedPreferences`'ta tutulmaz; `flutter_secure_storage` (Keystore/Keychain) kullanılır. `SettingsRepository.loadSecrets()` açılışta bir kez belleğe alır ve eski düz kopyayı taşıyıp siler. Ayrıntı: [[zikir-paylasim]].

## Anahtarlar

Android'de bu anahtarlar `FlutterSharedPreferences` dosyasında `flutter.` önekiyle görünür.

| Anahtar | Tür | Varsayılan | Ne |
|---|---|---|---|
| `theme` | String | `default` | Seçili tema: [[tema-sistemi]] |
| `notifications_enabled` | bool | `true` | Bildirimler açık mı: [[bildirimler]] |
| `reminder_minutes` | int | 15 | Ezandan kaç dakika sonra hatırlatma |
| `calc_method` | String | `diyanet` | Hesaplama yöntemi anahtarı: [[namaz-vakitleri]] |
| `location_mode` | String | `auto` | `auto` veya `manual`: [[konum]] |
| `manual_location` | JSON | yok | Elle seçilen il: `{lat, lon, city, country}` |
| `last_location` | JSON | yok | Son başarılı GPS konumu |
| `install_date` | String | ilk açılış | Takip başlangıç günü (`yyyy-MM-dd`) |
| `corrupted_db_backup` | String | yok | Bozuk veritabanı sıfırlandığında alınan yedeğin yolu; kullanıcı uyarıyı onaylayınca silinir: [[veri-katmani]] |

## Önemli noktalar

- **`install_date`**: `NamazBackend.create` ilk açılışta takip gününü yazar (`ensureInstallDate`); sonra değişmez. Kaza listesi bu günden başlar ([[kaza-sistemi]]) ve radar yüzdesi bu günden önceki günleri paydaya katmaz ([[istatistikler]]).
- **`last_location`**: GPS her başarılı olduğunda yazılır. Arka plan görevi GPS kullanmadığı için bu konumla çalışır: [[arka-plan-gorevleri]].
- **`effectiveLocation`**: Hesapta kullanılan konum. Elle modda ve elle konum varsa o; aksi halde `last_location`. Hiçbiri yoksa `null` ve ana ekran konum isteme kartını gösterir.
- Konum nesnesi `AppLocation`'dır (`packages/namaz_backend/lib/src/domain/prayer_time_service.dart`), `toJson`/`fromJson` ile saklanır; bozuk JSON sessizce yok sayılır.

## Neden veritabanında değil

Bunlar tek değerli, ilişkisiz ve sık okunan ayarlardır; ayrıca arka plan izolatında hızlı açılmaları gerekir. Eski uygulama `app_settings` tablosunu kullanıyordu; gereksiz karmaşıklık olduğu için bırakıldı: [[gecis-gecmisi]].

## İlgili sayfalar

[[veri-katmani]] · [[mimari-genel]] · [[durum-yonetimi]]
