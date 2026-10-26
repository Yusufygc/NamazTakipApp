# 002 — Vakitler API yerine cihazda hesaplanır

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Eski uygulama vakitleri `api.aladhan.com` üzerinden (yöntem 13, Diyanet) alıp SQLite'ta önbelleğe alıyordu. Eski notların en büyük sorunu "namaz vakitlerinin yanlış olması"ydı; ayrıca bildirim planlamak için her gün API'ye gitmek, ağ hatası ve konum/şehir eşleşmesi (önbellek anahtarı şehir adıydı) hata kaynağıydı. Arka plan görevinde de ağ gerekiyordu.

## Karar

Vakitler cihazda `adhan_dart` ile hesaplanır; varsayılan Diyanet yöntemi (`CalculationMethodParameters.turkiye()`). API çağrısı ve vakit önbelleği kaldırıldı.

## Sonuçlar

- İnternet gerekmez; uçak modunda ve arka planda çalışır: [[arka-plan-gorevleri]].
- Bildirim planı için dilediğimiz kadar gün ileri hesaplanabilir: [[bildirimler]].
- Hesaplanan değerler Aladhan Diyanet ile en çok 2 dakika fark etti (İstanbul, Ankara; 26 Eki, 21 Haz, 21 Ara): [[namaz-vakitleri]].
- Paket Diyanet'in bir **yaklaşımıdır**; resmî Diyanet tablosuyla birebir karşılaştırma yapılmadı ve bu risk [[bilinen-sorunlar]]'dadır.
- Kullanıcı farklı yöntem isteyebilir; ayarlarda altı yöntem sunulur.
- Vakitler UTC döner ve cihaz saat dilimine çevrilir; cihaz saat dilimi yanlışsa vakitler kayar.

## İlgili sayfalar

[[kararlar]] · [[namaz-vakitleri]] · [[001-flutter-gecisi]]
