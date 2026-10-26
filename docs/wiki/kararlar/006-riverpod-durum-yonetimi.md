# 006 — Durum yönetimi için Riverpod

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Uygulamada paylaşılan durum çoktur: ayarlar, konum, takip günü, bugünün kayıtları, istatistikler. İstatistik ekranları bir işaretleme sonrası tutarlı yenilenmeli; servisler (veritabanı, ayar deposu) bağımlılık olarak enjekte edilebilmeli; arka plan izolatında aynı servis kodu çalışmalı.

## Karar

`flutter_riverpod` 3.x kullanılır. `Notifier`/`AsyncNotifier` ile durum, `FutureProvider.autoDispose` ile türetilmiş veri, `ProviderScope.overrides` ile bağımlılık enjeksiyonu yapılır.

## Sonuçlar

- Ekran değişince autoDispose sağlayıcılar atılır; her giriş taze veri okur: [[durum-yonetimi]].
- Bir işaretleme `StatsVersion` sayacını artırarak tüm istatistik sağlayıcılarını tutarlı yeniler.
- Altyapı sağlayıcıları (`settingsRepositoryProvider`, `appDatabaseProvider`) `main()` içinde override edilir; testler fake verebilir.
- Riverpod 3'te `StateNotifier` eski sayılır; yeni kod `Notifier` kullanır.
- Mantık sağlayıcıda değil servis/repository'de tutulur; sağlayıcılar ayrıca test edilmez: [[test-stratejisi]].

## Değerlendirilen alternatifler

Karar geliştirici tarafından tasarım sırasında verildi; alternatifler ayrıntılı denenmedi, gerekçeleri şunlardır: `setState` + `InheritedWidget` (çok sayıda paylaşılan durum için yetersiz), Bloc (bu boyutta fazla tören), Provider paketi (Riverpod'un öncülü, daha az güvenli).

## İlgili sayfalar

[[kararlar]] · [[durum-yonetimi]] · [[mimari-genel]]
