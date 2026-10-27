import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/models.dart';
import '../domain/prayer_time_service.dart';

class LocationService {
  const LocationService();

  static const EventChannel _compassChannel =
      EventChannel('com.namaztakip.app/compass');

  /// Cihaz pusula sensöründen gelen kuzey açısı (`0.0` – `360.0`).
  Stream<double> get compassHeading =>
      _compassChannel.receiveBroadcastStream().map((e) => (e as num).toDouble());

  /// Konum iznini kontrol eder; gerekirse ister.
  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationFailure.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.deniedForever);
    }
  }

  /// Geçerli konumu ve şehir adını döner. Önce pil dostu ağ konumu denenir;
  /// alınamazsa (iç mekân, ağ konumu yok) GPS ile, o da olmazsa son bilinen
  /// konumla devam edilir.
  Future<AppLocation> current() async {
    await ensurePermission();
    const attempts = [
      (LocationAccuracy.medium, Duration(seconds: 10)),
      (LocationAccuracy.high, Duration(seconds: 25)),
    ];
    for (final (accuracy, limit) in attempts) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: accuracy, timeLimit: limit),
        );
        return await _named(pos.latitude, pos.longitude);
      } catch (e) {
        debugPrint('[Location] $accuracy başarısız: $e');
      }
    }
    final last = await Geolocator.getLastKnownPosition();
    if (last == null) {
      throw const LocationException(LocationFailure.unavailable);
    }
    return _named(last.latitude, last.longitude);
  }

  Future<AppLocation> _named(double lat, double lon) async {
    var city = '';
    var country = '';
    try {
      final marks = await Geocoding().placemarkFromCoordinates(lat, lon);
      if (marks.isNotEmpty) {
        final m = marks.first;
        city = _firstNonEmpty([m.administrativeArea, m.subAdministrativeArea, m.locality]);
        country = m.country ?? '';
      }
    } catch (_) {
      // Ad bulunamasa da koordinatlar vakit hesabı için yeterli.
    }
    if (city.isEmpty) {
      city = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    }
    return AppLocation(latitude: lat, longitude: lon, city: city, country: country);
  }

  String _firstNonEmpty(List<String?> values) =>
      values.firstWhere((v) => v != null && v.isNotEmpty, orElse: () => '') ?? '';
}
