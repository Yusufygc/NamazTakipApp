# İkon Sistemi

Uygulamadaki tüm ikonlar tek yerdedir: `lib/core/icons/app_icons.dart`. Karar gerekçesi: [[008-merkezi-ikon-ve-metin]].

## Kural

- Ekranlarda **emoji kullanılmaz**.
- `Icons.xxx` (Material ikonları) yalnızca `app_icons.dart` içinde geçer; ekranlar `AppIcons.xxx` kullanır.
- İkonlar **anlamsal adla** adlandırılır (`AppIcons.navQaza`, `AppIcons.prayerPerformed`), görsel adla değil (`event_busy` değil). Böylece bir ikonu değiştirmek tek satırdır.
- Bildirimlerde ikon/emoji yoktur; sistem uygulama ikonunu gösterir: [[bildirimler]].

`test/central_system_test.dart` kuralı denetler: `lib/` içinde emoji varsa veya `app_icons.dart` dışında `Icons.[a-z]` geçiyorsa test düşer: [[test-stratejisi]].

## Gruplar

| Grup | Örnekler |
|---|---|
| Marka | `app` (cami) |
| Durum ve uyarı | `error`, `retry`, `warning` |
| Gezinme | `navHome`/`navHomeSelected`, `navBadges`/`navBadgesSelected`, `navQaza`/`navQazaSelected`, `navStats`/`navStatsSelected`, `navSettings`/`navSettingsSelected`, `navAbout` |
| Vakit kartı | `prayerIcon(PrayerType)`, `sunrise`, `prayerNext`, `prayerPerformed`, `prayerMissed`, `prayerPending`, `location`, `locationDetect`, `city`, `search`, `selected`, `chevronRight`, `calendar`, `notifications`, `timer`, `compass` |
| Diyalog | `dialogHeader`, `confirmPerformed`, `confirmMissed` |
| Kaza | `qazaItem`, `qazaEmpty`, `expand` |
| Süreç | `statsRadar`, `statsHeatmap`, `statsCompare`, `weekCurrent`, `weekPrevious`, `trendUp/Down/Flat`, `monthPrevious/Next` |
| Seri ve rozet | `streakCurrent`, `streakBest`, `streakDays`, `locked`, `achievement(id)` |
| Ayarlar | `congregation`, `theme(key)` |
| Hakkında | `aboutLocation`, `aboutTracking`, `aboutQaza`, `aboutStats`, `aboutBadges`, `aboutThemes`, `tip`, `dua` |

İki ikon bir kimliğe bağlıdır ve `switch` ile çözülür: `achievement(AchievementId)` ([[seri-ve-rozetler]]) ve `theme(String key)` ([[tema-sistemi]]). `achievement` kapsayıcıdır; yeni rozet eklenince derleyici eksik dalı gösterir.

## Yeni ikon ekleme

1. İkon adının Flutter'da var olduğunu doğrula (örn. `Icons.mosque` vardır, `Icons.gold` yoktur).
2. `AppIcons` içine uygun gruba anlamsal adla ekle.
3. Ekranda `AppIcons.adi` kullan.
4. `flutter test` çalıştır; koruma testi geçmeli.

## Uygulama (launcher) ikonu bu sistemin dışındadır

Telefonun ana ekranındaki ikon `assets/icon/` kaynaklarından üretilir: [[uygulama-ikonu]].

## İlgili sayfalar

[[metin-sistemi]] · [[ui-ekranlar]] · [[008-merkezi-ikon-ve-metin]]
