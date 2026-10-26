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
}
