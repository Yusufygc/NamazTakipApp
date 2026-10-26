# 009 — Konum: medium → high → son bilinen

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Vakit hesabı için şehir düzeyinde konum yeterlidir; sürekli yüksek doğrulukta GPS pil ve süre açısından gereksizdir. İlk sürüm `LocationAccuracy.low` kullandı. Emülatör testinde konum alınamadı: düşük/orta doğruluk "ağ konumu" ister, emülatörde ağ konumu yoktur ve `adb emu geo fix` yalnızca GPS sağlayıcısını besler (20 saniye sonra zaman aşımı). Gerçek cihazlarda da iç mekânda ağ konumu zayıf olabilir.

## Karar

`LocationService.current()` sırayla dener: `medium` (10 sn) → `high` (25 sn) → `getLastKnownPosition()`; hiçbiri yoksa `unavailable` hatası. Son başarılı konum saklanır ve arka plan görevi onu kullanır. Elle şehir seçimi her zaman alternatiftir.

## Sonuçlar

- Çoğu gerçek cihazda ilk adımda hızlı ve pil dostu sonuç beklenir; zayıf ağda GPS devreye girer.
- En kötü durumda açılışta 35 saniyeye kadar konum bekleme olabilir; bu sürede ana ekran "Konum alınıyor…" gösterir ve elle şehir seçilebilir: [[konum]].
- Arka plan konum izni gerekmez: [[arka-plan-gorevleri]].
- Emülatörde GPS yedek adımı sayesinde test mümkündür: [[gelistirme-ortami]].
- `forceLocationManager` denendi ve işe yaramadı; kullanılmıyor (geolocator isteği yine fused sağlayıcıya yönlendirdi).

## İlgili sayfalar

[[kararlar]] · [[konum]] · [[emulator-test-notlari]]
