import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_backend/src/platform/share_service.dart';

/// `/` yoluna verilen HTML'i döndüren yerel sunucu; sayfa başına istenen
/// yanıt `pages` içinde tanımlanır.
Future<HttpServer> _serve(Map<String, String> pages) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) {
    final body = pages[request.uri.path];
    request.response
      ..statusCode = body == null ? 404 : 200
      ..headers.contentType = ContentType.html
      ..add(utf8.encode(body ?? ''))
      ..close();
  });
  return server;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpServer server;
  late String base;

  setUpAll(() async {
    // flutter_test varsayılan olarak her HTTP isteğini 400 ile reddeder.
    HttpOverrides.global = null;
    server = await _serve({
      // Instagram gibi: büyük sayfa, hiç og/description etiketi yok.
      '/giris-duvari': '<html><head><title>Instagram</title>'
          '<meta name="viewport" content="width=device-width"></head></html>',
      // Çift tırnaklı içerikte kesme işareti (Ya Rezzak'ın) değeri kesmemeli.
      '/aciklama':
          '<html><head><meta property="og:description" content="Sabah namazından sonra 100 defa Ya Rezzak\'ın zikrini çekin"></head></html>',
      // Tek tırnaklı içerik ve ters öznitelik sırası.
      '/tek-tirnak':
          "<html><head><meta content='Her gün 33 defa Sübhanallah' property='og:description'></head></html>",
    });
    base = 'http://127.0.0.1:${server.port}';
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  group('isCaptionMissing', () {
    test('yalnızca bağlantı ve okunamayan açıklama: eksik', () {
      expect(
        isCaptionMissing('https://www.instagram.com/p/abc/?img_index=1'),
        isTrue,
      );
      expect(
        isCaptionMissing('https://x.example/p/abc', scrapedCaption: '  '),
        isTrue,
      );
    });

    test('kullanıcı metni veya kazınan açıklama varsa eksik değil', () {
      expect(
        isCaptionMissing('100 defa Ya Rezzak https://x.example/p/abc'),
        isFalse,
      );
      expect(
        isCaptionMissing(
          'https://x.example/p/abc',
          scrapedCaption: 'Sabah namazından sonra 100 defa',
        ),
        isFalse,
      );
    });

    test('bağlantı yoksa eksik sayılmaz (düz metin paylaşımı)', () {
      expect(isCaptionMissing('Ya Rezzak 100 defa'), isFalse);
      expect(isCaptionMissing(''), isFalse);
    });
  });

  group('güvenli bağlantı denetimi', () {
    test('yalnızca http ve https, ana makine adıyla', () {
      expect(isSafeWebUrl('https://www.instagram.com/p/abc/'), isTrue);
      expect(isSafeWebUrl('  http://example.com/x  '), isTrue);
      for (final bad in [
        'file:///sdcard/x',
        'tel:*2767*3855#',
        'intent://scan/#Intent;scheme=zxing;end',
        'javascript:alert(1)',
        'content://x',
        'https://',
        'www.instagram.com/p/abc',
        '',
      ]) {
        expect(isSafeWebUrl(bad), isFalse, reason: bad);
      }
    });

    test('openExternalUrl güvenli olmayan şemayı kanala hiç göndermez',
        () async {
      final opened = <String>[];
      const channel = MethodChannel('com.namaztakip.app/share');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'openUrl') {
          opened.add((call.arguments as Map)['url'] as String);
          return true;
        }
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));

      expect(await ShareService.instance.openExternalUrl('tel:112'), isFalse);
      expect(
        await ShareService.instance.openExternalUrl('file:///etc/hosts'),
        isFalse,
      );
      expect(opened, isEmpty);

      expect(
        await ShareService.instance
            .openExternalUrl(' https://www.instagram.com/p/abc/ '),
        isTrue,
      );
      expect(opened, ['https://www.instagram.com/p/abc/']);
    });
  });

  group('sanitizeTargetCount (yapay zeka yanıtı)', () {
    test('geçerli sayıyı tam sayı yapar', () {
      expect(sanitizeTargetCount(33), 33);
      expect(sanitizeTargetCount(100.0), 100);
      expect(sanitizeTargetCount(100000), 100000);
    });

    test('sıfır, negatif, çok büyük ve sayı olmayan değerleri reddeder', () {
      expect(sanitizeTargetCount(0), isNull);
      expect(sanitizeTargetCount(-5), isNull);
      expect(sanitizeTargetCount(100001), isNull);
      expect(sanitizeTargetCount(1e15), isNull);
      expect(sanitizeTargetCount(double.nan), isNull);
      expect(sanitizeTargetCount(double.infinity), isNull);
      expect(sanitizeTargetCount('100'), isNull);
      expect(sanitizeTargetCount(null), isNull);
    });
  });

  group('ShareService.analyzeSharedContent (yerel sunucu)', () {
    test('açıklaması olmayan sayfa: captionUnavailable true, zikir yok', () async {
      final draft = await ShareService.instance
          .analyzeSharedContent('$base/giris-duvari?img_index=1');
      expect(draft.captionUnavailable, isTrue);
      expect(draft.sourceUrl, '$base/giris-duvari?img_index=1');
      expect(draft.title, 'Paylaşılan Zikir');
    });

    test('Gemini anahtarı olsa bile açıklama yoksa istek atılmaz', () async {
      // Anahtar geçersiz; çağrı denenseydi ağ hatası/boş dönerdi. Sonuç yine
      // yerel taslak ve captionUnavailable olmalıdır.
      final draft = await ShareService.instance.analyzeSharedContent(
        '$base/giris-duvari',
        geminiApiKey: 'GECERSIZ',
      );
      expect(draft.captionUnavailable, isTrue);
    });

    test('og:description içindeki kesme işareti değeri kesmez', () async {
      final draft =
          await ShareService.instance.analyzeSharedContent('$base/aciklama');
      expect(draft.captionUnavailable, isFalse);
      expect(draft.title, 'Yâ Rezzâk');
      expect(draft.targetCount, 100);
      expect(draft.prayerTime, PrayerType.fajr);
      // Kesme işaretinden sonraki kısım korunmuş olmalı.
      expect(draft.rawCaption, contains('zikrini çekin'));
    });

    test('tek tırnaklı ve ters sıralı meta etiketi okunur', () async {
      final draft =
          await ShareService.instance.analyzeSharedContent('$base/tek-tirnak');
      expect(draft.captionUnavailable, isFalse);
      expect(draft.title, 'Sübhanallah');
      expect(draft.targetCount, 33);
    });

    test('erişilemeyen bağlantı (404): captionUnavailable true', () async {
      final draft = await ShareService.instance
          .analyzeSharedContent('$base/yok-boyle-sayfa');
      expect(draft.captionUnavailable, isTrue);
    });

    test('düz metin paylaşımı ağa çıkmadan ayıklanır', () async {
      final draft = await ShareService.instance
          .analyzeSharedContent('Rızık için 100 defa Ya Rezzak');
      expect(draft.captionUnavailable, isFalse);
      expect(draft.title, 'Yâ Rezzâk');
    });
  });
}
