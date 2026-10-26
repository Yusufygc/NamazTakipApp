# 011 — Ön yüz ve backend ayrı paketlerdir

Durum: Kabul edildi
Tarih: 2026-10-26

## Bağlam

Kullanıcı "front ve backendi tamamen ayırmak, kod bağımlılığını minimuma indirmek" istedi. Uygulamada sunucu yoktur; "backend" arayüz dışındaki her şeydir: vakit hesabı, SQLite, ayarlar, konum, bildirim, arka plan görevi, kaza ve istatistik kuralları. O zamana kadar bunlar tek pakette, klasörlerle ayrılmıştı ama hiçbir şey sınırı zorlamıyordu: ekranlar `NotificationService.instance`'ı, `SettingsRepository`'yi ve `LocationService`'i doğrudan kullanıyordu; sağlayıcılar iş kuralı içeriyordu; metinler ve bildirim metinleri iç içeydi.

## Karar

Backend, `packages/namaz_backend/` altında **ayrı bir Dart paketi** olur (pub workspace). Ön yüz onu yalnızca tek bir arayüzle (`NamazBackend`) ve sade modellerle tanır:

- Konum, bildirim, depolama, arka plan ve vakit hesabı paketleri yalnızca backend'in `pubspec.yaml`'ındadır; ön yüzde bulunamaz.
- Backend yalnızca `package:namaz_backend/namaz_backend.dart` ile erişilir; `src/` içe aktarılamaz.
- İş kuralları (istatistik, kaza, rozet, bildirim planı) sağlayıcılardan backend'e taşındı; sağlayıcılar ince bir Riverpod katmanıdır.
- Dil ve metin kararı ön yüzdedir. Backend `NotificationTexts` portuyla metni dışarıdan alır.
- Tema, ikon, metin sistemi ve gösterim biçimleri (`formatTime`) ön yüzde kalır; tema anahtarı backend için yalnızca anlamsız bir kalıcı metindir.
- Sınırlar otomatik testle denetlenir (iki `architecture_test.dart`).

Backend içinde de katman sırası vardır: `domain ← data, platform ← application`.

## Sonuçlar

**Olumlu**

- Bağımlılık yönü ve sınır derleyici/analiz/test ile zorlanır; "yanlışlıkla" bağımlılık eklemek zorlaşır.
- Ön yüz `NamazBackend`'in sahte (fake) uygulamasıyla test edilebilir; backend arayüz olmadan test edilir (55 testin 36'sı backend'dedir).
- Ön yüzün bağımlılık listesi 3 pakete düştü (`flutter_riverpod`, `fl_chart`, `namaz_backend`); `intl` tamamen kalktı.
- Backend, başka bir ön yüzle (ör. farklı tema/uygulama) yeniden kullanılabilir.
- İş kuralları sağlayıcılardan çıktı; mantık tek yerde ve testlenebilir.

**Maliyet ve sınırlar**

- Daha fazla dosya ve bir katman: yeni özellik hem arayüze hem sağlayıcıya eklenir ([[backend-paketi]] sayfasındaki adımlar).
- Arka plan görevi bir **giriş noktası** ister: Workmanager üst düzey işaretli fonksiyon ister, bu yüzden ön yüz `namazBackgroundEntryPoint`'i tanımlar ve backend'in `handleBackgroundTasks`'ını çağırır; bu küçük bir geri çağrı bağımlılığıdır.
- Android/iOS proje dosyaları (izinler, `Info.plist`) uygulamada kalır; eklentiler backend'de olduğu halde platform ayarları ön yüz paketindedir. Backend'in neye ihtiyaç duyduğu [[android-yapilandirma]] ve [[ios-yapilandirma]] sayfalarında belgelidir.
- Backend içindeki depolar için ayrı soyut arayüzler (port) tanımlanmadı; sınır `NamazBackend` arayüzündedir. Depoları değiştirilebilir yapmak gerekirse eklenir: [[yol-haritasi]].
- Tema anahtarını backend'e saklatmak küçük bir kaçak sayılır; alternatifi ön yüzün kendi saklaması olurdu, ama bu ön yüze depolama paketi sokardı.

## Reddedilen seçenekler

- **Yalnızca klasör ayrımı** (tek pakette `core/data/services/ui`): sınırı zorlayan bir şey olmaz; mevcut durum buydu.
- **İki ayrı depo / iki uygulama:** gereksiz ayrışma; mobil uygulamada ağ üzerinden backend yoktur.
- **Backend'i saf Dart yapmak:** eklentiler (konum, bildirim, SQLite) Flutter gerektirir; saf Dart yalnızca `domain/` katmanında sağlandı ve testle korunur.

## İlgili sayfalar

[[kararlar]] · [[mimari-genel]] · [[backend-paketi]] · [[001-flutter-gecisi]] · [[006-riverpod-durum-yonetimi]]
