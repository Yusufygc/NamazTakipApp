# 004 — Bildirim kimlikleri tarih ve vakitten türetilir

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Eski uygulama her yeniden planlamada tüm bekleyen bildirimleri iptal edip sıfırdan kuruyordu; bu, ön plan ve arka plan görevinin aynı anda çalıştığı durumlarda yarış yaratıyor ve "kıldın mı" hatırlatmasının aynı anda iki kez gelmesine yol açıyordu (eski notlarda "kritik" olarak işaretli).

## Karar

Her bildirimin kimliği `yyyymmdd × 10 + vakit × 2 + tür` olarak üretilir. Aynı vakit için her zaman aynı kimlik çıkar. Planlama "hepsini iptal et" yerine "plan dışı kalanları iptal et, plandakileri üzerine yaz" biçiminde yapılır. Plan ve uygulama ayrıdır: plan saf fonksiyondur (`buildNotificationPlan`).

## Sonuçlar

- Yeniden planlama idempotenttir; çift bildirim yapısal olarak imkânsızdır: [[bildirimler]].
- İki izolat aynı anda planlasa bile aynı kimliklerin üzerine yazar.
- İşaretlenen vaktin hatırlatması, planda yer almadığı için kendiliğinden iptal olur.
- Kimlik 32 bit işaretli sınırın altında kalır (2099'a kadar test edilir).
- Kimlik şeması değişirse eski bildirimler plan dışı sayılıp iptal edilir; geçiş sorunsuzdur.

## İlgili sayfalar

[[kararlar]] · [[bildirimler]] · [[001-flutter-gecisi]]
