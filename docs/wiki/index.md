# Wiki Dizini

Namaz Takip projesinin bilgi tabanı. Her işe buradan başlayın; kurallar için depo kökündeki `CLAUDE.md` ve [[wiki-kullanim]]. Değişiklik geçmişi: [[log]].

## Başlangıç

- [[proje-ozeti]] — Uygulamanın ne olduğu, teknoloji, durum ve depo düzeni.
- [[urun-gereksinimleri]] — İlk istekler ve sonradan eklenen talepler, Flutter'daki karşılıkları.
- [[yol-haritasi]] — Yapılacak işler, fikirler ve doğrulama borçları.
- [[sozluk]] — Projede kullanılan terimler (vakit, kaza, takip günü, seri...).
- [[wiki-kullanim]] — Wiki'nin nasıl işlediği, yazım kuralları ve kod değişikliği sonrası kontrol listesi.

## Mimari ve veri

- [[mimari-genel]] — Ön yüz ve backend paketleri, sınır kuralları, başlangıç sırası ve örnek veri akışı.
- [[backend-paketi]] — `namaz_backend`: herkese açık yüz, `NamazBackend` arayüzü, katmanlar ve metin portu.
- [[durum-yonetimi]] — Ön yüzdeki Riverpod sağlayıcıları (backend'e delege eden ince katman) ve desenler.
- [[veri-katmani]] — SQLite şeması, durum kodları, tarih biçimi, repository sorguları.
- [[ayarlar-ve-kalicilik]] — `shared_preferences` anahtarları ve küçük kalıcı durum.
- [[bagimliliklar]] — Paketler, neden seçildikleri, uyarılar.

## Özellikler

- [[namaz-vakitleri]] — Cihazda vakit hesabı, yöntemler ve Aladhan ile doğruluk karşılaştırması.
- [[takip-gunu-ve-sayac]] — 04:00 gün kuralı, sıradaki vakit ve geri sayım kartı.
- [[namaz-isaretleme]] — Kıldım/Kılmadım diyaloğu, durumlar ve işaretleme sonrası akış.
- [[kaza-sistemi]] — Kaza listesinin türetilmesi, kaza etme ve arayüz.
- [[seri-ve-rozetler]] — Tam gün, seri hesabı ve beş rozet.
- [[istatistikler]] — Radar, ısı haritası ve haftalık/aylık karşılaştırma.
- [[konum]] — GPS ve elle şehir, yedek zinciri, emülatörde test notları.
- [[bildirimler]] — Plan, kimlikler, uygulama, dokunma ve sınırlar.
- [[arka-plan-gorevleri]] — Periyodik yeniden planlama (workmanager) ve platform farkları.
- [[izinler]] — İzin sırası, Android/iOS izinleri ve reddedilme davranışı.

## Arayüz

- [[ui-ekranlar]] — Kabuk, altı ekran ve şehir seçici.
- [[tema-sistemi]] — Beş tema, `AppPalette` ve doğrulama durumu.
- [[ikon-sistemi]] — `AppIcons` kuralları ve gruplar.
- [[metin-sistemi]] — Modüler `strings` sistemi, Türkçe yardımcılar.
- [[erisilebilirlik-ve-kontrast]] — Kontrast kararları ve ekran okuyucu etiketleri.

## Platform

- [[android-yapilandirma]] — Gradle, manifest, desugaring, imzalama ve tuzaklar.
- [[ios-yapilandirma]] — Info.plist, AppDelegate, arka plan kimliği; derlenmedi.
- [[uygulama-ikonu]] — Launcher ikonu kaynakları, üretimi ve proje dosyası tuzağı.

## Süreç

- [[gelistirme-ortami]] — Windows kurulumu, emülatör komutları ve tuzaklar.
- [[test-stratejisi]] — Test dosyaları, koruma testleri ve elle test listesi.
- [[derleme-ve-yayin]] — Derleme komutları, imzalama ve yayın kontrol listesi.
- [[emulator-test-notlari]] — Elle test turlarının kaydı ve bulunan hatalar.
- [[gecis-gecmisi]] — React Native/Expo'dan Flutter'a geçişin hikâyesi ve farkları.
- [[bilinen-sorunlar]] — Çözülmemiş sorunlar, doğrulanmamış alanlar ve sınırlar.

## Kararlar

- [[kararlar]] — Karar kayıtlarının listesi ve şablonu.
- [[001-flutter-gecisi]] — React Native/Expo yerine Flutter.
- [[002-vakitler-cihazda-hesaplanir]] — Vakitler API yerine cihazda hesaplanır.
- [[003-iso-tarih-formati]] — Tarihler `yyyy-MM-dd` saklanır.
- [[004-sabit-bildirim-kimlikleri]] — Bildirim kimlikleri tarih ve vakitten türetilir.
- [[005-kaza-turetilir]] — Kaza listesi türetilir, ayrı tabloda tutulmaz.
- [[006-riverpod-durum-yonetimi]] — Durum yönetimi için Riverpod.
- [[007-sqflite-secimi]] — Depolama için `sqflite`.
- [[008-merkezi-ikon-ve-metin]] — Merkezi ikon ve modüler metin sistemi.
- [[009-konum-yedek-zinciri]] — Konum: medium → high → son bilinen.
- [[010-wiki-sistemi]] — Proje bilgisi `docs/wiki/` içinde tutulur.
- [[011-front-backend-ayrimi]] — Ön yüz ve backend ayrı paketlerdir.

## Ham kaynaklar

`docs/raw/` klasörü şu an boştur; kural için `docs/raw/README.md`.
