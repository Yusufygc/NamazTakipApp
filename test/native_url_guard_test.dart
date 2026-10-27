import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Dart tarafı `isSafeWebUrl` ile süzer, ama yerel köprüler de savunma
/// derinliği olarak aynı kuralı uygular. Swift derlenemediği ortamlarda bile
/// kuralın silinmemesini kaynak düzeyinde korur.
void main() {
  test('Android openUrl yalnızca http ve https açar', () {
    final src = File(
      'android/app/src/main/kotlin/com/namaztakip/namaz_takip/MainActivity.kt',
    ).readAsStringSync();
    final handler = src.substring(src.indexOf('"openUrl" ->'));
    expect(handler, contains('scheme != "http" && scheme != "https"'));
    expect(handler, contains('parsed.host.isNullOrEmpty()'));
  });

  test('iOS openUrl açmadan önce şema ve ana makine denetler', () {
    final src = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(src, contains('static func isSafeWebUrl(_ url: URL) -> Bool'));
    expect(src, contains('scheme == "http" || scheme == "https"'));
    final open = src.substring(src.indexOf('case "openUrl":'));
    final guardAt = open.indexOf('Self.isSafeWebUrl(url)');
    final openAt = open.indexOf('UIApplication.shared.open');
    expect(guardAt, greaterThan(-1));
    expect(openAt, greaterThan(guardAt), reason: 'denetim açmadan önce olmalı');
  });
}
