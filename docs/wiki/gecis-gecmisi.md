# Geçiş Geçmişi (React Native/Expo → Flutter)

Projenin ilk sürümü React Native ve Expo ile yazılmıştı. 2026-10-26'da sıfırdan Flutter'a yeniden yazıldı. Karar gerekçesi: [[001-flutter-gecisi]].

## Eski uygulama

| | |
|---|---|
| Çatı | Expo SDK 54, React Native 0.81.5, React 19, yeni mimari açık |
| Dil | Düz JavaScript (TypeScript yok), yaklaşık 4,2 bin satır; MVC düzeni (`controllers/`, `services/`, `views/`) |
| Gezinme | `@react-navigation` Drawer + alt sekmeler (`expo-router` şablondan kalma, kullanılmıyordu) |
| Depolama | `expo-sqlite` (5 tablo: `prayers`, `qaza_prayers`, `prayer_times_cache`, `reminder_settings`, `app_settings`), tema için AsyncStorage |
| Vakitler | `api.aladhan.com`, yöntem 13 (Diyanet), önbellekli |
| Bildirim | `expo-notifications`, 3 günlük pencere, her seferinde hepsini iptal edip yeniden planlama |
| Arka plan | `expo-background-task` + `expo-task-manager` |
| Grafik | `react-native-chart-kit`, `react-native-svg` |
| Derleme | EAS Build (`eas.json`, `preview` ve `production` profilleri, APK) |
| Uygulama kimliği | `com.namaztakip.app` (Flutter'da korundu) |

Özellikler: günlük takip, kaza listesi, radar ve ısı haritası, haftalık/aylık karşılaştırma, rozetler, beş tema, hakkında sayfası.

## Yeniden yazmanın nedenleri

Doğrudan kullanıcı isteği: "React Native ve Expo'dan sıyrılmak". Karar öncesi analiz: kod tabanı küçük ve TypeScript'siz olduğu için yeniden yazma maliyeti düşüktü; bildirim ve alarm çekirdek özellikti; Flutter tek render motoruyla iOS/Android arasındaki drawer ve tema uyumsuzluklarını ortadan kaldırıyordu. Uygulama yayınlanmamıştı, kullanıcı verisi yoktu; veri taşıma gerekmedi.

## Zaman çizelgesi (2026-10-26)

| Adım | Commit |
|---|---|
| `flutter-migration` branch'i açıldı; Flutter SDK ve Android araçları kuruldu | — |
| Flutter uygulaması `namaz_takip/` altında yazıldı, emülatörde test edildi | `ebce2b2` feat: rewrite app in Flutter |
| RN/Expo kalıntıları silindi, Flutter kök dizine taşındı, launcher ikonları üretildi | `0d94fbc` chore: remove React Native/Expo sources and move Flutter project to repo root |
| Merkezi ikon ve metin sistemi | `bb1ab70` refactor: add central icon system and modular string system |
| Wiki sistemi kuruldu | [[log]] |

Branch'ler: `main` (son RN sürümü), `backup-before-rewrite` (RN'in yedeği, "Bildirim sistemi düzeltildi" noktası), `flutter-migration` (Flutter). Silinen RN kodu `main` ve yedek branch'te durur.

## Neler değişti

| Konu | Eski | Yeni |
|---|---|---|
| Vakit kaynağı | Aladhan API (internet şart, vakitler yanlış çıkıyordu) | Cihazda hesap: [[namaz-vakitleri]] |
| Tarih biçimi | `dd-MM-yyyy` metin; `ORDER BY` ve seri hesabı hatalı | `yyyy-MM-dd`: [[003-iso-tarih-formati]] |
| Kaza | İki tablo (`prayers` + `qaza_prayers`), birleştirme kodu, çift kayıt hatası | Türetilir, tek tablo: [[005-kaza-turetilir]] |
| Kaza edilen vakit | Kılınmış sayılıp istatistiği şişiriyordu | Ayrı durum (3), istatistiğe girmez: [[veri-katmani]] |
| Sayaç | Metin karşılaştırmasıyla sıradaki vakit; Yatsı'dan sonra yenileme gerekirdi | Saat tabanlı: [[takip-gunu-ve-sayac]] |
| Bildirim | `cancelAll` + rastgele kimlik, çift hatırlatma | Sabit kimlikler, plan-uygula ayrımı: [[004-sabit-bildirim-kimlikleri]] |
| Karşılaştırma | 0 vakitte "yükselişte" | "Değişim yok": [[istatistikler]] |
| İstatistik günleri | Yalnızca kılınan günler | Sıfır günler dahil |
| "Daha sonra hatırlat" | İşlevsiz düğme | "Vazgeç" |
| Ayarlar | `app_settings` tablosu + AsyncStorage | `shared_preferences`: [[ayarlar-ve-kalicilik]] |
| Konum | Elle seçim yoktu, GPS tek yol | GPS + 81 il: [[konum]], [[009-konum-yedek-zinciri]] |
| Emoji ve sabit metin | Ekranlara dağınık | Merkezi ikon ve metin sistemi: [[008-merkezi-ikon-ve-metin]] |
| Arka plan | `expo-task-manager` | `workmanager`: [[arka-plan-gorevleri]] |
| Derleme | EAS Build | `flutter build`: [[derleme-ve-yayin]] |

## Taşınmayanlar

- **Ayasofya arka planı:** Eski uygulamada zaten kaldırılmıştı.
- **`reminder_settings` tablosu:** Eski tabloda tanımlıydı, uygulamada kullanılmıyordu.
- **`expo-router` şablon dosyaları** (`components/`, `hooks/`, `constants/theme.ts`, `scripts/reset-project.js`): ölü koddu.
- **Eski README.md:** RN'e özgü uzun dokümandı; geçmişte duruyor.

## Eski docs

Projenin eski istek ve notları (`Ilk_promt.txt`, `Gelistirmeler.txt`, `eksikler ve geliştirmeler.txt`, `namaz_app_prompt.md`) kullanıcı tarafından silindi. İçerikleri [[urun-gereksinimleri]] ve [[yol-haritasi]] sayfalarında özetlenmiştir.

## İlgili sayfalar

[[proje-ozeti]] · [[001-flutter-gecisi]] · [[kararlar]]
