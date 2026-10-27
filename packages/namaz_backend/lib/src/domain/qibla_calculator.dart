import 'dart:math' as math;

import 'prayer_time_service.dart';

/// Kâbe-i Muazzama koordinatları (Mekke).
const double kKaabaLatitude = 21.422487;
const double kKaabaLongitude = 39.826206;

/// Kullanıcının konumuna göre Kıble açısı ve Kâbe'ye olan kuş uçuşu mesafe.
class QiblaInfo {
  const QiblaInfo({
    required this.bearingDegrees,
    required this.distanceKm,
  });

  /// Kuzeyden saat yönünde Kıble açısı (`0.0` – `360.0` derece).
  final double bearingDegrees;

  /// Kâbe'ye olan kuş uçuşu mesafe (kilometre).
  final int distanceKm;
}

/// Verilen konum için Kıble açısını ve Kâbe mesafesini hesaplar (saf Dart).
QiblaInfo computeQibla(AppLocation location) {
  final lat1 = _degToRad(location.latitude);
  final lon1 = _degToRad(location.longitude);
  final lat2 = _degToRad(kKaabaLatitude);
  final lon2 = _degToRad(kKaabaLongitude);

  final dLon = lon2 - lon1;

  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final initialBearing = _radToDeg(math.atan2(y, x));
  final bearing = (initialBearing + 360.0) % 360.0;

  // Haversine mesafesi (Dünya yarıçapı R = 6371 km)
  final dLat = lat2 - lat1;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final distanceKm = (6371.0 * c).round();

  return QiblaInfo(
    bearingDegrees: bearing,
    distanceKm: distanceKm,
  );
}

double _degToRad(double deg) => deg * (math.pi / 180.0);
double _radToDeg(double rad) => rad * (180.0 / math.pi);
