# Ürün Gereksinimleri

Bu sayfa, uygulamanın ilk isteklerini ve sonradan eklenen geliştirme taleplerini, Flutter sürümündeki karşılıklarıyla birlikte toplar. Kaynak, projenin eski istek metinleridir (kullanıcı tarafından silinmiştir); burada özet olarak korunur. Ayrıntılı geçmiş için [[gecis-gecmisi]].

## Özgün tanım

"Namaz takip ve kaza namazı sayar." Tipik bir namaz uygulaması gibidir; ayrıcalığı veritabanı ve raporlama tarafının daha geniş olmasıdır. İlk plan React Native + Expo + SQLite idi; bugün teknoloji Flutter'dır ([[001-flutter-gecisi]]).

## Çekirdek gereksinimler

| Gereksinim | Flutter durumu | Not |
|---|---|---|
| Bulunulan konuma göre otomatik vakitler | Karşılandı | Artık API yerine cihazda hesaplanır: [[namaz-vakitleri]], [[002-vakitler-cihazda-hesaplanir]] |
| Sıradaki vakte kalan süreyi güncel göster | Karşılandı | [[takip-gunu-ve-sayac]] |
| Ezan anında "önceki namazı kıldın mı?" bildirimi | Karşılandı | Örn. ikindi girince öğleyi sorar: [[bildirimler]] |
| Bildirim yok sayılırsa uygulamaya girince sor | Kısmen | Bekleyen vakitler ana ekranda görünür; açılışta otomatik soru yok: [[yol-haritasi]] |
| Ekstra "kıldın mı" hatırlatıcıları | Kısmen | Ezandan N dakika sonra tek hatırlatma, süre ayarlanabilir; özel hatırlatıcı yok: [[bildirimler]] |
| Kılınan/kılınmayan namazlar için haftalık ve aylık görsel raporlar | Karşılandı | [[istatistikler]] |
| Yönetim yan menüde (drawer), ayarlar orada | Karşılandı | [[ui-ekranlar]] |
| SQLite ile kalıcı depolama | Karşılandı | [[veri-katmani]] |

## Sonradan eklenen talepler

Aşağıdakilerin hepsi eski uygulamada yapılmış olarak işaretlenmişti. Flutter sürümündeki durumları:

- **Kaza sayfasını günlere göre gruplama**, gün kutusunda özet, dokununca vakitler: yapıldı, [[kaza-sistemi]].
- **Başarımlar ve seri**: yapıldı, [[seri-ve-rozetler]].
- **Kılmadım işaretinde kırmızı çarpı**: yapıldı, [[namaz-isaretleme]].
- **Yatsıdan sonra sayfayı yenilemeden Sabah'a geçiş**: yapıldı ve emülatörde doğrulandı, [[takip-gunu-ve-sayac]].
- **İşaretlemeyi unutulan günlerin otomatik kazaya düşmesi**, tamamen kılınan günün listeden çıkması: yapıldı, [[kaza-sistemi]].
- **Karşılaştırma sayfasını haftalığa alıp "Süreç" altında toplama** (haftalık, aylık, karşılaştırma): yapıldı, [[ui-ekranlar]].
- **Konumun ekranda görünmesi**: yapıldı, [[konum]].
- **Tema ayarları**: yapıldı (beş tema), [[tema-sistemi]].
- **Konum seçme ayarı**: yapıldı (81 il), [[konum]].
- **Karşılaştırmada 0 vakitte "yükselişte" görünmesi**: giderildi; fark 0 ise "Değişim yok", [[istatistikler]].
- **Hatırlatmanın aynı anda iki kez gelmesi**: yapısal olarak giderildi; bildirim kimlikleri sabittir, [[004-sabit-bildirim-kimlikleri]].
- **Namaz vakitlerinin yanlış olması** (eski uygulamanın en büyük sorunu): vakitler Aladhan/Diyanet ile 1–2 dakika içinde örtüşüyor, [[namaz-vakitleri]].
- **Aynı vaktin birden çok kez kaza olarak kaydedilmesi**: engellendi, [[veri-katmani]].

## Henüz yapılmayanlar

Eski notlarda "ileride" diye geçen iki fikir vardı: ezberlenen sureler ve başarılar; eskiden birikmiş kaza namazlarını girip günlük hedefle ne zaman biteceğini hesaplama. İkisi de [[yol-haritasi]] sayfasındadır.

## İlgili sayfalar

[[proje-ozeti]] · [[yol-haritasi]] · [[gecis-gecmisi]]
