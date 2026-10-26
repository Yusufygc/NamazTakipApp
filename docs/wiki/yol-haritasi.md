# Yol Haritası

Yapılacak işler ve fikirler. "Kaynak" sütunu, işin kullanıcıdan mı geldiğini yoksa geliştirici önerisi mi olduğunu gösterir. Bir iş yapıldığında buradan çıkarılır ve [[log]] dosyasına işlenir.

## Öncelikli: doğrulama borçları

Bunlar yeni özellik değil, mevcut işin kanıtlanması içindir.

| İş | Neden | Bağlantı |
|---|---|---|
| Gerçek Android telefonda test | Bildirim güvenilirliği (pil kısıtlamaları), GPS, performans emülatörde görülmez | [[bilinen-sorunlar]], [[bildirimler]] |
| iOS derlemesi ve testi | iOS ayarları yazıldı ama hiç derlenmedi; Mac veya macOS CI gerekir | [[ios-yapilandirma]] |
| Koyu, Okyanus, Gül, Altın temalarında görsel test | Yalnızca Varsayılan tema emülatörde gezildi; kontrast sorunları çıkabilir | [[tema-sistemi]], [[erisilebilirlik-ve-kontrast]] |
| Arka plan görevinin 12 saatlik yenilemesini doğrulama | Henüz tetiklenmesi gözlenmedi | [[arka-plan-gorevleri]] |
| 04:00 gün geçişinin canlı doğrulaması | Mantık birim testli, canlı geçiş izlenmedi | [[takip-gunu-ve-sayac]] |

## Ürün özellikleri

| İş | Kaynak | Not |
|---|---|---|
| Eskiden birikmiş kaza namazlarını girip günlük kılma hızına göre bitiş tarihi hesaplama | Kullanıcı (eski notlar) | Yeni tablo veya ayar gerekir; [[kaza-sistemi]] ile birleştirilmeli |
| Ezberlenen sureler ve ilgili başarılar | Kullanıcı (eski notlar) | [[seri-ve-rozetler]] yapısına rozet ekler |
| Uygulama açılınca bekleyen vakit için otomatik soru | Kullanıcı (ilk gereksinim) | Şu an yalnızca kartlar bekleyen vakti gösterir: [[urun-gereksinimleri]] |
| "Daha sonra hatırlat" gerçek işlevi | Öneri | Eski uygulamada da işlevsizdi; yeni sürümde bu düğme "Vazgeç" oldu: [[namaz-isaretleme]] |
| Bildirimden doğrudan "Kıldım / Kılmadım" düğmeleri | Öneri | `flutter_local_notifications` eylem düğmelerini destekler; arka plan izolatında veritabanı yazımı gerekir |
| Özel (kullanıcı tanımlı) hatırlatıcılar | Kullanıcı (ilk gereksinim) | Şu an tek bir gecikme süresi ayarı var |
| Özel ezan sesi | Öneri | Bildirim kanalı ayarı ve ses dosyası gerekir |
| Çok dilli yapı (ARB) | Öneri | [[metin-sistemi]] modüler olduğu için geçiş kolaylaşır |
| Sistem koyu/açık temasını izleme | Öneri | [[tema-sistemi]] şu an kullanıcı seçimine bağlı |

## Yayın

| İş | Bağlantı |
|---|---|
| Release imzalama (keystore) | [[derleme-ve-yayin]] |
| Play Store için App Bundle ve mağaza kaydı | [[derleme-ve-yayin]] |
| App Store / TestFlight (Apple Developer hesabı gerekir) | [[ios-yapilandirma]] |
| Uygulama içi sürüm numarasını `pubspec.yaml` ile senkron gösterme | [[metin-sistemi]] (şu an `CommonStrings.version` sabit) |

## Teknik borç

- `workmanager_android` eski Kotlin eklentisini kullanıyor; Flutter ileride uyarıyı hataya çevirebilir: [[bagimliliklar]].
- Çekmece başlığının üstünde durum çubuğu alanı beyaz kalıyor: [[bilinen-sorunlar]].
- Widget testleri yalnızca başlangıç hata ekranı ve bildirim sağlığı kartını kapsıyor; ana ekranlar için yok: [[test-stratejisi]].

## İlgili sayfalar

[[proje-ozeti]] · [[urun-gereksinimleri]] · [[bilinen-sorunlar]]
