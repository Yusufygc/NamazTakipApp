# Proje Özeti

Namaz Takip, günlük namazları takip eden ve kaza namazlarını otomatik listeleyen bir mobil uygulamadır. Flutter ile yazılmıştır ve hem Android hem iOS hedefler. Uygulama henüz yayınlanmamıştır; gerçek kullanıcı verisi yoktur.

## Kısaca

| | |
|---|---|
| Ad | Namaz Takip |
| Paket adı (Dart) | `namaz_takip` |
| Uygulama kimliği (Android) | `com.namaztakip.app` |
| Sürüm | 1.0.0+1 |
| Çatı | Flutter 3.47 (Dart 3.13), Material 3 |
| Yapı | İki paket: ön yüz (`namaz_takip`) ve backend (`packages/namaz_backend`), tek arayüzle bağlı: [[mimari-genel]], [[backend-paketi]] |
| Durum yönetimi | Riverpod 3 (ön yüz), bkz. [[durum-yonetimi]] |
| Depolama | SQLite (`sqflite`) + `shared_preferences`, bkz. [[veri-katmani]], [[ayarlar-ve-kalicilik]] |
| Vakit hesabı | Cihazda, `adhan_dart` ile, bkz. [[namaz-vakitleri]] |
| Geliştirici | MYY |

## Ne yapar

- Konuma göre beş vakit ve güneş vaktini gösterir, sıradaki vakte geri sayar: [[namaz-vakitleri]], [[takip-gunu-ve-sayac]].
- Her vakti "kıldım (tek başına / cemaatle)" veya "kılmadım" diye işaretletir: [[namaz-isaretleme]].
- İşaretlenmeyen geçmiş günleri kaza listesine kendiliğinden düşürür: [[kaza-sistemi]].
- Ezan vaktinde önceki namazı sorar, ezandan sonra hatırlatır: [[bildirimler]].
- Performans radarı, ısı haritası, haftalık/aylık karşılaştırma sunar: [[istatistikler]].
- Seri ve rozetlerle motivasyon sağlar: [[seri-ve-rozetler]].
- Beş tema, elle şehir seçimi, hesaplama yöntemi ve hatırlatma süresi ayarı: [[tema-sistemi]], [[konum]], [[ui-ekranlar]].

## Durum (2026-10-26)

- Kod yazıldı, `flutter analyze` temiz, 78 test geçiyor (ön yüz 27, backend 51): [[test-stratejisi]].
- Android emülatörde (Android 36) elle doğrulandı: [[emulator-test-notlari]].
- Gerçek telefonda, iOS'ta ve dört ek temada görsel test yapılmadı: [[bilinen-sorunlar]], [[yol-haritasi]].
- Eski React Native/Expo sürümü silindi, Flutter projesi depo köküne taşındı: [[gecis-gecmisi]], [[001-flutter-gecisi]].

## Depo düzeni

Git kökü ile Flutter kökü aynı klasördür.

```
lib/                 ön yüz: ekranlar, sağlayıcılar, tema, ikon, metin (bkz. mimari-genel)
packages/namaz_backend/  backend: vakit, veri, konum, bildirim, istatistik (bkz. backend-paketi)
test/                ön yüz testleri (bkz. test-stratejisi)
android/, ios/       platform projeleri, bkz. [[android-yapilandirma]], [[ios-yapilandirma]]
assets/icon/         ikon kaynakları, bkz. [[uygulama-ikonu]]
docs/wiki/           bu bilgi tabanı
docs/raw/            ham kaynaklar (şu an boş)
CLAUDE.md            wiki anayasası ve proje kuralları
```

## İlgili sayfalar

[[index]] · [[urun-gereksinimleri]] · [[mimari-genel]] · [[gelistirme-ortami]] · [[sozluk]]
