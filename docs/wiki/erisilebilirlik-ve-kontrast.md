# Erişilebilirlik ve Kontrast

Emülatör testinde bulunan görsel sorunlar ve alınan kararlar. Bu sayfa, yeni bir ekran eklerken tekrar edilmemesi gereken hataları kaydeder.

## Alınan kararlar

| Sorun | Karar |
|---|---|
| Kılındı/Kılmadım kartları mat görünüyordu: `renk.withValues(alpha: .25)` kartın gölgesini altından gösteriyordu | Şeffaf renk yerine `Color.alphaBlend(renk.withValues(alpha: .25), palette.card)` ile **opak** zemin üretilir: [[namaz-isaretleme]] |
| Kılmadım kartında `#FF8A80` yazı açık pembe zeminde okunmuyordu | Açık temalarda yazı koyu kırmızı `#C62828`; koyu temada `palette.danger` |
| Karşılaştırmada "Yükselişte" yazısı ve ikonu beyaz üstünde açık limon yeşiliydi | Açık temalarda koyu yeşil `#2E7D32`; koyu temada `palette.secondary`: [[istatistikler]] |
| İki sistem izin penceresi çakışabilir | Sıralı istenir: [[izinler]] |
| Diyalog düğmeleri sağa yaslı yığılıyordu | `actionsOverflowAlignment: OverflowBarAlignment.center` |
| Kapalı hedefli düğmeler (ileri ay oku) | `IconButton.filledTonal(onPressed: null)` ile otomatik soluk görünür |

## Ekran okuyucu (Semantics)

| Yer | Etiket |
|---|---|
| Vakit kartı | "Öğle 12:53, kılındı" / "kılınmadı" (`HomeStrings.prayerSemantics`) |
| Geri sayım | "Yatsı vaktine 00:56:40 kaldı" (`HomeStrings.countdownSemantics`) |
| Isı haritası hücresi | "26 Ekim 2026: 2 / 5" |
| Tema kartı | "Tema: Okyanus", seçili durumu |
| Ay okları | `tooltip`: "Önceki ay", "Sonraki ay" |

Etiketler [[metin-sistemi]] modüllerindendir. Gerçek ekran okuyucuyla (TalkBack, VoiceOver) **test edilmedi**; etiketler koddan okunarak yazıldı: [[bilinen-sorunlar]].

## Kontrol listesi (yeni ekran için)

1. Renkler `context.palette`'ten gelsin; sabit renk gerekiyorsa açık ve koyu zeminde okunduğunu kontrol et ([[tema-sistemi]]).
2. Şeffaf renk kart üstüne konacaksa `alphaBlend` kullan.
3. Yalnızca renkle anlam taşıma: durumlar ikonla da gösterilir (tik, çarpı, kilit).
4. Dokunulabilir alan en az 48×48; `InkWell` ve `ListTile` bunu sağlar.
5. İkonlu düğme ve ikon-yalnız öğelerde `Semantics` veya `tooltip` ekle.
6. Beş temanın hepsinde gez.

## İlgili sayfalar

[[tema-sistemi]] · [[ui-ekranlar]] · [[bilinen-sorunlar]]
