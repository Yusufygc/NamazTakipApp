# Namaz Takip

Günlük namazları takip eden, kaza namazlarını otomatik listeleyen Flutter uygulaması (Android ve iOS).

## Özellikler

- Konuma göre namaz vakitleri, cihazda hesaplanır (`adhan_dart`, varsayılan Diyanet yöntemi). İnternet gerekmez.
- Vakte dokunarak kıldım (tek başına / cemaatle) veya kılmadım işaretleme.
- İşaretlenmeyen geçmiş günler kaza listesine otomatik düşer; vakit vakit kaza edilebilir.
- Ezan vaktinde "önceki namazı kıldın mı?" bildirimi ve ezandan sonra hatırlatma.
- Süreç: performans radarı, aylık ısı haritası, haftalık/aylık karşılaştırma.
- Seri ve rozetler.
- 5 tema, elle şehir seçimi (81 il), hesaplama yöntemi ve hatırlatma süresi ayarı.

## Çalıştırma

Flutter SDK 3.47 veya üzeri gerekir.

```bash
flutter pub get
flutter run
```

Test ve analiz:

```bash
flutter analyze
flutter test
```

Debug APK:

```bash
flutter build apk --debug
```

## Proje yapısı

```
lib/
  core/        saf mantık: tarih, seri, rozet, tema, vakit modelleri
  data/        SQLite (sqflite), repository'ler, il listesi
  services/    vakit hesabı, konum, bildirim, arka plan görevi
  providers/   Riverpod durum yönetimi
  ui/          ekranlar ve widget'lar
test/          birim testleri
assets/icon/   uygulama ikonu kaynakları
```

## Notlar

- Tarihler veritabanında `yyyy-MM-dd` olarak saklanır.
- Bildirim kimlikleri `yyyymmdd*10 + vakit*2 + tür` ile sabit üretilir; yeniden planlama çift bildirim oluşturmaz.
- iOS en fazla 64 bekleyen bildirim tuttuğu için iOS'ta 6 günlük pencere planlanır.
- Launcher ikonları `assets/icon/` kaynaklarından üretilir: `dart run flutter_launcher_icons`.
  Üretim sonrası `ios/Runner.xcodeproj/project.pbxproj` içindeki `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`
  değerinin `YES` kaldığını kontrol edin (araç bunu `AppIcon` yapabiliyor).
- iOS yapılandırması yazıldı ancak henüz bir Mac üzerinde derlenmedi.
