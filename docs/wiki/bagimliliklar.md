# Bağımlılıklar

`pubspec.yaml` içindeki paketler ve neden kullanıldıkları. Sürümler 2026-10-26 itibarıyla `pubspec.lock`'tadır.

## Hangi pakette

Bağımlılıklar iki pakete bölünmüştür ([[011-front-backend-ayrimi]]). Ön yüzün `pubspec.yaml`'ında yalnızca arayüz paketleri bulunur; test bunu denetler: [[test-stratejisi]].

| Paket | Bağımlılıkları |
|---|---|
| Ön yüz (`namaz_takip`, kök `pubspec.yaml`) | `flutter_riverpod`, `fl_chart`, `cupertino_icons` (kullanılmıyor), `namaz_backend`; geliştirme: `flutter_test`, `flutter_lints`, `flutter_launcher_icons` |
| Backend (`packages/namaz_backend/pubspec.yaml`) | `adhan_dart`, `sqflite`, `path`, `shared_preferences`, `geolocator`, `geocoding`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `workmanager`; geliştirme: `flutter_test`, `flutter_lints`, `sqflite_common_ffi` |

`intl` paketi kaldırıldı: tarih anahtarı ve saat biçimi elle üretiliyor (`dateKey`, `formatTime`).

## Çalışma zamanı

| Paket | Sürüm | Ne için | Sayfa |
|---|---|---|---|
| `flutter_riverpod` | ^3.4.3 | Durum yönetimi | [[durum-yonetimi]] |
| `sqflite` | ^2.4.5 | SQLite | [[veri-katmani]] |
| `path` | ^1.9.1 | Veritabanı yolu | [[veri-katmani]] |
| `shared_preferences` | ^2.5.6 | Ayarlar | [[ayarlar-ve-kalicilik]] |
| `flutter_secure_storage` | ^11.2.0 | Gemini API anahtarı için Keystore/Keychain deposu (yalnızca backend `secret_store.dart`) | [[zikir-paylasim]], [[ayarlar-ve-kalicilik]] |
| `adhan_dart` | ^2.0.1 | Cihazda vakit hesabı (Diyanet ve diğer yöntemler) | [[namaz-vakitleri]] |
| `geolocator` | ^14.1.2 | GPS konumu, izin akışı | [[konum]] |
| `geocoding` | ^5.0.0 | Koordinattan şehir adı | [[konum]] |
| `flutter_local_notifications` | ^22.3.3 | Zamanlanmış yerel bildirim | [[bildirimler]] |
| `timezone` | ^0.11.2 | Bildirim zamanları için saat dilimi | [[bildirimler]] |
| `flutter_timezone` | ^5.1.1 | Cihazın saat dilimi kimliği | [[bildirimler]] |
| `workmanager` | ^0.10.10 | Arka planda periyodik görev | [[arka-plan-gorevleri]] |
| `fl_chart` | ^1.3.0 | Radar, çubuk ve çizgi grafikleri | [[istatistikler]] |
| `cupertino_icons` | ^1.0.8 | Şablondan gelen; kullanılmıyor | |

## Geliştirme

| Paket | Ne için |
|---|---|
| `flutter_test` | Test çatısı: [[test-stratejisi]] |
| `flutter_lints` | Statik analiz kuralları |
| `sqflite_common_ffi` | Backend: masaüstünde bellek içi SQLite ile repository testleri |
| `flutter_launcher_icons` | Launcher ikonlarını üretir: [[uygulama-ikonu]] |

## Kararlar ve uyarılar

- **`permission_handler` kaldırıldı.** Kodda hiç kullanılmıyordu (konum izni `geolocator`, bildirim izni `flutter_local_notifications` ile alınır) ve Android 37 SDK'sı isteyerek ilk derlemeyi bozdu: [[emulator-test-notlari]].
- **`workmanager_android` Kotlin uyarısı:** Paket eski Kotlin Gradle eklentisini uyguluyor. Derleme uyarı verir, hata vermez; Flutter ileride hataya çevirebilir. Paket güncellemesi izlenmeli: [[yol-haritasi]], [[android-yapilandirma]].
- **Eklenti API'leri sürüm sürüm değişir.** `flutter_local_notifications` 22.x isimli parametreler kullanır (`initialize(settings:)`, `zonedSchedule(id:...)`, `cancel(id:)`); `geocoding` 5.x sınıf tabanlıdır (`Geocoding().placemarkFromCoordinates`); Riverpod 3 `Notifier` tabanlıdır. Sürüm yükseltirken değişiklik günlüğü okunmalıdır.
- **Tedarik zinciri:** Android SDK araçlarının ve Android Studio'nun doğrulaması [[gelistirme-ortami]] sayfasındadır. pub.dev paketlerinin kaynak kodu satır satır incelenmedi.

## Yeni paket ekleme kuralı

1. Gerçekten gerekli mi? Mevcut paket veya birkaç satır kod yeterliyse eklenmez.
2. `flutter pub add` ile eklenir, derleme ve test çalıştırılır.
3. Bu sayfa ve [[log]] güncellenir.

## İlgili sayfalar

[[mimari-genel]] · [[android-yapilandirma]] · [[ios-yapilandirma]]
