# Wiki Kullanımı

Bu wiki, projenin kalıcı hafızasıdır. Çalışma kuralları depo kökündeki `CLAUDE.md` dosyasında (anayasa) yazılıdır; bu sayfa özetidir.

## Katmanlar

1. **Ham kaynaklar:** `docs/raw/`. Değiştirilmez, yalnızca okunur.
2. **Wiki:** `docs/wiki/`. Sayfalar Markdown'dır ve birbirine `[[sayfa-adi]]` biçiminde bağlanır.
3. **Anayasa:** `CLAUDE.md`.

## Giriş noktaları

- Her işe [[index]] ile başlanır: tüm sayfaların kategorili haritası.
- Neyin ne zaman değiştiği [[log]] dosyasındadır; en yeni kayıt en üsttedir.

## Sayfa yazım kuralları

- Dosya adı küçük harf ve tire ile yazılır, uzantı `.md` (`bildirimler.md`). Bağlantıda uzantı yazılmaz: `[[bildirimler]]`.
- Bağlantılar dosya adına göre çözülür; adlar tüm wiki'de benzersizdir. Karar kayıtları `kararlar/` alt klasöründedir ama bağlantıda klasör yazılmaz: `[[001-flutter-gecisi]]`.
- Her sayfa sonunda "İlgili sayfalar" bölümü bulunur. Öksüz sayfa bırakılmaz: her sayfa [[index]]'ten ve en az bir başka sayfadan erişilebilir olmalıdır.
- Sayfalar normal, tam cümlelerle yazılır. Kodda geçen adlar `kod biçiminde` verilir.
- Bir bilgi iki yerde tekrarlanmaz; ayrıntı tek sayfada tutulur, diğer sayfalar ona bağlanır.
- Tarihler `YYYY-AA-GG` biçimindedir.

## Operasyonlar

| Komut | Ne yapılır |
|---|---|
| **Ingest** | Yeni kaynak okunur, özet/konsept sayfası açılır, çelişen sayfalar güncellenir, [[index]] ve [[log]] güncellenir |
| **Query** | Soru, önce [[index]] üzerinden ilgili sayfalar okunarak yanıtlanır; kalıcı değer taşıyan sonuç wiki'ye yazılır |
| **Lint** | Çelişki, eskimiş karar, öksüz sayfa ve kırık bağlantı taranır; rapor sunulur, onaydan sonra düzeltilir |

## Bir kod değişikliği sonrası kontrol listesi

1. İlgili özellik sayfası güncellendi mi? ([[mimari-genel]] sayfasından hangi sayfaya bakılacağı bulunur.)
2. Yeni bir karar alındıysa `kararlar/` altında kayıt açıldı mı? ([[kararlar]])
3. Yeni paket eklendiyse [[bagimliliklar]] güncellendi mi?
4. Bilinen bir sorun çözüldüyse veya yeni çıktıysa [[bilinen-sorunlar]] güncellendi mi?
5. [[log]] dosyasına kayıt eklendi mi?

## İlgili sayfalar

[[proje-ozeti]] · [[kararlar]] · [[sozluk]]
