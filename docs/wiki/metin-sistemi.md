# Metin Sistemi

Kullanıcıya görünen tüm metinler `lib/core/strings/` altında, modül başına bir dosyada tutulur. Karar gerekçesi: [[008-merkezi-ikon-ve-metin]].

## Kural

- Ekranlara, widget'lara, bildirimlere sabit Türkçe metin yazılmaz; ilgili modülden çağrılır.
- Ekranlar yalnızca `core/strings/strings.dart` dosyasını içe aktarır; bu dosya tüm modülleri dışa açar.
- Parametreli metinler `static String` fonksiyondur (`QazaStrings.summary(3, 2)`), sabitler `static const`'tır.
- Her modül `abstract final class`'tır; örneklenmez.

`test/central_system_test.dart` kuralı denetler: `lib/ui/` içinde Türkçe harf içeren tek tırnaklı sabit metin bulunursa test düşer: [[test-stratejisi]].

## Modüller

| Dosya | Sınıf | Kapsam |
|---|---|---|
| `common_strings.dart` | `CommonStrings` | Uygulama adı, sürüm, geliştirici, İptal/Vazgeç/Tekrar dene, `error(e)`, ayarlar altbilgisi |
| `date_strings.dart` | `DateStrings` | Ay ve kısa gün adları, `long`, `monthAndYear`, `short` biçimleri |
| `prayer_strings.dart` | `PrayerStrings` + `PrayerTypeLabel` | Vakit adları; `PrayerType.label` uzantısı |
| `nav_strings.dart` | `NavStrings` | Çekmece ve ekran başlıkları |
| `home_strings.dart` | `HomeStrings` | Ana ekran, sayaç, ekran okuyucu etiketleri |
| `location_strings.dart` | `LocationStrings` | Konum hataları, şehir seçici |
| `prayer_dialog_strings.dart` | `PrayerDialogStrings` | "X NAMAZINI / KILDINIZ MI?" diyaloğu |
| `qaza_strings.dart` | `QazaStrings` | Kaza ekranı |
| `stats_strings.dart` | `StatsStrings` | Süreç: sekmeler, ısı haritası, karşılaştırma |
| `gamification_strings.dart` | `GamificationStrings` | Seri ve rozet başlık/açıklamaları |
| `settings_strings.dart` | `SettingsStrings` + `CalcMethodLabel` | Ayarlar, tema adları, hesaplama yöntemi adları |
| `about_strings.dart` | `AboutStrings` | Hakkında |
| `notification_strings.dart` | `NotificationStrings` | Kanal adı ve bildirim metinleri |
| `startup_strings.dart` | `StartupStrings` | Başlatma hata ekranı ve bozuk veritabanı kurtarma uyarısı |
| `notification_health_strings.dart` | `NotificationHealthStrings` | Tam zamanlı alarm izni uyarısı |
| `notification_texts_adapter.dart` | `AppNotificationTexts` | Backend'in `NotificationTexts` portunu bu metinlerle doldurur: [[bildirimler]] |
| `home_widget_texts_adapter.dart` | `AppHomeWidgetTexts` | Backend'in `HomeWidgetTexts` portunu doldurur (vakit adları, başlık, rozetler): [[ana-ekran-widget]] |

Metin sistemi **ön yüze** aittir; backend metin içermez, bildirim metinlerini port üzerinden alır ([[backend-paketi]]). Enum'lar backend'dedir (`PrayerType`, `CalcMethod`, `AchievementId`); etiket uzantıları ön yüzdedir. Enum'ların görünen adı enum içinde değil, strings modülündedir: `PrayerType.label` (`prayer_strings.dart`), `CalcMethod.label` (`settings_strings.dart`). Böylece çekirdek model dile bağımlı olmaz.

## Türkçe yardımcılar (`lib/core/format/text_utils.dart`)

| Fonksiyon | Neden |
|---|---|
| `turkishUpper` | Dart `toUpperCase()` `i`'yi `I`'ya çevirir; "İkindi" → "İKINDI" olur. Bu fonksiyon `i → İ`, `ı → I` yapar: "İKİNDİ". Diyalog başlığı kullanır |
| `foldTurkish` | Arama için Türkçe harfleri ve büyük/küçük farkını yok sayar; şehir seçici kullanır |

## Yeni metin ekleme

1. Metin ilgili modüle eklenir; yoksa yeni modül açılıp `strings.dart`'a `export` edilir.
2. Ekranda `Modul.metin` kullanılır.
3. Test geçmeli. Wiki'de metin listesi çoğaltılmaz; yalnızca bu sayfadaki modül tablosu güncellenir.

## Çok dillilik

Şu an yalnızca Türkçe vardır. Modüller ileride Flutter'ın ARB tabanlı çeviri sistemine taşınabilecek biçimdedir (anahtarlar anlamsal, parametreler fonksiyon). Geçiş yapılmadı: [[yol-haritasi]].

## Bilinen sınır

Sürüm numarası (`CommonStrings.version`) `pubspec.yaml`'dan okunmaz, elle yazılıdır; sürüm artırılırken ikisi birlikte güncellenmelidir: [[bilinen-sorunlar]].

## Zikir içeriği (`lib/core/content/`)

Esmaül Hüsna kataloğu, yaygın zikirler, klasik tesbihat adımları, ilk kurulum başlıkları, varsayılan taslak metinleri ve yapay zeka istemi `lib/core/content/dhikr_catalog.dart` içindedir (`kAppDhikrContent`). `main.dart` bunu `NamazBackendConfig.dhikrContent` ile backend'e verir; backend katalogu bilmez, yalnızca `DhikrCatalogEntry` türünü ve `DhikrContent` sözleşmesini tanır. Neden ön yüzde: içerik yerelleştirilebilir metindir (başka dile geçişte yalnızca ön yüz değişir). Dinî onay durumu: [[dini-icerik-onayi]].

### Backend'de kalan Türkçe sabitler (izin listesi)

Backend koruma testi bunlar dışında Türkçe metin sabitini reddeder; her biri gerekçelidir ve dosya artık Türkçe içermezse test listeden çıkarmayı ister:

| Dosya | Neden |
|---|---|
| `data/turkish_cities.dart` | İl adları veridir (özel isim) |
| `domain/dhikr_extractor.dart` | Türkçe girdiyi ayrıştıran anahtar sözcükler ("defa", "sabah namazı"); çıktıya metin koymaz |
| `domain/dhikr.dart` | `DhikrGroups`: veritabanında saklanan kalıcı grup değerleri; taşımak mevcut kullanıcı kayıtları için veri göçü gerektirir |

## İlgili sayfalar

[[ikon-sistemi]] · [[ui-ekranlar]] · [[bildirimler]]
