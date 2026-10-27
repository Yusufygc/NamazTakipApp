import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/dhikr.dart';
import '../domain/dhikr_extractor.dart';
import '../domain/prayer.dart';

/// Sosyal medya (Instagram, TikTok, YouTube Shorts vb.) paylaşım niyetlerini
/// (Intent.ACTION_SEND) dinleyen, paylaşılan bağlantıların meta açıklamalarını
/// kazıyan ve isteğe bağlı Gemini AI ile zenginleştiren platform servisi.
class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  static const MethodChannel _channel = MethodChannel(
    'com.namaztakip.app/share',
  );

  final StreamController<String> _sharedController =
      StreamController<String>.broadcast();

  bool _initialized = false;

  /// Uygulama açıkken gelen paylaşımlar.
  Stream<String> get sharedTexts => _sharedController.stream;

  void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSharedText') {
        final text = (call.arguments as String?)?.trim();
        if (text != null && text.isNotEmpty) {
          _sharedController.add(text);
        }
      }
    });
  }

  /// Uygulama kapalıyken "Paylaş -> Namaz Takip" ile başlatıldıysa ilk metni alır.
  Future<String?> takeInitialSharedText() async {
    try {
      final text = await _channel.invokeMethod<String>('takeInitialSharedText');
      final trimmed = text?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    } catch (e) {
      debugPrint('[ShareService] takeInitialSharedText hata: $e');
      return null;
    }
  }

  /// Kaynak video bağlantısını dış tarayıcıda veya Instagram uygulamasında açar.
  ///
  /// Yalnızca `http` ve `https` açılır: bağlantı paylaşılan metinden veya elle
  /// yazılan alandan gelir; `file:`, `tel:`, `intent:` gibi şemalar açılmaz.
  Future<bool> openExternalUrl(String url) async {
    if (!isSafeWebUrl(url)) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('openUrl', {
        'url': url.trim(),
      });
      return ok ?? false;
    } catch (e) {
      debugPrint('[ShareService] openExternalUrl hata: $e');
      return false;
    }
  }

  /// Paylaşılan metni veya bağlantıyı kazıyıp [DhikrDraft] üretir.
  Future<DhikrDraft> analyzeSharedContent(
    String rawTextOrUrl, {
    String? geminiApiKey,
    required DhikrContent content,
  }) async {
    final url = extractFirstUrl(rawTextOrUrl);
    var combinedText = rawTextOrUrl.trim();

    String? scrapedCaption;

    if (url != null) {
      scrapedCaption = await _scrapeOpenGraphCaption(url);
      if (scrapedCaption != null && scrapedCaption.isNotEmpty) {
        combinedText = '$combinedText\n$scrapedCaption';
      }
    }

    final localDraft = extractDhikrDraft(
      combinedText,
      sourceUrl: url,
      content: content,
    );

    // Yalnızca bağlantı var ve açıklaması okunamadı: taslakta bilgi yok, yapay
    // zekaya da gönderilecek metin yok (bağlantı Google'a gönderilmez).
    if (isCaptionMissing(rawTextOrUrl, scrapedCaption: scrapedCaption)) {
      return localDraft.copyWith(captionUnavailable: true);
    }

    if (geminiApiKey != null && geminiApiKey.trim().isNotEmpty) {
      final aiDraft = await _analyzeWithGemini(
        combinedText: combinedText,
        sourceUrl: url,
        apiKey: geminiApiKey.trim(),
        fallback: localDraft,
        prompt: content.aiPromptTemplate.replaceAll(
          DhikrContent.aiTextToken,
          combinedText,
        ),
      );
      if (aiDraft != null) return aiDraft;
    }

    return localDraft;
  }

  Future<String?> _scrapeOpenGraphCaption(String url) async {
    HttpClient? client;
    try {
      final uri = Uri.parse(url);
      if (!isSafeWebUrl(url)) return null;
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5)
        ..userAgent = 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36';
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.maxRedirects = 4;
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );
      if (response.statusCode < 200 || response.statusCode >= 400) {
        return null;
      }
      // İlk 120 KB meta etiketleri için yeterlidir.
      // Yavaş sunucu (parça parça gönderen) kazımayı sonsuza uzatmasın: parçalar
      // arası ve toplam süre sınırlıdır.
      final bytes = <int>[];
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      await for (final chunk in response.timeout(const Duration(seconds: 6))) {
        bytes.addAll(chunk);
        if (bytes.length >= 120 * 1024) break;
        if (DateTime.now().isAfter(deadline)) break;
      }
      final html = utf8.decode(bytes, allowMalformed: true);
      final parts = <String>[];

      for (final prop in ['og:description', 'og:title', 'description']) {
        final content = _extractMetaContent(html, prop);
        if (content != null && content.isNotEmpty) {
          parts.add(_decodeHtmlEntities(content));
        }
      }
      return parts.join(' — ').trim();
    } catch (e) {
      debugPrint('[ShareService] URL kazıma bilgi: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  String? _extractMetaContent(String html, String propertyOrName) {
    final patterns = [
      RegExp(
        '<meta[^>]+(?:property|name)=["\']$propertyOrName["\'][^>]+content=(?:"([^"]*)"|\'([^\']*)\')',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=(?:"([^"]*)"|\'([^\']*)\')[^>]+(?:property|name)=["\']$propertyOrName["\']',
        caseSensitive: false,
      ),
    ];
    // İçerik çift tırnakla sarılıysa içindeki kesme işareti (Ya Rezzak'ın)
    // değeri kesmemelidir.
    for (final p in patterns) {
      final m = p.firstMatch(html);
      if (m != null) return (m.group(1) ?? m.group(2))?.trim();
    }
    return null;
  }

  String _decodeHtmlEntities(String input) {
    var out = input
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    out = out.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });
    out = out.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });
    return out;
  }

  Future<DhikrDraft?> _analyzeWithGemini({
    required String combinedText,
    required String? sourceUrl,
    required String apiKey,
    required DhikrDraft fallback,
    required String prompt,
  }) async {
    HttpClient? client;
    try {
      // Anahtar URL'ye değil başlığa konur; adres günlüklerde ve geçmişte
      // anahtarı açığa çıkarmaz.
      final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
      );
      client = HttpClient()..connectionTimeout = const Duration(seconds: 7);
      final req = await client.postUrl(endpoint);
      req.headers.contentType = ContentType.json;
      req.headers.set('x-goog-api-key', apiKey);

      final payload = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        },
      });
      req.add(utf8.encode(payload));
      final resp = await req.close().timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final body = await resp.transform(utf8.decoder).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;
      final content =
          (candidates.first as Map<String, dynamic>)['content']
              as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;
      final textJson = (parts.first as Map<String, dynamic>)['text'] as String?;
      if (textJson == null || textJson.isEmpty) return null;

      final item = jsonDecode(textJson) as Map<String, dynamic>;
      final prayerStr = item['prayerTime'] as String?;
      PrayerType? prayerTime = fallback.prayerTime;
      if (prayerStr != null) {
        for (final p in PrayerType.values) {
          if (p.name == prayerStr) {
            prayerTime = p;
            break;
          }
        }
      }
      return DhikrDraft(
        title: (item['title'] as String?)?.trim().isNotEmpty == true
            ? (item['title'] as String).trim()
            : fallback.title,
        arabic: (item['arabic'] as String?)?.trim().isNotEmpty == true
            ? (item['arabic'] as String).trim()
            : fallback.arabic,
        transliteration:
            (item['transliteration'] as String?)?.trim().isNotEmpty == true
            ? (item['transliteration'] as String).trim()
            : fallback.transliteration,
        meaning: (item['meaning'] as String?)?.trim().isNotEmpty == true
            ? (item['meaning'] as String).trim()
            : fallback.meaning,
        targetCount:
            sanitizeTargetCount(item['targetCount']) ?? fallback.targetCount,
        groupName: (item['groupName'] as String?)?.trim().isNotEmpty == true
            ? (item['groupName'] as String).trim()
            : fallback.groupName,
        prayerTime: prayerTime,
        sourceUrl: sourceUrl ?? fallback.sourceUrl,
        rawCaption: fallback.rawCaption,
      );
    } catch (e) {
      debugPrint('[ShareService] Gemini analiz bilgi: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }
}
