# 010 — Proje bilgisi `docs/wiki/` içinde tutulur

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Projenin eski docs klasörü (istek metinleri, geliştirme notları) kullanıcı tarafından silindi. Proje bağlamı yalnızca sohbet geçmişinde ve kodda kalıyordu. Kullanıcı, bir "LLM Wiki" anayasası (`LLM-wiki.md`) sağladı: bilgi tabanı Obsidian tarzı bağlantılı Markdown sayfalarından oluşur; her işe `index.md` ile başlanır; değişiklikler `log.md`'ye işlenir; Ingest, Query, Lint operasyonları tanımlıdır. Gerekirse çok sayıda küçük sayfa kullanılması istendi.

## Karar

- Anayasa depo kökünde `CLAUDE.md` olarak durur (her oturumda otomatik okunur) ve projeye özel notlarla genişletilmiştir.
- Wiki `docs/wiki/` altındadır; ham kaynaklar için `docs/raw/` ayrılmıştır.
- Sayfalar konu başına küçük tutulur; kararlar `kararlar/` alt klasöründe ayrı kayıtlardır.
- Wiki depoya (git) girer; kodla birlikte sürümlenir.

## Sonuçlar

- Proje bağlamı oturumlar arasında kalıcıdır; sıfırdan keşif gerekmez: [[wiki-kullanim]].
- Her anlamlı değişiklikte wiki güncellenmelidir; güncellenmezse eskir. Çelişki ve öksüz sayfa taraması için "Wiki'yi Lint et" komutu vardır.
- Wiki, koddan türetilebilen ayrıntıları çoğaltmamalı; **neden**, **nasıl doğrulandı** ve **ne bilinmiyor** bilgisini tutmalıdır.

## İlgili sayfalar

[[kararlar]] · [[wiki-kullanim]] · [[log]]
