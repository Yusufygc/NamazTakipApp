import 'prayer.dart';

/// Varsayılan zikir grupları. Kullanıcı ayrıca kendi grup adını da yazabilir.
abstract final class DhikrGroups {
  static const String esma = 'Esmaül Hüsna';
  static const String morningEvening = 'Sabah & Akşam';
  static const String rizik = 'Rızık & Bereket';
  static const String sifa = 'Şifa & Huzur';
  static const String prayerTesbihat = 'Namaz Tesbihatı';
  static const String general = 'Genel Zikirler';

  static const List<String> defaults = [
    esma,
    morningEvening,
    rizik,
    sifa,
    prayerTesbihat,
    general,
  ];
}

/// Kullanıcının kaydettiği tek bir zikir veya esma kaydı.
class DhikrItem {
  const DhikrItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.targetCount,
    required this.currentCount,
    required this.totalCompleted,
    required this.groupName,
    this.prayerTime,
    this.sourceUrl,
    this.isFavorite = false,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int targetCount;
  final int currentCount;
  final int totalCompleted;
  final String groupName;
  final PrayerType? prayerTime;
  final String? sourceUrl;
  final bool isFavorite;
  final DateTime createdAt;

  double get progress =>
      targetCount <= 0 ? 0.0 : (currentCount / targetCount).clamp(0.0, 1.0);

  bool get isCompleted => targetCount > 0 && currentCount >= targetCount;

  DhikrItem copyWith({
    int? id,
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    int? targetCount,
    int? currentCount,
    int? totalCompleted,
    String? groupName,
    PrayerType? prayerTime,
    bool clearPrayerTime = false,
    String? sourceUrl,
    bool clearSourceUrl = false,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return DhikrItem(
      id: id ?? this.id,
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      groupName: groupName ?? this.groupName,
      prayerTime: clearPrayerTime ? null : (prayerTime ?? this.prayerTime),
      sourceUrl: clearSourceUrl ? null : (sourceUrl ?? this.sourceUrl),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Paylaşılan bir sosyal medya videosundan/metninden kazınan veya elle girilen
/// zikir taslağı.
class DhikrDraft {
  const DhikrDraft({
    required this.title,
    this.arabic = '',
    this.transliteration = '',
    this.meaning = '',
    this.targetCount = 33,
    this.groupName = DhikrGroups.general,
    this.prayerTime,
    this.sourceUrl,
    this.rawCaption = '',
  });

  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int targetCount;
  final String groupName;
  final PrayerType? prayerTime;
  final String? sourceUrl;
  final String rawCaption;

  DhikrDraft copyWith({
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    int? targetCount,
    String? groupName,
    PrayerType? prayerTime,
    bool clearPrayerTime = false,
    String? sourceUrl,
    String? rawCaption,
  }) {
    return DhikrDraft(
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      targetCount: targetCount ?? this.targetCount,
      groupName: groupName ?? this.groupName,
      prayerTime: clearPrayerTime ? null : (prayerTime ?? this.prayerTime),
      sourceUrl: sourceUrl ?? this.sourceUrl,
      rawCaption: rawCaption ?? this.rawCaption,
    );
  }
}
