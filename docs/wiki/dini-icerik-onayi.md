# Dinî İçerik Onayı

Uygulamada dinî bilgi taşıyan veriler (esma, zikir metinleri, kerahat süreleri, kandil kuralları) **dinî kaynaktan onay görmemiştir.** Bu sayfa neyin makineyle doğrulandığını, neyin onay beklediğini ve nasıl onaylanacağını tutar. Kod yazan yapay zeka dinî hüküm veremez; karar kullanıcıya (veya danıştığı dinî kaynağa) aittir. Onaylanan madde buraya tarih ve onaylayan ile işlenir, onaylanmayan madde uygulamadan çıkarılır veya öneri olarak işaretlenir.

## Esmaül Hüsna kataloğu (99 isim)

Kaynak: `packages/namaz_backend/lib/src/domain/esma_catalog.dart` (`kEsmaAndDhikrCatalog`). Yapı: Lafz-ı Celâl ("Yâ Allah", 99'a sayılmaz), ardından Diyanet/ilmihal sırasıyla 99 isim (Rahmân ile başlar, Sabûr ile biter), en sonda 99'a girmeyen "Yâ Şâfî". Her kayıtta Arapça yazı, okunuş, kısa anlam, varsayılan adet, grup, anahtar kelimeler bulunur.

### Makineyle doğrulananlar (`esmaul_husna_test.dart`, 7 test)

- Tam 99 isim, sıra, benzersiz başlıklar; 99 dışında yalnızca Allah ve Şâfî.
- Varsayılan adet, Türkçe kaynaklarda yaygın **geleneksel ebced** tablosuyla birebir aynı.
- Ebced, Arapça yazıdan harf harf yeniden hesaplanınca 99 ismin 96'sında aynı çıkıyor. Üç istisna hemze yazımından gelen gelenek farkı: Mü'min (137 geleneksel, harf toplamı 136), Bâri (214, 213), Raûf (287, 292). Zü'l-Celâl'in 1100'ü geleneksel olarak yalın hâl (ذو) ile hesaplanır; Arapça kayıt çağrı hâlinde (ذا) yazılıdır.
- Her ismin kendi anahtar kelimesi paylaşılan metinde o ismi buluyor; başka bir girdi onu gölgelemiyor.
- Bu doğrulama **iç tutarlılıktır**: Arapça yazı, sayı ve sıra birbiriyle uyuşuyor. Yazının ve değerlerin doğru kaynakla örtüştüğünü kanıtlamaz; ebced referans değerleri de bu çalışmada bilinen yaygın tablodan alındı, dış bir kaynaktan satır satır doğrulanmadı.

### Onay bekleyenler

1. **Arapça yazım ve harekeler** (99 isim). Kontrol listesi: harekeler, "Yâ" öneki, Mâlikü'l-Mülk ve Zü'l-Celâli ve'l-İkrâm yazımı.
2. **Türkçe okunuş ve kısa anlamlar.** Yeni 60 anlam (eklenen ve birleşikten ayrılan isimler) genel bilgiyle yazıldı, kaynak gösterilmedi; korunan 39 kayıttaki anlamlar önceki yazardan kaldı. Anlamlar tek cümlelik kısa karşılıklardır, ayrıntılı tefsir değildir.
3. **Sayım kuralı:** "Allah" lafzı 99'a dahil değil (Rahmân'dan Sabûr'a 99). Bazı listeler Allah'ı sayıp farklı bir ismi çıkarır.
4. **Varsayılan adet = ebced.** Gelenekte ismin ebced değeri kadar zikredilir; bu bir farz veya sünnet değil, yaygın uygulamadır. Kullanıcı adedi değiştirebilir.
5. **Grup ve vakit eşlemeleri** (korunan 39 kayıtta: örn. Gaffâr "Sabah & Akşam", Rezzâk "Rızık & Bereket", Rahmân Sabah). Bunlar önceki yazarın tercihleridir; yeni isimler tarafsız "Esmaül Hüsna" grubunda ve vakitsiz eklendi.
6. **Fazilet iddiası yok:** Katalogda kaynaklı fazilet metni bulunmuyor. Kaynaksız fazilet ifadesi riskli olduğu için arayüzdeki "Esmaül Hüsna ve Faziletleri" başlığı "Esmaül Hüsna (99 İsim)", arama ipucundaki "fazilet" ve alan adı "Anlamı ve Fazileti" ("Anlamı ve Notlar") olarak değiştirildi; Gemini istemi artık fazilet veya sevap iddiası üretmemesini söylüyor.

## Zikir ve tesbihat metinleri

`kDhikrCatalog` (`domain/dhikr_extractor.dart`) ve `kClassicTesbihatSteps` (`domain/esma_catalog.dart`): Arapça metinler, okunuşlar, anlamlar ve adetler (33'er, 100, "Hasbünallah 450", "Yunus duası 41" gibi) onay bekler. Kataloğa kaynaklı olmayan adet eklenmemesi önerilir.

## Kerahat süreleri

`detectKerahat` (`domain/islamic_calendar.dart`) şu süreleri kullanır: güneş doğuşundan sonra 45 dk, öğleden önce 30 dk (istiva), akşamdan önce 40 dk. 2026-10-27'de yapılan taramada kaynaklar **birbirini tutmadı** ve resmî Diyanet sayfası bulunamadı:

| Vakit | Koddaki | Taramada görülen aralıklar |
|---|---|---|
| Güneş doğuşu sonrası | 45 dk | 45-50 dk (çoğu kaynak); bir kaynak 15-20 dk |
| İstiva (öğle öncesi) | 30 dk | ~10 dk (bir kaynak); 30 dk |
| Gurub (akşam öncesi) | 40 dk | 30 dk; 40-50 dk |

Mezhebe göre de farklılaşıyor. Karar için Diyanet İlmihali veya `namazvakti.diyanet.gov.tr` kullanılması ve süreler bu sayfaya kaynakla yazılması önerilir; o zamana kadar uyarı **bilgilendirme** niteliğindedir.

## Kandil ve bayram günleri

Hicri ay başları Diyanet'e dayanan yayınlarla örtüşecek şekilde tabloya yazıldı ve testlendi; kandil kuralları (Regaip dahil) Diyanet tarihleriyle test ediliyor. Kaynak resmî tablo değil: [[hicri-takvim]].

## Onay süreci

1. Bu sayfadaki "Onay bekleyenler" maddelerini dinî kaynağa (Diyanet İlmihali, ilgili müftülük veya güvendiğiniz bir hoca) gösterin.
2. Düzeltmeleri `esma_catalog.dart` ve `islamic_calendar.dart` içinde yapın; `esmaul_husna_test.dart` sayı, sıra ve ebced tutarlılığını yeniden denetler.
3. Onaylanan maddeyi "tarih, onaylayan, kaynak" ile buraya ekleyin ve [[bilinen-sorunlar]] satırını güncelleyin.

## İlgili sayfalar

[[zikir-paylasim]] · [[hicri-takvim]] · [[ui-ekranlar]] · [[bilinen-sorunlar]] · [[guvenlik-ve-kalite-analizi]]
