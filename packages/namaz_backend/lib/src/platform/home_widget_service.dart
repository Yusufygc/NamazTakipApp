import 'package:flutter/services.dart';

import '../domain/home_widget_snapshot.dart';

/// Android AppWidget ve iOS WidgetKit ile `com.namaztakip.app/home_widget`
/// MethodChannel üzerinden haberleşen platform servisi.
class HomeWidgetService {
  const HomeWidgetService();

  static const MethodChannel _channel = MethodChannel(
    'com.namaztakip.app/home_widget',
  );

  /// Güncel vakit ve takip özetini yerel depoya (Android SharedPreferences /
  /// iOS App Group UserDefaults) yazar ve sistem widget'ını yeniler.
  Future<bool> updateWidget(
    HomeWidgetSnapshot snapshot,
    HomeWidgetTexts texts,
  ) async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'updateWidget',
        snapshot.toMap(texts),
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Destekleyen başlatıcılarda (Android 8.0+ `requestPinAppWidget`) kullanıcıya
  /// widget'ı doğrudan telefon ana ekranına sabitleme penceresini açar.
  Future<bool> requestPinWidget() async {
    try {
      final ok = await _channel.invokeMethod<bool>('requestPinWidget');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
