# Namaz İşaretleme

Kullanıcı bir vakte dokunur ve diyalogdan cevap verir. Kod: `lib/ui/widgets/prayer_dialog.dart`, `lib/ui/screens/home_screen.dart`, `TodayRecordsNotifier`.

## Diyalog

Başlık "X NAMAZINI / KILDINIZ MI?" biçimindedir (`PrayerDialogStrings`, büyük harfe çevirme `turkishUpper` ile: "İKİNDİ"). Seçenekler:

| Seçenek | Sonuç | Durum kodu |
|---|---|---|
| Cemaatle kıldım (kutu) + **Kıldım** | `markPerformed(congregation: true/false)` | 1 |
| **Kılmadım** | `markMissed` | 2 |
| **Vazgeç** | Hiçbir şey yapılmaz | — |

Diyalog başlığı, işaretlenen tarih bugünden farklıysa tarihi de gösterir (örn. Sabah bildirimiyle gelen "dünkü Yatsı" sorusu).

"Daha sonra hatırlat" düğmesi eski uygulamada vardı ama işlevsizdi; yeni sürümde "Vazgeç" oldu. Gerçek bir erteleme için [[yol-haritasi]].

## Kart görünümü

| Durum | Görünüm |
|---|---|
| Bekliyor | Boş daire |
| Sıradaki vakit | Vurgulu (birincil renk), kum saati |
| Kılındı (1 veya 3) | Açık yeşil zemin, tik |
| Kılmadım (2) | Açık kırmızı zemin, kırmızı çarpı, koyu kırmızı yazı |
| Güneş | Sarı kenarlık, güneş ikonu, dokunulamaz |

Kart renkleri şeffaf yerine kartın üstüne `Color.alphaBlend` ile harmanlanır; şeffaf renk altındaki gölgeyi gösterip mat görünüyordu: [[erisilebilirlik-ve-kontrast]].

## Tarih parametresi

`markPerformed(date, vakit, ...)` ve `markMissed(date, vakit)` **tarih alır**. Normal dokunuşta takip günü, bildirimden gelen soruda bildirimin taşıdığı tarih kullanılır. Sabah ezanı bildirimi dünkü Yatsı'yı sorduğu için bu gereklidir: [[bildirimler]].

## İşaretleme sonrası

1. Bugünün kayıtları yeniden okunur ve ekran güncellenir.
2. `StatsVersion` artar; istatistik sağlayıcıları yenilenir: [[durum-yonetimi]].
3. Kaza listesi geçersiz kılınır: [[kaza-sistemi]].
4. Bildirimler yeniden planlanır; işaretlenen vakit için hatırlatma ve soru artık üretilmez: [[bildirimler]].

## Yeniden işaretleme

Bir kart tekrar dokunulabilir; yeni cevap eskinin üzerine yazılır (upsert): [[veri-katmani]]. Bu, yanlış işaretlemeyi düzeltmenin yoludur; ayrı bir "geri al" yoktur.

## Doğrulama

Emülatörde: Öğle "Kıldım + cemaatle", Akşam "Kılmadım", sonra bildirimden gelen soruyla Akşam "Kıldım + cemaatle" yapıldı; veritabanında `maghrib|1|1`, rozetlerde "Cemaat Dostu 1/50" görüldü: [[emulator-test-notlari]].

## İlgili sayfalar

[[takip-gunu-ve-sayac]] · [[ui-ekranlar]] · [[seri-ve-rozetler]]
