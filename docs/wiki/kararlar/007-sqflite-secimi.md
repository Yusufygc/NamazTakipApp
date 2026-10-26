# 007 — Depolama için `sqflite`

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Eski uygulama SQLite kullanıyordu ve ilk istekte "DB için SQLite" yazıyordu. Flutter'da iki ana yol vardı: `sqflite` (doğrudan SQL) ve `drift` (tip güvenli, kod üretimli).

## Karar

`sqflite` kullanılır. Şema tek tablodur ([[veri-katmani]]), sorgular az ve basittir; `drift`'in kod üretimi (`build_runner`) ve ek katmanı bu boyutta gereksiz karmaşıklık getirir. Repository katmanı SQL'i uygulamanın geri kalanından saklar.

## Sonuçlar

- Bellek içi test için `sqflite_common_ffi` kullanılır: [[test-stratejisi]].
- SQL metinleri repository içindedir; yazım hatası derleyicide değil çalışma zamanında/testte yakalanır, bu yüzden repository testleri kapsamlıdır.
- Şema büyürse (örn. "birikmiş kaza" tablosu, ezberlenen sureler) `onUpgrade` geçişleri elle yazılır; `drift` geçişi daha az gerekirse yeniden değerlendirilir: [[yol-haritasi]].
- Ayarlar SQLite'a değil `shared_preferences`'a konur: [[ayarlar-ve-kalicilik]].

## İlgili sayfalar

[[kararlar]] · [[veri-katmani]] · [[bagimliliklar]]
