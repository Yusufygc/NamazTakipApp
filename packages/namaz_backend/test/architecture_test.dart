import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Backend paketinin iç katman kurallarını ve arayüzden bağımsızlığını denetler.
///
/// Katmanlar (`lib/src/`): domain ← data, platform ← application.
///  - domain:      saf Dart mantığı ve modeller; başka katmanı bilmez, Flutter'a bağlı değildir.
///  - data:        SQLite ve ayar deposu; yalnızca domain'i bilir.
///  - platform:    konum ve bildirim eklentileri; yalnızca domain'i bilir.
///  - application: bunları birleştirir (bildirim planlama, arka plan, NamazBackend uygulaması).

const _layers = ['domain', 'data', 'platform', 'application'];

const _allowedLayerImports = <String, Set<String>>{
  'domain': {},
  'data': {'domain'},
  'platform': {'domain'},
  'application': {'domain', 'data', 'platform'},
};

final _importLine = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);

List<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

Iterable<String> _imports(File f) =>
    _importLine.allMatches(f.readAsStringSync()).map((m) => m.group(1)!);

String _norm(String path) => path.replaceAll('\\', '/');

/// `lib/src/<katman>/...` yolundan katman adını çıkarır.
String? _layerOf(String path) {
  final m = RegExp(r'lib/src/([a-z]+)/').firstMatch(_norm(path));
  return m?.group(1);
}

/// Türkçe harfler veya vakit adları: kullanıcıya görünecek metin işareti.
final _turkish = RegExp(r'[ğüşıöçĞÜŞİÖÇâîûÂÎÛ]|\b(Sabah|Namaz|Eda)\b');

/// Dart kaynağındaki dizgi sabitlerinin içeriğini döndürür; yorumları ve
/// `debugPrint(...)` çağrılarının içini (geliştirici günlüğü) atlar.
List<String> _stringLiterals(String src) {
  final out = <String>[];
  var i = 0;
  var debugDepth = 0; // debugPrint( içindeyken > 0
  bool at(String s) => src.startsWith(s, i);
  while (i < src.length) {
    if (at('//')) {
      while (i < src.length && src[i] != '\n') {
        i++;
      }
      continue;
    }
    if (at('/*')) {
      final end = src.indexOf('*/', i + 2);
      i = end < 0 ? src.length : end + 2;
      continue;
    }
    final c = src[i];
    if (c == "'" || c == '"') {
      final triple = at(c * 3);
      final quote = triple ? c * 3 : c;
      i += quote.length;
      final buf = StringBuffer();
      while (i < src.length && !at(quote)) {
        if (src[i] == r'\') {
          buf.write(src.substring(i, i + 2 > src.length ? src.length : i + 2));
          i += 2;
          continue;
        }
        if (!triple && src[i] == '\n') break;
        buf.write(src[i]);
        i++;
      }
      i += quote.length;
      if (debugDepth == 0) out.add(buf.toString());
      continue;
    }
    if (debugDepth == 0 && at('debugPrint(')) {
      debugDepth = 1;
      i += 'debugPrint('.length;
      continue;
    }
    if (debugDepth > 0) {
      if (c == '(') debugDepth++;
      if (c == ')') debugDepth--;
    }
    i++;
  }
  return out;
}

