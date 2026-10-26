import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../core/date_utils.dart';
import '../core/prayer.dart';

/// Konum bilgisi (GPS veya elle seçilmiş).
class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.country = '',
  });

  final double latitude;
  final double longitude;
  final String city;
  final String country;

  String get label => country.isEmpty ? city : '$city, $country';

  Map<String, Object> toJson() => {
        'lat': latitude,
        'lon': longitude,
        'city': city,
        'country': country,
      };

  static AppLocation? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final lat = j['lat'];
    final lon = j['lon'];
    if (lat is! num || lon is! num) return null;
    return AppLocation(
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      city: (j['city'] as String?) ?? '',
      country: (j['country'] as String?) ?? '',
    );
  }
}

/// Seçilebilir hesaplama yöntemleri.
enum CalcMethod {
  diyanet('diyanet', 'Diyanet (Türkiye)'),
  mwl('mwl', 'Müslüman Dünya Birliği'),
  egyptian('egyptian', 'Mısır Genel Otoritesi'),
  karachi('karachi', 'Karaçi İslam Bilimleri Üniv.'),
  ummAlQura('ummalqura', 'Ümmü\'l-Kura (Mekke)'),
  northAmerica('isna', 'Kuzey Amerika (ISNA)');

  const CalcMethod(this.key, this.trName);

  final String key;
  final String trName;

  static CalcMethod fromKey(String? key) => CalcMethod.values
      .firstWhere((m) => m.key == key, orElse: () => CalcMethod.diyanet);

  adhan.CalculationParameters get params {
    switch (this) {
      case CalcMethod.diyanet:
        return adhan.CalculationMethodParameters.turkiye();
      case CalcMethod.mwl:
        return adhan.CalculationMethodParameters.muslimWorldLeague();
      case CalcMethod.egyptian:
        return adhan.CalculationMethodParameters.egyptian();
      case CalcMethod.karachi:
        return adhan.CalculationMethodParameters.karachi();
      case CalcMethod.ummAlQura:
        return adhan.CalculationMethodParameters.ummAlQura();
      case CalcMethod.northAmerica:
        return adhan.CalculationMethodParameters.northAmerica();
    }
  }
}

/// Vakitleri cihazda hesaplar; internet gerekmez.
class PrayerTimeService {
  const PrayerTimeService();

  DayTimes compute(AppLocation location, DateTime day, CalcMethod method) {
    final date = dateOnly(day);
    final times = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(location.latitude, location.longitude),
      date: date,
      calculationParameters: method.params,
      precision: false,
    );
    return DayTimes(
      date: date,
      fajr: times.fajr.toLocal(),
      sunrise: times.sunrise.toLocal(),
      dhuhr: times.dhuhr.toLocal(),
      asr: times.asr.toLocal(),
      maghrib: times.maghrib.toLocal(),
      isha: times.isha.toLocal(),
    );
  }
}
