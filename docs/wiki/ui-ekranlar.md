# Ekranlar

Gezinme alt gezinme çubuğu (`NavigationBar`) iledir. Kod: `lib/ui/`.

## Kabuk (`app_shell.dart`)

`AppShell` tek bir `Scaffold` ve Material 3 `NavigationBar` (alt çubuk) kullanır. Seçili ekran `selectedDestinationProvider` ile tutulur; gövde, seçili hedefin `builder`'ı ile değiştirilir. Ekran değiştirirken eski ekran yok edilir; autoDispose sağlayıcılar bu sayede her girişte taze veri okur: [[durum-yonetimi]]. Üst barda (`AppBar`) 8 köşeli Selçuklu madalyonu (`SeljukMedallion`) içinde `AppIcons.app`, ekran başlığı, ana ekrandayken tıklanabilir şehir kapsülü (`ActionChip`) ve sağ üstte `AboutScreen`'i açan bilgi düğmesi (`AppIcons.navAbout`) yer alır. Kaza sekmesi, bekleyen kaza namazı varsa sayısını rozet (`Badge`) olarak gösterir.

| # | Sekme (`tab*`) | Ekran Başlığı | Dosya | Ana sağlayıcılar |
|---|---|---|---|---|
| 0 | Vakitler | Namaz Takip | `screens/home_screen.dart` | `settingsProvider`, `locationRefreshProvider`, `todayTimesProvider`, `todayRecordsProvider`, `trackingDayProvider` |
| 1 | Kaza | Kaza Namazları | `screens/qaza_screen.dart` | `qazaProvider` |
| 2 | Süreç | Süreç | `screens/stats_screen.dart` (`widgets/stats_heatmap_tab.dart`, `widgets/stats_comparison_tab.dart`) | `radarProvider`, `monthCountsProvider`, `weekComparisonProvider`, `dailyCountsProvider` |
| 3 | Rozetler | Rozetler & Seri | `screens/gamification_screen.dart` | `gamificationProvider` |
| 4 | Ayarlar | Ayarlar | `screens/settings_screen.dart` | `settingsProvider` |
| — | (Üst bar) | Hakkında | `screens/about_screen.dart` | — |
| — | (Ek ekran) | Şehir Seç | `screens/city_picker_screen.dart` | `settingsProvider`, `citiesProvider` |

## Ana ekran

Yukarıdan aşağıya: uyarı kartları (`CorruptedDatabaseCard`, `NotificationHealthCard`), Mihrap kemeri ve Selçuklu yıldızı motifli [[takip-gunu-ve-sayac]] geri sayım Hero kartı (`CountdownCard` — sıradaki vakit rozeti, hedef saat, büyük tabular sayaç, iki vakit arası ilerleme çubuğu, tarih ve `X / 5 Vakit Eda Edildi` özeti), "BUGÜNÜN NAMAZLARI • tarih" başlığı ve sol kenarında dikey zaman çizelgesi (timeline) bulunan vakit kartları (`PrayerCard`: Sabah, Güneş, Öğle, İkindi, Akşam, Yatsı). Konum yoksa kartların yerine Selçuklu madalyonlu konum isteme kartı çıkar: [[konum]]. Bir karta dokunmak `SeljukMedallion` başlıklı işaretleme diyaloğunu açar: [[namaz-isaretleme]]. Bildirimden gelen sorular da bu ekranda açılır: [[bildirimler]]. Uygulama ön plana dönünce takip günü, konum ve kayıtlar tazelenir (`didChangeAppLifecycleState`).

Widget'lar: `PrayerCard` (zaman çizelgeli vakit kartı), `CountdownCard` (mihrap hero sayaç kartı), `MihrabArchBackdrop` ve `SeljukMedallion` (`islamic_pattern.dart` — `CustomPainter` tabanlı İslami geometrik motifler), `showPrayerDialog` (diyalog), `CorruptedDatabaseCard` (bozuk veritabanı uyarısı), `NotificationHealthCard` (tam zamanlı alarm izni uyarısı) → `lib/ui/widgets/`.

**Başlatma hata ekranı:** `StartupErrorApp` (`lib/ui/startup_error_app.dart`), `NamazBackend.create` hata verirse normal uygulama yerine gösterilir: mesaj, ayrıntı ve tek düğme "Tekrar dene". Verileri silen bir eylem sunmaz. Emülatörde veritabanı yolu klasör yapılarak doğrulandı: hata sürerken ekran kalır, sorun giderilip "Tekrar dene"ye basılınca normal açılır.

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

- Ekranlar backend'i doğrudan çağırmaz; Riverpod sağlayıcılarını kullanır. `backendProvider` yalnızca olay anlarında (izin, bildirim akışı, şehir listesi, takip başlangıcı) okunur; test bunu sınırlar: [[durum-yonetimi]], [[backend-paketi]].
- Renkler `context.palette` ile alınır, sabit renk yazılmaz (istisna: ısı haritası ve durum renkleri): [[tema-sistemi]].
- Metin ve ikon merkezi sistemlerden gelir; test bunu zorlar: [[metin-sistemi]], [[ikon-sistemi]].
- Ekran okuyucu etiketleri ve kontrast kararları: [[erisilebilirlik-ve-kontrast]].

## İlgili sayfalar

[[mimari-genel]] · [[durum-yonetimi]] · [[proje-ozeti]]
