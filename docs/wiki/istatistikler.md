# İstatistikler (Süreç)

Süreç ekranı üç sekmeden oluşur: Performans (radar), Isı Haritası ve Karşılaştırma. Kod: `lib/ui/screens/stats_screen.dart`; veri sağlayıcıları [[durum-yonetimi]]'ndedir. Eskiden ayrı sayfalar olan haftalık, aylık ve karşılaştırma tek "Süreç" altında birleşti: [[urun-gereksinimleri]].

Tüm sayımlar yalnızca `performed` (durum 1) vakitleri sayar; kaza edilenler dahil değildir: [[veri-katmani]], [[kaza-sistemi]].

## Performans (radar)

- `radarProvider(gün)`: seçilen aralıkta (7, 30 veya 90 gün) her vakit için yüzde.
- Yüzde = kılınan sayısı / payda × 100, 0–100'e sıkıştırılır. **Payda**, aralığın gün sayısı ile takip başlangıcından bugüne geçen gün sayısının **küçüğüdür**; uygulama yeni kurulduysa takip öncesi günler başarısızlık sayılmaz: [[ayarlar-ve-kalicilik]].
- `fl_chart` `RadarChart`; ölçeği 0–100'e sabitlemek için görünmez ikinci bir veri seti (hep 100) eklenir. Altında vakit başına ilerleme çubukları ve yüzde yazısı.

## Isı haritası

- Ay görünümü (Pazartesi ile başlar); ay okları arasında geçiş, ileri ok bu ayda kapanır. Gün hücrelerinde gün numarası ve "N/5".
- Renkler: 5/5 yeşil (`#4CAF50`), 3–4 sarı (`#FFC107`), 1–2 turuncu (`#FF9800`), 0 kırmızı (`#EF5350`).
- Takip başlangıcından önceki ve gelecek günler renksizdir.
- Veri: `monthCountsProvider(ay)`.

## Karşılaştırma

- Son 14 günün günlük sayıları iki yedi güne bölünür: `currentWeek` (son 7 gün) ve `previousWeek`; fark `diff = current − previous`.
- **Gelişim durumu:** `diff > 0` "Yükselişte" (yeşil), `diff < 0` "Düşüşte" (kırmızı), `diff == 0` "Değişim yok" (gri). Eski uygulama 0 vakitte bile "yükselişte" gösteriyordu; düzeltildi: [[urun-gereksinimleri]].
- Alt grafik: Haftalık (son 7 gün çubuk) veya Aylık (son 30 gün çizgi). Günlük sayılar **sıfır günleri de içerir** (`dailyCounts`); eski uygulama yalnızca kılınan günleri döndürüyordu.

## Test

`test/prayer_repository_test.dart`: `dailyCounts` sıfır günleri de döner ve yalnız kılınanı sayar; `performedByPrayer` beş vakti de döner. Radar paydası ve karşılaştırma mantığı sağlayıcı içindedir ve ayrıca birim testlenmemiştir: [[test-stratejisi]].

## İlgili sayfalar

[[seri-ve-rozetler]] · [[ui-ekranlar]] · [[tema-sistemi]] · [[erisilebilirlik-ve-kontrast]]
