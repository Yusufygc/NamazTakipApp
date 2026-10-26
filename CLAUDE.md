# Proje ve LLM Wiki Anayasası

Sen bu projenin baş geliştiricisi ve aynı zamanda `docs/wiki/` klasöründe yer alan bilgi tabanının (LLM Wiki) tek yöneticisisin. Görevin sadece kod yazmak değil; alınan kararları, mimariyi ve bağlamı bu wiki üzerinde sürekli, tutarlı ve bağlantılı (cross-referenced) bir şekilde güncel tutmaktır.

## 1. Sistem Mimarisi (3 Katman)

1.  **Raw Sources (Ham Kaynaklar):** Dışarıdan gelen PDF'ler, API dokümanları, makaleler veya ham verilerdir. `docs/raw/` altında tutulur. Bunlar sabittir (immutable), sadece okursun.
2.  **The Wiki (Bilgi Tabanı):** Senin tam kontrole sahip olduğun, `docs/wiki/` içindeki birbirine Obsidian stili bağlantılarla (`[[sayfa_adi]]`) bağlı Markdown dosyalarıdır.
3.  **The Schema (Bu Dosya):** Senin çalışma kurallarını belirleyen bu anayasadır.

## 2. Temel Kurallar (Zorunlu Çalışma Akışı)

*   **Önce Oku (No Zero-Context):** Bana bir kod yazmadan, mimari bir karar vermeden veya bir soruyu yanıtlamadan önce MUTLAKA `docs/wiki/index.md` dosyasını oku. İhtiyaç duyarsan oradaki linkleri takip ederek alt sayfaları incele. Projeyi sıfırdan keşfetme, biriken bilgiyi kullan.
*   **Proaktif Güncelleme (Bookkeeping):** Sohbetimiz sırasında yeni bir kütüphane eklersek, bir yapılandırma (örneğin Gradle, manifest, Apache/Linux sunucu ayarları) yaparsak veya karmaşık bir algoritma tasarlarsak, bunu hafızanda tutma. Arka planda ilgili Wiki sayfasını güncelle veya yenisini oluştur.
*   **Bağlantısallık:** Oluşturduğun her markdown sayfasında Obsidian tarzı `[[cift_koseli_parantez]]` kullanarak diğer ilgili sayfalara atıfta bulun. Öksüz (hiçbir yere bağlanmayan) sayfa bırakma.

## 3. Kritik Dosyalar ve İşlevleri

Sistemin navigasyonunu sağlamak için şu iki dosyayı her zaman güncel tutacaksın:

*   **`docs/wiki/index.md`:** Tüm wiki'nin içerik haritasıdır. Kategorilere (Örn: Mimari, Veritabanı, Modeller, API'ler) ayrılmış şekilde tüm sayfaların bir listesini ve tek cümlelik özetlerini içerir. Yeni bir sayfa açtığında buraya ekle.
*   **`docs/wiki/log.md`:** Kronolojik kayıt defteridir. Yaptığın her önemli değişikliği veya eklediğin kaynağı, dosyanın en üstüne eklenecek şekilde şu formatta yaz: `## [YYYY-AA-GG] [İŞLEM_TİPİ] | Kısa Açıklama` (Örn: `## [2026-05-15] INGEST | Kullanıcı yetkilendirme şeması eklendi`).

## 4. Operasyon Komutları

Benim sana vereceğim bazı anahtar kelimeler ve senin vermen gereken tepkiler şunlardır:

### 🟢 [INGEST] (İçeri Alma ve Sentezleme)
Ben sana yeni bir kaynak, kod parçası veya fikir verdiğimde ve "Bunu Ingest et" dediğimde şu adımları izle:
1. Kaynağı oku ve analiz et.
2. `docs/wiki/` içinde yeni bir özet/konsept sayfası oluştur.
3. Mevcut wiki sayfalarını (eğer yeni bilgi eskisiyle çelişiyorsa veya onu genişletiyorsa) güncelle.
4. `index.md` dosyasına yeni sayfanın linkini ekle.
5. `log.md` dosyasına bu işlemi kaydet.

### 🔵 [QUERY] (Sorgulama ve Üretim)
Sana projeyle ilgili detaylı bir soru sorduğumda:
1. Sadece genel AI bilgilerini kullanma; önce `index.md` üzerinden ilgili wiki sayfalarını bul ve oku.
2. Wiki'deki bilgiler ışığında sentezlenmiş bir cevap ver.
3. Çıkan sonuç önemli bir mimari kararsa veya kalıcı bir değer taşıyorsa, inisiyatif alarak bu cevabı wiki'ye yeni bir sayfa olarak ekle.

### 🟠 [LINT] (Bakım ve Sağlık Kontrolü)
Sana "Wiki'yi Lint et" dediğimde:
1. Tüm `docs/wiki/` klasörünü tara.
2. Birbiriyle çelişen bilgiler, güncelliğini yitirmiş kararlar, hiçbir bağlantısı olmayan (orphan) sayfalar veya içi boş referanslar (kırık linkler) var mı kontrol et.
3. Bana bir rapor sun ve onayımı aldıktan sonra düzeltmeleri yap.

## 5. Bu Projeye Özel Notlar

Ayrıntılar wiki'dedir (`docs/wiki/index.md`); burada yalnızca her oturumda bilinmesi gerekenler var.

*   **Proje:** Namaz Takip, Flutter (Android + iOS). Git kökü ve Flutter kökü aynı klasördür (`pubspec.yaml` burada). Ayrıntı: `[[proje-ozeti]]`.
*   **Komutlar:** `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`. Windows ortam kurulumu ve emülatör komutları: `[[gelistirme-ortami]]`.
*   **Merkezi sistemler (kural):** Ekranlara emoji, `Icons.xxx` veya sabit Türkçe metin yazılmaz. İkonlar `lib/core/icons/app_icons.dart`, metinler `lib/core/strings/` altındadır; `test/central_system_test.dart` bunu denetler. Ayrıntı: `[[ikon-sistemi]]`, `[[metin-sistemi]]`.
*   **Doğrulama:** Bir değişiklikten sonra `flutter analyze` temiz olmalı ve `flutter test` geçmeli. Bildirim, konum ve arayüz davranışı emülatörde veya cihazda doğrulanmadan "çalışıyor" denmez. Ayrıntı: `[[test-stratejisi]]`, `[[emulator-test-notlari]]`.
*   **Dil ve ton:** Wiki sayfaları, commit mesajları ve kod yorumları normal, tam cümlelerle yazılır. Kullanıcıya görünen metinler Türkçedir.
*   **Commit:** Kullanıcı istemeden commit veya push yapılmaz. Wiki değişiklikleri de kodla birlikte aynı commit'e girebilir.
