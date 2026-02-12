<p align="center">
  <h1 align="center">🕌 Namaz Takip</h1>
  <p align="center">
    <strong>Günlük beş vakit namazınızı kolayca takip edin, istatistiklerinizi görüntüleyin ve manevi gelişiminizi izleyin.</strong>
  </p>
  <p align="center">
    React Native • Expo • SQLite • Aladhan API
  </p>
</p>

---

## 📋 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Özellikler](#-özellikler)
- [Ekran Görüntüleri](#-ekran-görüntüleri)
- [Mimari & Yazılım Yapısı](#-mimari--yazılım-yapısı)
- [Teknoloji Yığını](#-teknoloji-yığını)
- [Kurulum](#-kurulum)
- [Proje Yapısı](#-proje-yapısı)
- [Veritabanı Şeması](#-veritabanı-şeması)
- [API Entegrasyonu](#-api-entegrasyonu)
- [Tema Sistemi](#-tema-sistemi)
- [Bildirim Sistemi](#-bildirim-sistemi)
- [Oyunlaştırma Sistemi](#-oyunlaştırma-sistemi)
- [Kullanım Kılavuzu](#-kullanım-kılavuzu)
- [Geliştirici Notları](#-geliştirici-notları)

---

## 🌟 Genel Bakış

**Namaz Takip**, Müslümanların günlük beş vakit namazlarını düzenli bir şekilde takip etmelerini sağlayan kapsamlı bir mobil uygulamadır. Konum tabanlı otomatik namaz vakti hesaplama, detaylı istatistikler, kaza namazı yönetimi, gamifikasyon (oyunlaştırma) ve dinamik tema desteği gibi modern özellikler sunar.

Uygulama; **React Native** ve **Expo** altyapısı üzerinde geliştirilmiş olup, **SQLite** veritabanı ile yerel veri depolama ve **Aladhan API** ile namaz vakitleri hesaplama işlevlerini kullanmaktadır.

### Neden Bu Uygulama?

| Sorun | Çözüm |
|-------|-------|
| Namazları takip etmek zor | Tek dokunuşla kayıt, otomatik kaza tespiti |
| Gelişimi ölçmek güç | Haftalık/aylık grafikler, radar ve ısı haritası |
| Motivasyon eksikliği | Seri takibi, rozetler ve başarı sistemi |
| Her konum için ayrı ayar | Otomatik konum algılama ve Diyanet hesaplama yöntemi |
| Kişiselleştirme istekleri | 5 farklı tema seçeneği (koyu mod dahil) |

---

## ✨ Özellikler

### ⏰ Otomatik Namaz Vakitleri
- Cihaz konumunuza göre **otomatik namaz vakti hesaplama**
- **Aladhan API** entegrasyonu (Diyanet / Türkiye hesaplama yöntemi — method 13)
- 6 vakit gösterimi: Sabah (İmsak), Güneş, Öğle, İkindi, Akşam, Yatsı
- Namaz vakitleri otomatik olarak **önbelleğe alınır** (gereksiz API çağrısı yapılmaz)
- Aşağı çekerek yenileme (**pull-to-refresh**) desteği

### ⏳ Geri Sayım Sayacı
- Bir sonraki namaz vaktine **anlık geri sayım**
- Vakit girdiğinde **otomatik güncelleme** ve ekran yenileme
- Şık ve modern tasarım ile kolay okunabilirlik

### ✅ Namaz Takibi
- Her vakit için **kıldım / kılmadım** kaydı
- **Cemaatle kılma** seçeneği
- Kılınan namazlar **yeşil ✓**, kaçırılan namazlar **kırmızı ✕** ile gösterilir
- Bir sonraki namaz **özel renk ve ⏳ ikonu** ile vurgulanır

### 📋 Kaza Namazı Yönetimi
- Kaçırılan namazlar **otomatik olarak kaza listesine** eklenir
- **Tarihe göre gruplandırılmış** genişletilebilir kart tasarımı
- Kaza namazını kıldığınızda tek dokunuşla **"Kaza Et"** işareti
- Toplam kaza borcu göstergesi
- Hem manuel olarak işaretlenen hem de **otomatik tespit edilen** kazalar

### 📊 Detaylı İstatistikler

#### Radar Grafiği (Performans)
- Her namaz vakti için **kılma oranı yüzdesi** (son 30 gün)
- SVG tabanlı **pentagon radar grafiği**
- Renk kodlu performans göstergesi (%80+ yeşil, %50-79 sarı, %0-49 kırmızı)
- **Akıllı analiz** özelliği: En güçlü ve en zayıf vaktinizi otomatik tespit

#### Isı Haritası (Takvim)
- Aylık takvim görünümünde **günlük namaz performansı**
- Renk kodları: Yeşil (5/5), Sarı (3-4), Turuncu (1-2), Kırmızı (0)
- **Ay değiştirme** navigasyonu

#### Haftalık Karşılaştırma
- **Bu hafta vs. geçen hafta** karşılaştırması
- **Bar chart** (haftalık) ve **line chart** (aylık) grafikleri
- Gelişim durumu göstergesi (yükseliş / düşüş trendi)

### 🔥 Oyunlaştırma (Gamification)
- **Kesintisiz seri takibi** — Mevcut ve en uzun seri
- **5 rozet** sistemi:
  - ✅ **İlk Hafta** — 7 gün üst üste tüm namazlar
  - 🔥 **Ay Tamamlayıcı** — 30 gün tam namaz
  - 💎 **100 Gün** — 100 gün tam namaz
  - 🕌 **Cemaat Dostu** — 50 vakit cemaatle namaz
  - ⏰ **Sabah Kahramanı** — 30 sabah namazı
- Her rozet için **ilerleme çubuğu**

### 🔔 Bildirim Sistemi
- Namaz vakitlerinde **push bildirim**
- Ayarlardan **açma/kapama** kontrolü
- Expo Notifications altyapısı

### 🎨 Dinamik Tema Sistemi
- **5 farklı tema** seçeneği:
  - 🌿 **Varsayılan (Sage)** — Doğal yeşil tonlar
  - 🌙 **Koyu (Dark)** — Göz yormayan karanlık mod
  - 🌊 **Okyanus (Ocean)** — Mavi tonlar
  - 🌹 **Gül Kurusu (Rose)** — Pembe/bordo tonlar
  - ✨ **Altın (Gold)** — Altın/sarı tonlar
- Seçim **AsyncStorage** ile kalıcı olarak saklanır
- Tüm ekranlar ve bileşenler temayı **anında** uygular

### ℹ️ Hakkında Sayfası
- Uygulama tanıtımı ve özellik listesi
- Adım adım **kullanım rehberi**
- İpuçları bölümü

---

## 🏗️ Mimari & Yazılım Yapısı

Uygulama, **katmanlı mimari (Layered Architecture)** prensibine uygun olarak tasarlanmıştır. Her katman belirli bir sorumluluk üstlenir ve katmanlar arası bağımlılık tek yönlüdür (üstten alta).

```
┌─────────────────────────────────────────────────┐
│                   Views Layer                    │
│         (Screens, Components, Navigation)        │
├─────────────────────────────────────────────────┤
│                 Context Layer                    │
│              (ThemeContext)                       │
├─────────────────────────────────────────────────┤
│               Controllers Layer                  │
│  (PrayerController, GamificationController,      │
│   LocationController)                            │
├─────────────────────────────────────────────────┤
│                Services Layer                    │
│  (DatabaseService, PrayerTimesAPI,               │
│   NotificationService)                           │
├─────────────────────────────────────────────────┤
│              Utils & Constants                   │
│        (dateHelpers, colors, themes)             │
└─────────────────────────────────────────────────┘
```

### Katman Açıklamaları

| Katman | Sorumluluk | Dosyalar |
|--------|-----------|----------|
| **Views** | Kullanıcı arayüzü, ekranlar, bileşenler, navigasyon | `screens/`, `components/`, `navigation/` |
| **Context** | Global durum yönetimi (tema) | `ThemeContext.js` |
| **Controllers** | İş mantığı, veri dönüşümleri | `PrayerController.js`, `GamificationController.js`, `LocationController.js` |
| **Services** | Dış hizmetlerle iletişim (DB, API, push) | `DatabaseService.js`, `PrayerTimesAPI.js`, `NotificationService.js` |
| **Utils/Constants** | Yardımcı fonksiyonlar, sabitler | `dateHelpers.js`, `colors.js`, `themes.js` |

### Veri Akışı

```
Kullanıcı Eylemi
    ↓
View (Screen/Component)
    ↓
Controller (İş Mantığı)
    ↓
Service (DB/API)
    ↓
Sonuç → Controller → View (Güncelleme)
```

**Örnek — Namaz Vakitlerini Getirme:**
1. `HomeScreen` → `PrayerController.getPrayerTimes()` çağırır
2. Controller: Önce **SQLite önbelleğini** kontrol eder
3. Önbellekte yoksa → `PrayerTimesAPI.getPrayerTimesByCoordinates()` çağırır
4. API yanıtı → SQLite'a **kayıt + önbellek** → Controller → HomeScreen'e döner
5. HomeScreen verileri state'e alır ve **PrayerCard** bileşenleriyle render eder

---

## 🛠️ Teknoloji Yığını

| Teknoloji | Kullanım Alanı | Versiyon |
|-----------|---------------|----------|
| **React Native** | Mobil uygulama çerçevesi | 0.81.5 |
| **Expo** | Geliştirme platformu | ~54.0 |
| **expo-sqlite** | Yerel veritabanı (SQLite) | ~16.0 |
| **expo-location** | Konum algılama | ~19.0 |
| **expo-notifications** | Push bildirimler | ~0.32 |
| **@react-navigation** | Navigasyon (Drawer + Bottom Tabs) | v7 |
| **react-native-chart-kit** | Bar & Line grafikleri | ^6.12 |
| **react-native-svg** | SVG tabanlı radar grafiği | 15.12 |
| **axios** | HTTP istemcisi (API çağrıları) | ^1.13 |
| **AsyncStorage** | Kalıcı anahtar-değer depolama (tema) | ^2.2 |
| **date-fns** | Tarih yardımcı fonksiyonları | ^4.1 |
| **Aladhan API** | Namaz vakitleri hesaplama | v1 |

---

## 🚀 Kurulum

### Gereksinimler
- **Node.js** 18+ yüklü olmalı
- **Expo CLI** (`npx expo` ile kullanılabilir)
- **Android Studio** (Android emülatör) veya fiziksel cihaz
- **Expo Go** uygulaması (fiziksel cihazda test için)

### Adımlar

```bash
# 1. Projeyi klonlayın
git clone <repo-url>
cd prayer-tracker

# 2. Bağımlılıkları yükleyin
npm install

# 3. Expo geliştirme sunucusunu başlatın
npx expo start

# 4. Uygulamayı çalıştırın
# - Android emülatör için: a tuşuna basın
# - Fiziksel cihaz için: Expo Go ile QR kodu tarayın
```

### İlk Çalıştırma Notları
- Uygulama ilk açılışta **konum izni** isteyecektir (namaz vakitleri için gerekli)
- **Bildirim izni** otomatik istenir
- Veritabanı **otomatik oluşturulur** ve başlangıç ayarları yüklenir
- İnternet bağlantısı gereklidir (namaz vakitleri API'den çekilir, sonra önbelleğe alınır)

---

## 📁 Proje Yapısı

```
prayer-tracker/
├── App.js                          # Ana giriş noktası, DB init, ThemeProvider
├── package.json                    # Bağımlılıklar ve scriptler
├── assets/
│   └── images/
│       ├── Arkaplan.jpg            # Kaza sayfası arka plan görseli
│       └── Ayasofya.png            # Drawer menü arka plan görseli
│
└── src/
    ├── constants/
    │   ├── colors.js               # Varsayılan renk paleti (sabit, geriye uyumlu)
    │   └── themes.js               # 5 tema paleti tanımları
    │
    ├── context/
    │   └── ThemeContext.js          # ThemeProvider + useTheme() hook
    │
    ├── controllers/
    │   ├── PrayerController.js     # Namaz vakitleri, istatistik, ısı haritası, radar
    │   ├── GamificationController.js # Seri hesaplama, rozet sistemi
    │   └── LocationController.js   # Konum algılama (expo-location)
    │
    ├── services/
    │   ├── api/
    │   │   └── PrayerTimesAPI.js   # Aladhan API entegrasyonu
    │   ├── database/
    │   │   └── DatabaseService.js  # SQLite bağlantı, tablo oluşturma, CRUD
    │   └── notifications/
    │       └── NotificationService.js # Push bildirim yönetimi
    │
    ├── utils/
    │   └── dateHelpers.js          # Tarih formatlama yardımcılar
    │
    └── views/
        ├── components/
        │   ├── PrayerCard.js       # Namaz vakti kartı (kılındı/kaçırıldı/sonraki)
        │   ├── CountdownTimer.js   # Geri sayım sayacı
        │   ├── ConfirmationDialog.js # Namaz onay/kaçırma diyaloğu
        │   ├── PrayerHeatmap.js    # Aylık ısı haritası takvimi
        │   └── PrayerRadarChart.js # SVG radar performans grafiği
        │
        ├── navigation/
        │   ├── RootNavigator.js    # NavigationContainer wrapper
        │   ├── DrawerNavigator.js  # Yan menü (Drawer) navigasyonu
        │   └── TabNavigator.js     # Alt sekme (Bottom Tab) navigasyonu
        │
        └── screens/
            ├── HomeScreen.js       # Ana ekran — namaz listesi, geri sayım
            ├── SettingsScreen.js   # Ayarlar — bildirimler, tema seçimi
            ├── QazaListScreen.js   # Kaza namazları listesi
            ├── GamificationScreen.js # Rozetler ve seri takibi
            ├── ComparisonStats.js  # Haftalık/aylık karşılaştırma grafikleri
            ├── StatisticsScreen.js # İstatistikler (Tab container)
            └── AboutScreen.js      # Hakkında — özellikler ve kullanım rehberi
```

---

## 🗃️ Veritabanı Şeması

Uygulama **SQLite** (expo-sqlite) kullanır. Veritabanı dosyası: `prayer_tracker.db`

### Tablolar

#### `prayers` — Günlük namaz kayıtları
| Sütun | Tür | Açıklama |
|-------|-----|----------|
| `id` | INTEGER (PK) | Otomatik artan ID |
| `prayer_name` | TEXT | Namaz adı (`Sabah`, `Öğle`, `İkindi`, `Akşam`, `Yatsı`) |
| `date` | TEXT | Tarih (DD-MM-YYYY) |
| `prayer_time` | TEXT | Namaz vakti (HH:MM) |
| `is_performed` | INTEGER | Kılındı mı? (0/1) |
| `performed_at` | TEXT | Kılınma zamanı |
| `is_congregation` | INTEGER | Cemaatle mi? (0/1) |
| `created_at` | TEXT | Kayıt tarihi |

> **UNIQUE constraint**: `(prayer_name, date)` — aynı gün aynı namaz tekrar kaydedilmez.

#### `qaza_prayers` — Kaza namazları
| Sütun | Tür | Açıklama |
|-------|-----|----------|
| `id` | INTEGER (PK) | Otomatik artan ID |
| `prayer_name` | TEXT | Kaçırılan namaz adı |
| `missed_date` | TEXT | Kaçırılma tarihi |
| `is_compensated` | INTEGER | Kaza edildi mi? (0/1) |
| `compensated_at` | TEXT | Kaza tarihi |
| `notes` | TEXT | Notlar |

#### `prayer_times_cache` — API önbelleği
| Sütun | Tür | Açıklama |
|-------|-----|----------|
| `date` | TEXT | Tarih |
| `city`, `country` | TEXT | Konum bilgileri |
| `fajr`, `sunrise`, `dhuhr`, `asr`, `maghrib`, `isha` | TEXT | Namaz vakitleri |
| `latitude`, `longitude` | REAL | Koordinatlar |

> Aynı gün ve şehir için tekrar API çağrısı yapılmaz.

#### `app_settings` — Uygulama ayarları
| Anahtar | Varsayılan | Açıklama |
|---------|-----------|----------|
| `notification_enabled` | `'1'` | Bildirimler açık/kapalı |
| `calculation_method` | `'13'` | Diyanet (Türkiye) yöntemi |
| `language` | `'tr'` | Dil |
| `selected_city` | `''` | Seçili şehir |

#### `reminder_settings` — Hatırlatıcı ayarları
| Sütun | Tür | Açıklama |
|-------|-----|----------|
| `reminder_type` | TEXT | `'after_adhan'` veya `'custom'` |
| `minutes_after` | INTEGER | Ezan sonrası dakika (varsayılan: 15) |
| `is_active` | INTEGER | Aktif mi? |

### İndeksler
```sql
idx_prayers_date        ON prayers(date)
idx_prayers_performed   ON prayers(is_performed)
idx_qaza_compensated    ON qaza_prayers(is_compensated)
idx_cache_date          ON prayer_times_cache(date)
```

---

## 🌐 API Entegrasyonu

### Aladhan API

Namaz vakitleri [Aladhan API](https://aladhan.com/prayer-times-api) üzerinden hesaplanır.

**Base URL:** `https://api.aladhan.com/v1`

**Endpoint:**
```
GET /timings/{date}?latitude={lat}&longitude={lon}&method=13
```

| Parametre | Açıklama |
|-----------|----------|
| `date` | Tarih (DD-MM-YYYY formatında) |
| `latitude` | Enlem |
| `longitude` | Boylam |
| `method` | Hesaplama yöntemi (13 = Diyanet İşleri Başkanlığı) |

**Yanıt örneği:**
```json
{
  "data": {
    "timings": {
      "Fajr": "06:15",
      "Sunrise": "07:42",
      "Dhuhr": "12:55",
      "Asr": "15:43",
      "Maghrib": "18:07",
      "Isha": "19:29"
    }
  }
}
```

### Önbellekleme Stratejisi
1. Controller ilk olarak **SQLite önbelleğini** kontrol eder
2. Önbellekte varsa → doğrudan döner (API çağrısı yapılmaz)
3. Önbellekte yoksa → API'den çeker, önbelleğe kaydeder, döner
4. Pull-to-refresh ile **force update** yapılabilir (önbellek silinir, yeniden çekilir)

---

## 🎨 Tema Sistemi

### Mimari

```
ThemeProvider (App.js)
    ├── AsyncStorage'dan tema yükle
    ├── Context ile tüm uygulamaya sun
    └── useTheme() hook
         ├── colors (aktif tema renkleri)
         ├── themeName (aktif tema adı)
         ├── setTheme(key) (tema değiştir)
         └── themes (tüm temalar)
```

### Tema Yapısı

Her tema şu renk anahtarlarına sahiptir:

| Anahtar | Kullanım |
|---------|----------|
| `primary` | Ana başlıklar, aktif sekmeler, ana butonlar |
| `secondary` | Başarı durumları, kılınan namazlar |
| `accent` | Vurgular, sonraki namaz arka planı |
| `dark` | Koyu arka planlar, aktif ikonlar |
| `background` | Sayfa arka planı |
| `white` | Kart arka planları |
| `text` | Ana metin rengi |
| `textLight` | İkincil metin rengi |
| `success` | Başarı rengi |
| `danger` | Hata/kaçırma rengi |
| `warning` | Uyarı rengi |

### Bileşenlerde Kullanım

```javascript
import { useTheme } from '../../context/ThemeContext';

export default function MyComponent() {
    const { colors } = useTheme();
    const styles = getStyles(colors);
    // ...
}

const getStyles = (colors) => StyleSheet.create({
    container: { backgroundColor: colors.background },
    text: { color: colors.text },
});
```

---

## 🔔 Bildirim Sistemi

- **expo-notifications** kullanılır
- Uygulama açılışında bildirim izni istenir
- Her gün namaz vakitleri yüklendiğinde **bildirimler planlanır**
- Ayarlardan bildirimler kapatılabilir

---

## 🏆 Oyunlaştırma Sistemi

### Seri (Streak) Hesaplama
- **Tam gün**: 5/5 namaz kılınan gün
- **Mevcut seri**: Bugünden/dünden geriye doğru kesintisiz tam gün sayısı
- **En uzun seri**: Tüm geçmişte kaydedilen en uzun kesintisiz seri

### Rozet Sistemi

| Rozet | Hedef | Koşul |
|-------|-------|-------|
| ✅ İlk Hafta | 7 | En uzun seri ≥ 7 gün |
| 🔥 Ay Tamamlayıcı | 30 | Toplam tam gün ≥ 30 |
| 💎 100 Gün | 100 | Toplam tam gün ≥ 100 |
| 🕌 Cemaat Dostu | 50 | Cemaatle kılınan ≥ 50 vakit |
| ⏰ Sabah Kahramanı | 30 | Kılınan sabah namazı ≥ 30 |

---

## 📱 Kullanım Kılavuzu

### Ana Ekran
1. Uygulama açıldığında **konumunuz otomatik algılanır**
2. Günün 6 namaz vakti (Sabah, Güneş, Öğle, İkindi, Akşam, Yatsı) listelenir
3. **Geri sayım sayacı** bir sonraki vakte kalan süreyi gösterir
4. Bir namaz kartına dokunduğunuzda onay diyaloğu açılır:
   - **"Kıldım"** → Cemaatle kılma seçeneği ile birlikte kayıt
   - **"Kılmadım"** → Kaza listesine eklenir
   - **"Daha Sonra Hatırlat"** → İşlem yapılmaz

### Kaza Namazları
1. Sol menüden **"Kaza Namazları"** seçin
2. Kaçırılan namazlar **tarihe göre gruplandırılmış** kartlarda gösterilir
3. Bir kartı genişletmek için üzerine dokunun
4. **"Kaza Et"** butonuyla kaza namazını işaretleyin

### İstatistikler
1. Sol menüden **"İstatistikler"** seçin
2. Alt sekmeleri kullanarak 3 farklı görünüm arasında geçiş yapın:
   - **Performans**: Radar grafiği — her vakit için kılma oranı
   - **Isı Haritası**: Aylık takvim — günlük performans renkleri
   - **Karşılaştırma**: Haftalık/aylık çubuk ve çizgi grafikleri

### Rozetler & Seri
1. Sol menüden **"Rozetler & Seri"** seçin
2. Kesintisiz seri sayınızı ve en uzun serinizi görüntüleyin
3. Rozet kartlarında ilerleme çubuğunu takip edin

### Tema Değiştirme
1. Sol menüden **"Ayarlar"** seçin
2. **"Tema Seçimi"** bölümüne kaydırın
3. İstediğiniz tema kartına dokunun — tema anında uygulanır
4. Seçiminiz otomatik kaydedilir

---

## 🧪 Geliştirici Notları

### Navigasyon Yapısı

```
App.js (ThemeProvider)
└── RootNavigator (NavigationContainer)
    └── DrawerNavigator (Yan Menü)
        ├── HomeScreen
        ├── GamificationScreen
        ├── QazaListScreen
        ├── TabNavigator (Alt Sekmeler)
        │   ├── PrayerRadarChart (Performans)
        │   ├── PrayerHeatmap (Isı Haritası)
        │   └── ComparisonStats (Karşılaştırma)
        ├── SettingsScreen
        └── AboutScreen
```

### Veritabanı Migration Sistemi
`DatabaseService.initDB()` içinde basit bir migration mekanizması bulunur:
- Tablo şeması `PRAGMA table_info()` ile kontrol edilir
- Eksik sütunlar `ALTER TABLE` ile eklenir
- Örnek: `is_congregation` sütunu sonradan eklendi

### Tarih Formatı
- **Veritabanı & API**: `DD-MM-YYYY` formatı
- **Gösterim**: Türkçe format (`25 Ocak 2026`)

### Performans İyileştirmeleri
- `PRAGMA journal_mode = WAL` — Yazma performansı artırır
- Veritabanı indeksleri — Sorgu performansı
- API önbelleği — Gereksiz ağ çağrılarını önler
- `useFocusEffect` — Sadece ekran görünürken veri yükler

---

## 📄 Lisans

Bu proje kişisel kullanım amaçlıdır.

---

## 👨‍💻 Geliştirici

**MYY** — Namaz Takip © 2026

🤲 *Allah kabul etsin*
