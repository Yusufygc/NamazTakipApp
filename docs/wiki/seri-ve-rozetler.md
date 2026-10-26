# Seri ve Rozetler

Oyunlaştırma katmanı. Kod: `lib/core/streaks.dart`, `lib/core/achievements.dart`, `lib/ui/screens/gamification_screen.dart`.

## Tam gün ve seri

**Tam gün:** beş vaktin de `performed` (durum 1) olduğu gün. Kaza edilmiş (3) ve "kılmadım" (2) vakitler tam günü oluşturmaz: [[veri-katmani]]. Sorgu: `PrayerRepository.fullDays()`.

`computeStreaks(tamGünler, bugün)` (saf fonksiyon) üç değer üretir (`StreakStats`):

| Değer | Tanım |
|---|---|
| `totalFullDays` | Tam gün sayısı (tekrarsız) |
| `bestStreak` | En uzun ardışık tam gün dizisi |
| `currentStreak` | Son tam gün **bugün veya dünse** o güne biten dizinin uzunluğu; son tam gün daha eskiyse 0 |

Gün farkı `daysDiff` ile hesaplanır (yaz/kış saatinden etkilenmez): [[veri-katmani]]. "Bugün" takip günüdür: [[takip-gunu-ve-sayac]].

## Rozetler

`AchievementId` enum'ı rozetleri tanımlar; başlık ve açıklama [[metin-sistemi]]'ndeki `GamificationStrings`'ten, ikon [[ikon-sistemi]]'ndeki `AppIcons.achievement(id)`'den gelir.

| Kimlik | Başlık | Koşul | İlerleme verisi |
|---|---|---|---|
| `firstWeek` | İlk Hafta | 7 gün üst üste tüm namazlar | `bestStreak` (en fazla 7) |
| `monthCompleter` | Ay Tamamlayıcı | Toplam 30 tam gün | `totalFullDays` (en fazla 30) |
| `hundredDays` | 100 Gün | Toplam 100 tam gün | `totalFullDays` (en fazla 100) |
| `congregationFriendly` | Cemaat Dostu | 50 vakit cemaatle | `totalCongregation()` (en fazla 50) |
| `morningHero` | Sabah Kahramanı | 30 sabah namazı | `totalPerformed(fajr)` (en fazla 30) |

`Achievement.isUnlocked`, `progress >= target` ile hesaplanır. `buildAchievements` saf fonksiyondur.

## Ekran

Üstte üç kutu (Güncel Seri, En İyi Seri, Tam Gün), altında rozet kartları: kilitliyken kilit ikonu ve soluk, açıkken rozet ikonu ve vurgulu zemin; her kartta ilerleme çubuğu ve "N / hedef" metni: [[ui-ekranlar]].

## Yeni rozet ekleme

1. `AchievementId`'ye değer ekle.
2. `buildAchievements`'e ilerleme satırı ekle (gerekirse repository'ye sorgu).
3. `GamificationStrings.achievementTitle/Description` ve `AppIcons.achievement` içindeki `switch`'lere ekle (derleyici eksik dalları gösterir).
4. `test/central_system_test.dart` her rozetin metni ve ikonu olduğunu doğrular.
5. Bu sayfayı güncelle. Ezberlenen sureler gibi veri gerektiren rozetler için [[yol-haritasi]].

## Test

`test/core_test.dart`: boş liste, bugünle biten seri, dünle biten seri devam eder, iki gün önce biten seri kopar ama en iyi seri korunur, ay sınırını aşan seri.

## İlgili sayfalar

[[istatistikler]] · [[namaz-isaretleme]] · [[kaza-sistemi]]
