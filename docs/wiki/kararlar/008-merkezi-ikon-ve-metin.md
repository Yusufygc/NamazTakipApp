# 008 — Merkezi ikon ve modüler metin sistemi

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

İlk Flutter sürümünde ekranlara 25 yerde emoji ve yüzlerce sabit Türkçe metin dağınık yazılmıştı. Emoji platforma göre farklı görünür, ikon boyutu ve rengi tema ile ayarlanamaz; sabit metinler ise değiştirmeyi, tutarlılığı ve ileride çeviriyi zorlaştırır. Bir de Dart'ın `toUpperCase()`'i Türkçede "İkindi"yi "İKINDI" yapıyordu. Kullanıcı açıkça "emoji değil merkezi ikon ve modüler merkezi string sistemi" istedi.

## Karar

- Tüm ikonlar `lib/core/icons/app_icons.dart` içinde anlamsal adlarla toplanır; emoji kullanılmaz: [[ikon-sistemi]].
- Tüm metinler `lib/core/strings/` altında modül başına bir dosyada tutulur ve tek `strings.dart` girişinden dışa açılır: [[metin-sistemi]].
- Kural bir testle zorlanır (`central_system_test.dart`): `lib/` içinde emoji, `app_icons.dart` dışında `Icons.xxx`, `lib/ui/` içinde Türkçe sabit metin olamaz.
- Enum'ların görünen adı enum'da değil strings modülündedir (çekirdek model dilden bağımsız kalır).

## Sonuçlar

- Bir ikon veya metin tek yerde değişir.
- Bildirim başlıklarından emoji kalktı; sistem uygulama ikonunu gösterir.
- `turkishUpper` ve `foldTurkish` yardımcıları eklendi.
- Çok dillilik için yapı hazır ama ARB geçişi yapılmadı: [[yol-haritasi]].
- Yeni ekran yazarken ek disiplin gerekir; test ihlalde düşer, bu yüzden unutulması riskli değildir.
- Launcher ikonu bu sistemin dışındadır: [[uygulama-ikonu]].

## İlgili sayfalar

[[kararlar]] · [[ikon-sistemi]] · [[metin-sistemi]]
