# 001 — React Native/Expo yerine Flutter

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Uygulama Expo SDK 54 ve React Native 0.81 ile yazılmıştı. Kullanıcı "React Native ve Expo'dan sıyrılmak" istedi ve Flutter ile "Expo'suz React Native" (bare RN) arasında seçim yapılmasını istedi. Uygulama yayınlanmamıştı; gerçek kullanıcı verisi yoktu. Hedef: Android ve iOS.

Karar öncesi tespitler:

- Kod tabanı küçüktü (≈4,2 bin satır düz JavaScript, TypeScript yok); yeniden yazma maliyeti düşüktü.
- Çekirdek özellik bildirim ve alarmdı; her iki yolda da yerel bildirim paketleri olgundu.
- Expo yalnızca RN ekosistemine aittir; Flutter ile Expo kullanılmaz. Yalnızca Expo'dan çıkmak isteseydik `expo prebuild` ile yeniden yazmadan çıkılabilirdi, ama RN'in bağımlılık ve yükseltme yükü kalırdı.
- Eski uygulamada drawer/tema uyumsuzlukları iOS ve Android arasında platform farkından geliyordu.

## Karar

Flutter ile sıfırdan yeniden yazıldı. `flutter-migration` branch'inde çalışıldı, iş bitince eski RN kodu silinip Flutter projesi kök dizine taşındı.

## Sonuçlar

- Tek render motoru: iOS ve Android'de aynı görünüm.
- Dart'a geçiş; geliştirici için öğrenme maliyeti kabul edildi.
- Windows'ta iOS derlenemiyor; iOS için macOS veya CI gerekir: [[ios-yapilandirma]].
- Eski kod `main` ve `backup-before-rewrite` branch'lerinde durur: [[gecis-gecmisi]].
- Yeniden yazma fırsatı kullanılarak eski hatalar yapısal olarak giderildi: [[002-vakitler-cihazda-hesaplanir]], [[003-iso-tarih-formati]], [[004-sabit-bildirim-kimlikleri]], [[005-kaza-turetilir]].

## İlgili sayfalar

[[kararlar]] · [[gecis-gecmisi]] · [[proje-ozeti]]
