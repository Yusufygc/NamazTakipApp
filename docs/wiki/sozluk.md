# Sözlük

Projede kullanılan terimler. Kodda İngilizce, arayüzde Türkçe karşılıkları geçer.

| Terim | Anlam | Kodda |
|---|---|---|
| Vakit | Günün beş namaz zamanından biri | `PrayerType` |
| Sabah / Öğle / İkindi / Akşam / Yatsı | Beş farz vakit | `fajr`, `dhuhr`, `asr`, `maghrib`, `isha` |
| Güneş | Güneşin doğuş vakti; farz vakit değildir, yalnızca bilgi için gösterilir | `DayTimes.sunrise` |
| Ezan | Vaktin girişini bildiren çağrı; bildirimler bu anda tetiklenir | [[bildirimler]] |
| Kıldım / Kılmadım | Kullanıcının bir vakit için verdiği cevap | `PrayerStatus.performed` / `missed` |
| Cemaatle | Namazın cemaatle kılındığı işareti; "Cemaat Dostu" rozetini besler | `is_congregation` |
| Kaza | Vaktinde kılınmamış namazın sonradan kılınması; "kaza namazı" aynı zamanda borç olan namaz demektir | [[kaza-sistemi]] |
| Kaza et | Kaza listesindeki bir vakti kıldığını işaretlemek | `PrayerStatus.compensated` |
| Otomatik tespit | İşaretlenmemiş geçmiş günlerin kendiliğinden kazaya düşmesi | `QazaItem.isAutoDetected` |
| Takip günü | Kullanıcının bugün saydığı gün; gece 04:00'e kadar dünkü gündür | [[takip-gunu-ve-sayac]] |
| İslami gün | Eski notlardaki kavram: gün akşam ezanıyla başlar. Uygulama bunu 04:00 kuralıyla yaklaşık karşılar | [[takip-gunu-ve-sayac]] |
| Diyanet yöntemi | Türkiye Diyanet İşleri Başkanlığı'nın hesaplama yaklaşımı (fecr 18°, yatsı 17° ve dakika ayarları) | [[namaz-vakitleri]] |
| Süreç | İstatistik ekranı: performans, ısı haritası, karşılaştırma | [[istatistikler]] |
| Seri | Üst üste tam (5/5) günlerin sayısı | [[seri-ve-rozetler]] |
| Rozet | Belirli bir hedefe ulaşınca açılan başarım | [[seri-ve-rozetler]] |
| Hatırlatma | Ezandan N dakika sonra gelen "kıldınız mı?" bildirimi | [[bildirimler]] |
| Ön yüz (front) | Kullanıcıya görünen her şey: ekranlar, tema, ikon, metin, Riverpod sağlayıcıları. Uygulama paketi `namaz_takip` | [[mimari-genel]] |
| Backend | Arayüz dışındaki her şey: vakit hesabı, SQLite, ayarlar, konum, bildirim, arka plan, kaza ve istatistik kuralları. Paket `namaz_backend` | [[backend-paketi]] |
| `NamazBackend` | Ön yüzün backend ile tek konuşma arayüzü | [[backend-paketi]] |
| Port | Backend'in bir bağımlılığı dışarıdan istediği arayüz; örn. `NotificationTexts` | [[backend-paketi]] |
| Takip başlangıcı | Uygulamanın ilk açıldığı gün (`install_date`); kaza hesabı buradan başlar | [[ayarlar-ve-kalicilik]] |

## İlgili sayfalar

[[proje-ozeti]] · [[index]]
