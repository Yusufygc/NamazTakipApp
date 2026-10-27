import 'package:namaz_backend/namaz_backend.dart';

/// Backend testleri için küçük zikir içeriği: gerçek katalog ön yüzdedir
/// (`lib/core/content/dhikr_catalog.dart`), backend onu bilmez.
const DhikrContent testDhikrContent = DhikrContent(
  catalog: [
    DhikrCatalogEntry(
      title: 'Sübhanallah',
      arabic: 'سُبْحَانَ اللّٰهِ',
      transliteration: 'Sübhânallâh',
      meaning: 'Allah her türlü eksiklikten münezzehtir.',
      defaultCount: 33,
      groupName: DhikrGroups.prayerTesbihat,
      prayerTime: PrayerType.fajr,
      keywords: ['subhanallah', 'sübhanallah'],
    ),
    DhikrCatalogEntry(
      title: 'Yunus Peygamber Duası (Lâ İlâhe İllâ Ente)',
      arabic: 'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'Lâ ilâhe illâ ente sübhâneke innî küntü minez-zâlimîn',
      meaning: 'Senden başka ilah yoktur, Seni tenzih ederim.',
      defaultCount: 41,
      groupName: DhikrGroups.sifa,
      keywords: ['la ilahe illa ente', 'inne kuntu minez zalimin'],
    ),
    DhikrCatalogEntry(
      title: 'Yâ Rezzâk',
      arabic: 'يَا رَزَّاقُ',
      transliteration: 'Yâ Rezzâk',
      meaning: 'Bütün mahlukatın maddi ve manevi rızkını bolca veren.',
      defaultCount: 308,
      groupName: DhikrGroups.rizik,
      prayerTime: PrayerType.fajr,
      keywords: ['ya rezzak', 'rezzak'],
    ),
  ],
  starterTitles: ['Sübhanallah', 'Yâ Rezzâk'],
  fallbackTitle: 'Paylaşılan Zikir',
  fallbackMeaning: 'Paylaşılan videodan kaydedilen zikir ve tesbihat.',
  aiPromptTemplate: 'Metin: {text}',
);

/// Widget metinleri (backend testleri için sahte).
class TestWidgetTexts implements HomeWidgetTexts {
  const TestWidgetTexts();

  @override
  String prayerLabel(PrayerType prayer) => switch (prayer) {
    PrayerType.fajr => 'Sabah',
    PrayerType.dhuhr => 'Öğle',
    PrayerType.asr => 'İkindi',
    PrayerType.maghrib => 'Akşam',
    PrayerType.isha => 'Yatsı',
  };

  @override
  String get sunriseLabel => 'Güneş';

  @override
  String get nextTag => 'SIRADAKİ';

  @override
  String header(String city) => 'Namaz Takip • $city';

  @override
  String doneBadge(int done) => '$done / 5 Eda';
}
