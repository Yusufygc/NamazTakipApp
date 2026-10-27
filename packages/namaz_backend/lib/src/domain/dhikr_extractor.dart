import 'dhikr.dart';
import 'prayer.dart';

/// Paylaşılan metin veya video açıklamasından zikir bilgilerini çıkaran saf
/// (pure Dart) analiz fonksiyonu.
DhikrDraft extractDhikrDraft(
  String rawInput, {
  String? sourceUrl,
  required DhikrContent content,
}) {
  final extractedUrl = sourceUrl ?? extractFirstUrl(rawInput);
  final cleaned = cleanSocialCaption(rawInput);
  final folded = _foldTurkish(cleaned);

  // 1) Sözlükten eşleşen Esma veya zikir var mı?
  DhikrCatalogEntry? matched;
  for (final entry in content.catalog) {
    for (final keyword in entry.keywords) {
      if (folded.contains(_foldTurkish(keyword))) {
        matched = entry;
        break;
      }
    }
    if (matched != null) break;
  }

  // 2) Genel "Ya <Esma>" kalıbı yakalama (sözlükte yoksa bile)
  final customEsmaMatch = RegExp(
    r'\b(?:ya|yâ)\s+([a-zçğıöşüâîû]{3,16})(?:\s+(?:ya|yâ)\s+([a-zçğıöşüâîû]{3,16}))?\b',
    caseSensitive: false,
  ).firstMatch(cleaned);

  // 3) Hedef sayı tespiti (örn. "100 defa", "308 kere", "41 kez", "x100")
  final explicitCount = extractTargetCount(cleaned);

  // 4) Namaz vakti tespiti (örn. "sabah namazından sonra")
  final explicitPrayer = extractRecommendedPrayer(folded);

  // 5) Arapça metin bloğu varsa yakala
  final arabicMatch = RegExp(
    r'[\u0600-\u06FF][\u0600-\u06FF\s\u064B-\u065F\u0670]{2,}',
  ).firstMatch(cleaned);
  final extractedArabic = arabicMatch?.group(0)?.trim() ?? '';

  if (matched != null) {
    return DhikrDraft(
      title: matched.title,
      arabic: extractedArabic.isNotEmpty ? extractedArabic : matched.arabic,
      transliteration: matched.transliteration,
      meaning: matched.meaning,
      targetCount: explicitCount ?? matched.defaultCount,
      groupName: _inferGroup(folded, fallback: matched.groupName),
      prayerTime: explicitPrayer ?? matched.prayerTime,
      sourceUrl: extractedUrl,
      rawCaption: cleaned,
    );
  }

  if (customEsmaMatch != null) {
    final rawEsma = customEsmaMatch.group(0)!.trim();
    final formattedTitle = _titleCaseTurkish(rawEsma);
    return DhikrDraft(
      title: formattedTitle,
      arabic: extractedArabic,
      transliteration: formattedTitle,
      meaning: _extractSummaryMeaning(cleaned, content.fallbackMeaning),
      targetCount: explicitCount ?? 100,
      groupName: _inferGroup(folded, fallback: DhikrGroups.esma),
      prayerTime: explicitPrayer,
      sourceUrl: extractedUrl,
      rawCaption: cleaned,
    );
  }

  final fallbackTitle = _extractHeadlineTitle(cleaned, content.fallbackTitle);
  return DhikrDraft(
    title: fallbackTitle,
    arabic: extractedArabic,
    transliteration: fallbackTitle,
    meaning: _extractSummaryMeaning(cleaned, content.fallbackMeaning),
    targetCount: explicitCount ?? 33,
    groupName: _inferGroup(folded, fallback: DhikrGroups.general),
    prayerTime: explicitPrayer,
    sourceUrl: extractedUrl,
    rawCaption: cleaned,
  );
}

