import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_takip/core/strings/strings.dart';

/// Ön yüz (front) ile backend arasındaki sınırı denetler.
///
/// Kural: ön yüz backend'i yalnızca `package:namaz_backend/namaz_backend.dart`
/// üzerinden, yani `NamazBackend` arayüzü ve sade modeller aracılığıyla tanır.
/// Veritabanı, konum, bildirim, vakit hesabı ve arka plan paketleri yalnızca
/// backend paketindedir.

/// Yalnızca backend'in kullanabileceği paketler.
const _backendOnlyPackages = [
  'sqflite',
  'sqflite_common_ffi',
  'path',
  'shared_preferences',
  'adhan_dart',
  'geolocator',
  'geocoding',
  'flutter_local_notifications',
  'timezone',
  'flutter_timezone',
  'workmanager',
];

final _importLine = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);

List<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

Iterable<String> _imports(File f) =>
    _importLine.allMatches(f.readAsStringSync()).map((m) => m.group(1)!);

String _norm(String path) => path.replaceAll('\\', '/');

void main() {
  group('ön yüz sınırı', () {
    test('lib/ backend iç dosyalarını (src/) içe aktarmaz', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib')) {
        for (final i in _imports(f)) {
          if (i.startsWith('package:namaz_backend/src/')) {
            offenders.add('${_norm(f.path)} → $i');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'Yalnızca package:namaz_backend/namaz_backend.dart kullanın:\n${offenders.join('\n')}');
    });

    test('lib/ depolama, konum, bildirim ve arka plan paketlerini içe aktarmaz', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib')) {
        for (final i in _imports(f)) {
          for (final pkg in _backendOnlyPackages) {
            if (i.startsWith('package:$pkg/')) {
              offenders.add('${_norm(f.path)} → $i');
            }
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'Bu paketler backend\'e aittir:\n${offenders.join('\n')}');
    });

    test('ön yüz pubspec.yaml backend-only paket bildirmez', () {
      final spec = File('pubspec.yaml').readAsStringSync();
      final declared = <String>[];
      for (final pkg in _backendOnlyPackages) {
        // Yalnızca bildirim satırı: `  paket:` (yorumlar ve alt anahtarlar hariç)
        if (RegExp('^  $pkg:', multiLine: true).hasMatch(spec)) declared.add(pkg);
      }
      expect(declared, isEmpty, reason: 'pubspec.yaml içinden kaldırın: $declared');
    });

    test('lib/ içinde backend yalnızca bir kez, barrel dosyasıyla bağlanır', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib')) {
        for (final i in _imports(f)) {
          if (i.startsWith('package:namaz_backend/') &&
              i != 'package:namaz_backend/namaz_backend.dart') {
            offenders.add('${_norm(f.path)} → $i');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('providers/ dışındaki ekran kodu backend nesnesini doğrudan çağırmaz', () {
      // Ekranlar `backendProvider`'ı yalnızca olay anlarında (izin, bildirim,
      // şehir listesi) okuyabilir; bunun dışında sağlayıcılar kullanılmalıdır.
      // Bu sayı bilinçli olarak sınırlandırılmıştır; artıyorsa bir sağlayıcı eksiktir.
      var uses = 0;
      for (final f in _dartFiles('lib/ui')) {
        uses += 'backendProvider'.allMatches(f.readAsStringSync()).length;
      }
      expect(uses, lessThanOrEqualTo(8),
          reason: 'Ekranlarda çok fazla doğrudan backend çağrısı: $uses');
    });
  });

  group('metin adaptörü', () {
    const texts = AppNotificationTexts();

    test('ezan bildirimi önceki vakti Türkçe sorar', () {
      expect(texts.adhanTitle(PrayerType.isha), 'Yatsı Vakti');
      expect(texts.adhanAskBody(PrayerType.isha, PrayerType.maghrib),
          'Selamünaleyküm! Yatsı ezanı okundu. Akşam namazını kıldın mı?');
      expect(texts.adhanBody(PrayerType.fajr), 'Sabah vakti girdi.');
    });

    test('hatırlatma ve kanal metinleri dolu', () {
      expect(texts.reminderTitle(PrayerType.asr), 'İkindi Namazını Kıldınız mı?');
      expect(texts.reminderBody, isNotEmpty);
      expect(texts.channelName, isNotEmpty);
      expect(texts.channelDescription, isNotEmpty);
    });
  });
}