void main() {
  test('backend arayüz paketlerini kullanmaz', () {
    const forbidden = [
      'package:flutter/material.dart',
      'package:flutter/widgets.dart',
      'package:flutter/cupertino.dart',
      'package:flutter/painting.dart',
      'package:flutter_riverpod/',
      'package:fl_chart/',
      'package:namaz_takip/',
    ];
    final offenders = <String>[];
    for (final f in _dartFiles('lib')) {
      for (final i in _imports(f)) {
        if (forbidden.any(i.startsWith)) offenders.add('${_norm(f.path)} → $i');
      }
    }
    expect(offenders, isEmpty,
        reason: 'Backend arayüz bilmez:\n${offenders.join('\n')}');
  });

  test('domain katmanı saf Dart: Flutter ve eklenti paketi yok', () {
    const allowedExternal = ['package:adhan_dart/'];
    final offenders = <String>[];
    for (final f in _dartFiles('lib/src/domain')) {
      for (final i in _imports(f)) {
        final isRelative = !i.contains(':');
        final isDart = i.startsWith('dart:');
        final isAllowed = allowedExternal.any(i.startsWith);
        if (!isRelative && !isDart && !isAllowed) {
          offenders.add('${_norm(f.path)} → $i');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('katmanlar yalnızca izin verilen katmanları içe aktarır', () {
    final offenders = <String>[];
    for (final f in _dartFiles('lib/src')) {
      final layer = _layerOf(f.path);
      if (layer == null) continue; // src/namaz_backend.dart: hepsini görebilir
      for (final i in _imports(f)) {
        if (i.contains(':')) continue; // paket ve dart: içe aktarmaları
        final resolved = _norm(File(f.path).parent.uri.resolve(i).toFilePath());
        final target = _layerOf(resolved);
        if (target == null || target == layer) continue;
        if (!_allowedLayerImports[layer]!.contains(target)) {
          offenders.add('${_norm(f.path)}: $layer → $target');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('herkese açık yüz yalnızca barrel dosyasındadır', () {
    final barrel = File('lib/namaz_backend.dart').readAsStringSync();
    // Barrel `src/` dışına çıkmaz ve iç katmanları (data, platform, application) açmaz.
    for (final layer in ['data', 'platform', 'application']) {
      expect(barrel.contains('src/$layer/'), isFalse,
          reason: '$layer katmanı dışa açılmamalı');
    }
    final topLevel = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((f) => _norm(f.path).split('/').last)
        .toList();
    expect(topLevel, ['namaz_backend.dart'],
        reason: 'lib/ altında yalnızca barrel dosyası olmalı');
    expect(_layers.length, 4);
  });

  group('metin ve dil ön yüzdedir: backend sabit Türkçe metin içermez', () {
    // İzin listesi (dosya yolu → neden). Yeni bir dosya buraya eklenmeden
    // Türkçe metin sabiti içeremez; metin ön yüzde üretilip port ile verilir.
    const allowed = <String, String>{
      'lib/src/data/turkish_cities.dart': 'il adları veridir (özel isim)',
      'lib/src/domain/dhikr_extractor.dart':
          'Türkçe girdiyi ayrıştıran anahtar sözcükler; çıktıya metin koymaz',
      'lib/src/domain/dhikr.dart':
          'DhikrGroups: veritabanında saklanan kalıcı grup değerleri '
              '(taşımak veri göçü gerektirir)',
    };

    List<String> turkishIn(File f) => _stringLiterals(f.readAsStringSync())
        .where(_turkish.hasMatch)
        .toList();

    test('izin listesi dışındaki dosyalarda Türkçe metin sabiti yok', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib')) {
        final path = _norm(f.path);
        if (allowed.keys.any(path.endsWith)) continue;
        final found = turkishIn(f);
        if (found.isNotEmpty) {
          offenders.add('$path: ${found.take(3).map((s) => "'$s'").join(', ')}');
        }
      }
      expect(offenders, isEmpty,
          reason: 'Metin ve dil kararı ön yüzdedir. Backend metni port '
              '(NotificationTexts, HomeWidgetTexts, DhikrContent) ile alır:\n'
              '${offenders.join('\n')}');
    });

    test('izin listesindeki her dosya hâlâ Türkçe sabit içeriyor', () {
      // Metin ön yüze taşınınca dosya listeden çıkarılmalı; liste şişmesin.
      for (final entry in allowed.entries) {
        final file = _dartFiles('lib')
            .firstWhere((f) => _norm(f.path).endsWith(entry.key));
        expect(turkishIn(file), isNotEmpty,
            reason: '${entry.key} artık Türkçe sabit içermiyor; izin '
                'listesinden çıkarın (${entry.value})');
      }
    });

    test('tarayıcı doğru çalışıyor: sabiti yakalar, yorumu ve günlüğü atlar', () {
      const sample = r'''
// Yorumdaki Türkçe: Sabah ve Öğle yok sayılır
/* blok yorum: İkindi */
final a = 'Sabah';
final b = "Güneş doğuşu";
final c = 'ascii metin';
final d = """
çok satırlı Öğle
""";
void f() {
  debugPrint('günlük: Akşam ($x)');
  debugPrint(
    'çok satırlı günlük: Yatsı',
  );
}
final e = 'https://example.com/yol';
''';
      final found = _stringLiterals(sample).where(_turkish.hasMatch).toList();
      expect(found, hasLength(3));
      expect(found.any((s) => s.contains('Sabah')), isTrue);
      expect(found.any((s) => s.contains('Güneş')), isTrue);
      expect(found.any((s) => s.contains('Öğle')), isTrue);
      // Günlük ve yorum içindeki Türkçe sayılmaz.
      expect(found.any((s) => s.contains('Akşam') || s.contains('Yatsı')), isFalse);
    });
  });
}
