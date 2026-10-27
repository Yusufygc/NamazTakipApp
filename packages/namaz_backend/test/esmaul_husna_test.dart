import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';

/// 99 Esmaül Hüsna: (başlık, geleneksel ebced değeri). Sıra Diyanet/ilmihal
/// sırasıdır (Rahmân .. Sabûr). Değerler Türkçe kaynaklarda yaygın olandır; dinî
/// kaynakla doğrulanmamıştır (bkz. docs/wiki/dini-icerik-onayi.md).
const _expected = <(String, int)>[
  ('Yâ Rahmân', 298),
  ('Yâ Rahîm', 258),
  ('Yâ Melik', 90),
  ('Yâ Kuddûs', 170),
  ('Yâ Selâm', 131),
  ('Yâ Mü\'min', 137),
  ('Yâ Müheymin', 145),
  ('Yâ Azîz', 94),
  ('Yâ Cebbâr', 206),
  ('Yâ Mütekebbir', 662),
  ('Yâ Hâlık', 731),
  ('Yâ Bâri', 214),
  ('Yâ Musavvir', 336),
  ('Yâ Gaffâr', 1281),
  ('Yâ Kahhâr', 306),
  ('Yâ Vehhâb', 14),
  ('Yâ Rezzâk', 308),
  ('Yâ Fettâh', 489),
  ('Yâ Alîm', 150),
  ('Yâ Kâbıd', 903),
  ('Yâ Bâsıt', 72),
  ('Yâ Hâfıd', 1481),
  ('Yâ Râfi', 351),
  ('Yâ Mu\'izz', 117),
  ('Yâ Müzill', 770),
  ('Yâ Semî', 180),
  ('Yâ Basîr', 302),
  ('Yâ Hakem', 68),
  ('Yâ Adl', 104),
  ('Yâ Latîf', 129),
  ('Yâ Habîr', 812),
  ('Yâ Halîm', 88),
  ('Yâ Azîm', 1020),
  ('Yâ Gafûr', 1286),
  ('Yâ Şekûr', 526),
  ('Yâ Aliyy', 110),
  ('Yâ Kebîr', 232),
  ('Yâ Hafîz', 998),
  ('Yâ Mukît', 550),
  ('Yâ Hasîb', 80),
  ('Yâ Celîl', 73),
  ('Yâ Kerîm', 270),
  ('Yâ Rakîb', 312),
  ('Yâ Mucîb', 55),
  ('Yâ Vâsi', 137),
  ('Yâ Hakîm', 78),
  ('Yâ Vedûd', 20),
  ('Yâ Mecîd', 57),
  ('Yâ Bâis', 573),
  ('Yâ Şehîd', 319),
  ('Yâ Hakk', 108),
  ('Yâ Vekîl', 66),
  ('Yâ Kaviyy', 116),
  ('Yâ Metîn', 500),
  ('Yâ Veliyy', 46),
  ('Yâ Hamîd', 62),
  ('Yâ Muhsî', 148),
  ('Yâ Mübdi', 56),
  ('Yâ Mu\'îd', 124),
  ('Yâ Muhyî', 68),
  ('Yâ Mümît', 490),
  ('Yâ Hayy', 18),
  ('Yâ Kayyûm', 156),
  ('Yâ Vâcid', 14),
  ('Yâ Mâcid', 48),
  ('Yâ Vâhid', 19),
  ('Yâ Ehad', 13),
  ('Yâ Samed', 134),
  ('Yâ Kâdir', 305),
  ('Yâ Muktedir', 744),
  ('Yâ Mukaddim', 184),
  ('Yâ Muahhir', 846),
  ('Yâ Evvel', 37),
  ('Yâ Âhir', 801),
  ('Yâ Zâhir', 1106),
  ('Yâ Bâtın', 62),
  ('Yâ Vâlî', 47),
  ('Yâ Müteâlî', 551),
  ('Yâ Berr', 202),
  ('Yâ Tevvâb', 409),
  ('Yâ Müntekim', 630),
  ('Yâ Afüvv', 156),
  ('Yâ Raûf', 287),
  ('Yâ Mâlikü\'l-Mülk', 212),
  ('Yâ Zü\'l-Celâli ve\'l-İkrâm', 1100),
  ('Yâ Muksit', 209),
  ('Yâ Câmi', 114),
  ('Yâ Ganiyy', 1060),
  ('Yâ Mugnî', 1100),
  ('Yâ Mâni', 161),
  ('Yâ Dârr', 1001),
  ('Yâ Nâfi', 201),
  ('Yâ Nûr', 256),
  ('Yâ Hâdî', 20),
  ('Yâ Bedî', 86),
  ('Yâ Bâkî', 113),
  ('Yâ Vârîs', 707),
  ('Yâ Reşîd', 514),
  ('Yâ Sabûr', 298),
];