/// Metin içerisindeki ilk `http://` veya `https://` bağlantısını bulur.
String? extractFirstUrl(String text) {
  final match = RegExp(
    r'https?://[^\s"<>]+',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return null;
  var url = match.group(0)!;
  while (url.isNotEmpty && '.,;:!?) fullwidth'.contains(url[url.length - 1])) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

/// Dış kaynaktan (yapay zeka yanıtı vb.) gelen hedef sayıyı doğrular: 1..100000
/// arası bir tam sayı değilse `null`.
int? sanitizeTargetCount(Object? value) {
  if (value is! num || !value.isFinite) return null;
  final n = value.toInt();
  if (n < 1 || n > 100000) return null;
  return n;
}

/// Yalnızca `http`/`https` ve ana makine adı olan bağlantılar güvenlidir; dış
/// uygulamada açılmadan ve ağdan çekilmeden önce denetlenir.
bool isSafeWebUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return false;
  final scheme = uri.scheme.toLowerCase();
  return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
}

/// Paylaşımda bağlantı var ama zikir bilgisi taşıyan hiçbir metin yoksa `true`:
/// kullanıcı metni (bağlantı çıkarıldıktan sonra) boştur ve bağlantıdan açıklama
/// da okunamamıştır.
bool isCaptionMissing(String rawInput, {String? scrapedCaption}) {
  if (extractFirstUrl(rawInput) == null) return false;
  final hasUserText = cleanSocialCaption(rawInput).isNotEmpty;
  final hasScraped = scrapedCaption != null && scrapedCaption.trim().isNotEmpty;
  return !hasUserText && !hasScraped;
}

/// Instagram/TikTok/YouTube paylaşım metinlerindeki kalıp sarmalayıcıları ve
/// URL'leri temizler.
String cleanSocialCaption(String raw) {
  var text = raw.replaceAll(RegExp(r'https?://[^\s"<>]+'), ' ').trim();

  final igMatch = RegExp(
    r'on Instagram:\s*["“”]([\s\S]+?)["“”]\s*$',
    caseSensitive: false,
  ).firstMatch(text);
  if (igMatch != null) {
    text = igMatch.group(1)!.trim();
  }

  text = text.replaceAllMapped(
    RegExp(r'#([a-zA-Z0-9_çğıöşüÇĞİÖŞÜ]+)'),
    (m) => m.group(1)!,
  );

  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

/// Metin içerisindeki "100 defa", "308 kere", "41 kez", "33'er", "günde 70"
/// gibi sayı ifadelerini yakalar.
int? extractTargetCount(String text) {
  final patterns = [
    RegExp(
      r'\b(\d{1,5})\s*(?:defa|kere|kez|adet|tekrar|tesbih)\b',
      caseSensitive: false,
    ),
    RegExp(r"\b(\d{1,5})\s*['’]?\s*(?:er|ar|şer|şar)\b", caseSensitive: false),
    RegExp(
      r'\b(?:günde|her\s+gün|namazdan\s+sonra)\s+(\d{1,5})\b',
      caseSensitive: false,
    ),
    RegExp(r'\bx\s*(\d{1,5})\b', caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(text);
    if (match != null) {
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > 0 && value <= 100000) {
        return value;
      }
    }
  }
  return null;
}

/// Metinden tavsiye edilen namaz vaktini çıkarır.
PrayerType? extractRecommendedPrayer(String foldedText) {
  if (foldedText.contains('sabah namaz') ||
      foldedText.contains('imsak') ||
      foldedText.contains('fecr')) {
    return PrayerType.fajr;
  }
  if (foldedText.contains('ogle namaz') || foldedText.contains('zuhr')) {
    return PrayerType.dhuhr;
  }
  if (foldedText.contains('ikindi namaz') || foldedText.contains('asr')) {
    return PrayerType.asr;
  }
  if (foldedText.contains('aksam namaz') || foldedText.contains('magrib')) {
    return PrayerType.maghrib;
  }
  if (foldedText.contains('yatsi namaz') ||
      foldedText.contains('gece yatmadan') ||
      foldedText.contains('uyumadan once')) {
    return PrayerType.isha;
  }
  return null;
}

String _inferGroup(String foldedText, {required String fallback}) {
  if (foldedText.contains('rizik') ||
      foldedText.contains('bereket') ||
      foldedText.contains('borc') ||
      foldedText.contains('zenginlik')) {
    return DhikrGroups.rizik;
  }
  if (foldedText.contains('sifa') ||
      foldedText.contains('hastalik') ||
      foldedText.contains('huzur') ||
      foldedText.contains('sikinti') ||
      foldedText.contains('ferahlik')) {
    return DhikrGroups.sifa;
  }
  if (foldedText.contains('namaz tesbihat') ||
      foldedText.contains('namazdan sonra') ||
      foldedText.contains('farz namaz')) {
    return DhikrGroups.prayerTesbihat;
  }
  if (foldedText.contains('sabah aksam') ||
      foldedText.contains('her sabah') ||
      foldedText.contains('her aksam')) {
    return DhikrGroups.morningEvening;
  }
  if (foldedText.contains('esmaul husna') || foldedText.contains('esma')) {
    return DhikrGroups.esma;
  }
  return fallback;
}

String _foldTurkish(String input) {
  return input
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('i̇', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('û', 'u');
}

String _titleCaseTurkish(String input) {
  final words = input.trim().split(RegExp(r'\s+'));
  return words
      .map((w) {
        if (w.isEmpty) return w;
        final first = w[0]
            .replaceAll('i', 'İ')
            .replaceAll('ı', 'I')
            .replaceAll('ç', 'Ç')
            .replaceAll('ğ', 'Ğ')
            .replaceAll('ö', 'Ö')
            .replaceAll('ş', 'Ş')
            .replaceAll('ü', 'Ü')
            .toUpperCase();
        return '$first${w.substring(1).toLowerCase()}';
      })
      .join(' ');
}

String _extractHeadlineTitle(String cleaned, String fallback) {
  if (cleaned.isEmpty) return fallback;
  final firstSentence = cleaned
      .split(RegExp(r'[.!\n|•—–-]'))
      .map((s) => s.trim())
      .firstWhere((s) => s.length >= 3, orElse: () => cleaned);
  if (firstSentence.length <= 36) return firstSentence;
  return '${firstSentence.substring(0, 34).trim()}…';
}

String _extractSummaryMeaning(String cleaned, String fallback) {
  if (cleaned.isEmpty) {
    return fallback;
  }
  if (cleaned.length <= 180) return cleaned;
  return '${cleaned.substring(0, 177).trim()}...';
}
