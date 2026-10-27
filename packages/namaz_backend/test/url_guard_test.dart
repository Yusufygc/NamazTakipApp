import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/platform/share_service.dart';
import 'package:namaz_backend/src/platform/url_guard.dart';

import 'support/test_dhikr_content.dart';

bool _public(String ip) => isPublicAddress(InternetAddress(ip));

/// Gelen istek sayısını sayan ve isteğe bağlı yönlendiren yerel sunucu.
class _Probe {
  _Probe._(this.server);
  final HttpServer server;
  int hits = 0;

  static Future<_Probe> start(
    String bindAddress, {
    String? redirectTo,
    String html = '<meta property="og:description" content="Her gun 33 defa Subhanallah">',
  }) async {
    final server = await HttpServer.bind(InternetAddress(bindAddress), 0);
    final probe = _Probe._(server);
    server.listen((request) {
      probe.hits++;
      final response = request.response;
      if (redirectTo != null) {
        response
          ..statusCode = HttpStatus.found
          ..headers.set(HttpHeaders.locationHeader, redirectTo);
      } else {
        response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..add(utf8.encode(html));
      }
      response.close();
    });
    return probe;
  }

  String url(String host) => 'http://$host:${server.port}/x';
  Future<void> stop() => server.close(force: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // flutter_test varsayılan olarak her HTTP isteğini 400 ile reddeder.
    HttpOverrides.global = null;
  });

  tearDown(() {
    ShareService.addressPolicy = isPublicAddress;
    ShareService.allowInsecureHttp = false;
  });

  group('isPublicAddress', () {
    test('iç ve özel IPv4 blokları reddedilir', () {
      for (final ip in [
        '0.0.0.0',
        '10.0.0.1',
        '100.64.0.1',
        '127.0.0.1',
        '127.255.255.254',
        '169.254.169.254', // bulut metadata
        '172.16.0.1',
        '172.31.255.255',
        '192.168.1.10',
        '192.0.0.1',
        '198.18.0.1',
        '224.0.0.1',
        '255.255.255.255',
      ]) {
        expect(_public(ip), isFalse, reason: ip);
      }
    });

    test('genel IPv4 adresleri kabul edilir', () {
      for (final ip in ['8.8.8.8', '1.1.1.1', '93.184.216.34', '172.15.0.1', '172.32.0.1', '100.63.0.1', '100.128.0.1']) {
        expect(_public(ip), isTrue, reason: ip);
      }
    });

    test('iç IPv6 blokları ve gömülü iç IPv4 reddedilir', () {
      for (final ip in [
        '::',
        '::1',
        'fe80::1',
        'fc00::1',
        'fd12:3456::1',
        'ff02::1',
        '2001:db8::1',
        '::ffff:127.0.0.1',
        '::ffff:192.168.0.1',
        '::ffff:169.254.169.254',
        '64:ff9b::7f00:1', // NAT64 ile 127.0.0.1
        '2002:7f00:1::', // 6to4 ile 127.0.0.1
      ]) {
        expect(_public(ip), isFalse, reason: ip);
      }
    });

    test('genel IPv6 ve gömülü genel IPv4 kabul edilir', () {
      for (final ip in ['2606:4700:4700::1111', '2a00:1450:4001::200e', '::ffff:8.8.8.8']) {
        expect(_public(ip), isTrue, reason: ip);
      }
    });
  });

  group('kazıma SSRF koruması', () {
    test('loopback hedefine hiç istek atılmaz', () async {
      final target = await _Probe.start('127.0.0.1');
      addTearDown(target.stop);

      final draft = await ShareService.instance.analyzeSharedContent(
        target.url('127.0.0.1'),
        content: testDhikrContent,
      );
      expect(target.hits, 0);
      expect(draft.captionUnavailable, isTrue);
    });

    test('localhost adı loopback adresine çözülür ve engellenir', () async {
      final target = await _Probe.start('127.0.0.1');
      addTearDown(target.stop);

      final draft = await ShareService.instance.analyzeSharedContent(
        target.url('localhost'),
        content: testDhikrContent,
      );
      expect(target.hits, 0);
      expect(draft.captionUnavailable, isTrue);
    });

    test('özel ağ IP literali engellenir', () async {
      final draft = await ShareService.instance.analyzeSharedContent(
        'http://192.168.0.1/admin',
        content: testDhikrContent,
      );
      expect(draft.captionUnavailable, isTrue);
      final metadata = await ShareService.instance.analyzeSharedContent(
        'https://169.254.169.254/latest/meta-data/',
        content: testDhikrContent,
      );
      expect(metadata.captionUnavailable, isTrue);
    });

    test('izinli adresten iç adrese yönlendirme izlenmez', () async {
      final inner = await _Probe.start('127.0.0.2');
      final outer = await _Probe.start(
        '127.0.0.1',
        redirectTo: inner.url('127.0.0.2'),
      );
      addTearDown(() async {
        await inner.stop();
        await outer.stop();
      });
      // Yalnızca 127.0.0.1 "genel" sayılır; 127.0.0.2 iç adres gibi davranır.
      ShareService.addressPolicy = (a) => a.address == '127.0.0.1';
      ShareService.allowInsecureHttp = true;

      final draft = await ShareService.instance.analyzeSharedContent(
        outer.url('127.0.0.1'),
        content: testDhikrContent,
      );
      expect(outer.hits, 1);
      expect(inner.hits, 0);
      expect(draft.captionUnavailable, isTrue);
    });

    test('izinli adresler arasındaki yönlendirme izlenir', () async {
      final last = await _Probe.start('127.0.0.1');
      final first = await _Probe.start(
        '127.0.0.1',
        redirectTo: last.url('127.0.0.1'),
      );
      addTearDown(() async {
        await last.stop();
        await first.stop();
      });
      ShareService.addressPolicy = (_) => true;
      ShareService.allowInsecureHttp = true;

      final draft = await ShareService.instance.analyzeSharedContent(
        first.url('127.0.0.1'),
        content: testDhikrContent,
      );
      expect(last.hits, 1);
      expect(draft.captionUnavailable, isFalse);
      expect(draft.targetCount, 33);
    });

    test('sonsuz yönlendirme döngüsü sınırlanır', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var hits = 0;
      server.listen((request) {
        hits++;
        request.response
          ..statusCode = HttpStatus.found
          ..headers.set(HttpHeaders.locationHeader, '/${hits + 1}')
          ..close();
      });
      addTearDown(() => server.close(force: true));
      ShareService.addressPolicy = (_) => true;
      ShareService.allowInsecureHttp = true;

      final draft = await ShareService.instance.analyzeSharedContent(
        'http://127.0.0.1:${server.port}/1',
        content: testDhikrContent,
      );
      expect(hits, lessThanOrEqualTo(5));
      expect(draft.captionUnavailable, isTrue);
    });
  });
}