const _abjad = <String, int>{
  'ا': 1,
  'أ': 1,
  'إ': 1,
  'آ': 1,
  'ب': 2,
  'ج': 3,
  'د': 4,
  'ه': 5,
  'و': 6,
  'ؤ': 6,
  'ز': 7,
  'ح': 8,
  'ط': 9,
  'ي': 10,
  'ى': 10,
  'ئ': 10,
  'ك': 20,
  'ل': 30,
  'م': 40,
  'ن': 50,
  'س': 60,
  'ع': 70,
  'ف': 80,
  'ص': 90,
  'ق': 100,
  'ر': 200,
  'ش': 300,
  'ت': 400,
  'ث': 500,
  'خ': 600,
  'ذ': 700,
  'ض': 800,
  'ظ': 900,
  'غ': 1000,
};

int _ebced(String arabic) =>
    arabic.split('').fold(0, (sum, c) => sum + (_abjad[c] ?? 0));

DhikrCatalogEntry _entry(String title) =>
    kEsmaAndDhikrCatalog.firstWhere((e) => e.title == title);

void main() {
  group('Esmaül Hüsna kataloğu (99 isim)', () {
    final names = kEsmaAndDhikrCatalog
        .where((e) => _expected.any((x) => x.$1 == e.title))
        .toList();

    test('Lafz-ı Celâl ve tam 99 isim vardır, sıra korunur', () {
      expect(kEsmaAndDhikrCatalog.first.title, 'Yâ Allah');
      expect(_expected, hasLength(99));
      expect(names, hasLength(99));
      expect(
        names.map((e) => e.title).toList(),
        _expected.map((x) => x.$1).toList(),
      );
      expect(names.first.title, 'Yâ Rahmân');
      expect(names.last.title, 'Yâ Sabûr');
    });

    test('başlıklar benzersizdir ve 99 dışı yalnızca Allah ve Şâfî', () {
      final titles = kEsmaAndDhikrCatalog.map((e) => e.title).toList();
      expect(titles.toSet(), hasLength(titles.length));
      final extra = titles.where((t) => !_expected.any((x) => x.$1 == t));
      expect(extra.toSet(), {'Yâ Allah', 'Yâ Şâfî'});
    });

    test('varsayılan adet geleneksel ebced değeridir', () {
      for (final x in _expected) {
        expect(_entry(x.$1).defaultCount, x.$2, reason: x.$1);
      }
    });

    test('ebced Arapça yazıdan da hesaplanınca tutar (3 hemze istisnası)', () {
      // Hemze yazımında gelenek ile harf toplamı ayrışır; bunlar belgelidir.
      const hamzaConvention = {"Yâ Mü'min", 'Yâ Bâri', 'Yâ Raûf'};
      for (final x in _expected) {
        if (hamzaConvention.contains(x.$1)) continue;
        var arabic = _entry(x.$1).arabic.replaceFirst('يَا ', '');
        // "Zü'l-Celâl" geleneksel hesapta yalın hâl (ذو) ile hesaplanır.
        arabic = arabic.replaceFirst('ذَا', 'ذُو');
        expect(_ebced(arabic), x.$2, reason: x.$1);
      }
    });

    test('her kayıtta Arapça, okunuş, anlam ve anahtar kelime doludur', () {
      for (final e in kEsmaAndDhikrCatalog) {
        expect(e.arabic, isNotEmpty, reason: e.title);
        expect(e.transliteration, isNotEmpty, reason: e.title);
        expect(e.meaning.trim(), isNotEmpty, reason: e.title);
        expect(e.keywords, isNotEmpty, reason: e.title);
        expect(e.defaultCount, greaterThan(0), reason: e.title);
      }
    });

    test(
      'her ismin kendi anahtar kelimesi paylaşılan metinde o ismi bulur',
      () {
        // Başka bir girdinin anahtar kelimesi bir ismi gölgelememeli.
        for (final x in _expected) {
          final e = _entry(x.$1);
          final draft = extractDhikrDraft('${e.keywords.first} 100 defa');
          expect(draft.title, e.title, reason: e.keywords.first);
        }
      },
    );

    test('yeni eklenen isimler paylaşım metninden ayıklanır', () {
      final draft = extractDhikrDraft(
        'Sabah namazından sonra 66 defa Ya Kabid',
      );
      expect(draft.title, 'Yâ Kâbıd');
      expect(draft.targetCount, 66);
      expect(draft.prayerTime, PrayerType.fajr);
    });
  });
}
