# Ekranlar

Gezinme yan menü (çekmece) iledir. Kod: `lib/ui/`.

## Kabuk (`app_shell.dart`)

`AppShell` tek bir `Scaffold` ve Material 3 `NavigationDrawer` kullanır. Seçili ekran `selectedDestinationProvider` ile tutulur; gövde, seçili hedefin `builder`'ı ile değiştirilir. Çekmece ekran değiştirirken eski ekranı yok eder; autoDispose sağlayıcılar bu sayede her girişte taze veri okur: [[durum-yonetimi]]. Çekmece başlığında uygulama adı ve `AppIcons.app`; hedef adları `NavStrings`, ikonları `AppIcons.nav*` kaynaklıdır: [[metin-sistemi]], [[ikon-sistemi]].

| # | Ekran | Dosya | Ana sağlayıcılar |
|---|---|---|---|
| 0 | Namaz Takip (ana) | `screens/home_screen.dart` | `settingsProvider`, `locationRefreshProvider`, `todayTimesProvider`, `todayRecordsProvider`, `trackingDayProvider` |
| 1 | Rozetler & Seri | `screens/gamification_screen.dart` | `gamificationProvider` |
| 2 | Kaza Namazları | `screens/qaza_screen.dart` | `qazaProvider` |
| 3 | Süreç | `screens/stats_screen.dart` | `radarProvider`, `monthCountsProvider`, `weekComparisonProvider`, `dailyCountsProvider` |
| 4 | Ayarlar | `screens/settings_screen.dart` | `settingsProvider` |
| 5 | Hakkında | `screens/about_screen.dart` | — |
| — | Şehir Seç (ek ekran) | `screens/city_picker_screen.dart` | `settingsProvider` |

## Ana ekran

Yukarıdan aşağıya: konum etiketi (yenilemek için aşağı çekilir), [[takip-gunu-ve-sayac]] geri sayım kartı, "BUGÜNÜN NAMAZLARI • tarih" başlığı, vakit kartları (Sabah, Güneş, Öğle, İkindi, Akşam, Yatsı). Konum yoksa kartların yerine konum isteme kartı çıkar: [[konum]]. Bir karta dokunmak işaretleme diyaloğunu açar: [[namaz-isaretleme]]. Bildirimden gelen sorular da bu ekranda açılır: [[bildirimler]]. Uygulama ön plana dönünce takip günü, konum ve kayıtlar tazelenir (`didChangeAppLifecycleState`).

Widget'lar: `PrayerCard` (kart), `CountdownCard` (sayaç), `showPrayerDialog` (diyalog) → `lib/ui/widgets/`.

## Rozetler & Seri

Üç özet kutusu ve beş rozet kartı: [[seri-ve-rozetler]].

## Kaza Namazları

Gün kartları, genişleyince vakit satırları ve "Kaza Et": [[kaza-sistemi]].

## Süreç

Üç sekme: Performans (radar), Isı Haritası, Karşılaştırma: [[istatistikler]].

## Ayarlar

Bölümler: Bildirimler (anahtar, hatırlatma süresi), Konum ve Vakitler (otomatik/elle radyo, kullanılan konum, hesaplama yöntemi), Tema (beş tema kartı), altbilgi (sürüm ve geliştirici). Ayar anahtarları: [[ayarlar-ve-kalicilik]], tema: [[tema-sistemi]].

## Hakkında

Uygulama ikonu, sürüm, özellik listesi (ikonlu), iki ipucu, geliştirici ve dua satırı. Hepsi `AboutStrings`/`CommonStrings` kaynaklıdır.

## Şehir Seç

Arama kutulu 81 il listesi; seçilen il işaretli gelir, seçince ayar kaydedilir ve ekran kapanır: [[konum]].

## Ortak kurallar

- Renkler `context.palette` ile alınır, sabit renk yazılmaz (istisna: ısı haritası ve durum renkleri): [[tema-sistemi]].
- Metin ve ikon merkezi sistemlerden gelir; test bunu zorlar: [[metin-sistemi]], [[ikon-sistemi]].
- Ekran okuyucu etiketleri ve kontrast kararları: [[erisilebilirlik-ve-kontrast]].

## İlgili sayfalar

[[mimari-genel]] · [[durum-yonetimi]] · [[proje-ozeti]]
