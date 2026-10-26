import '../prayer.dart';

/// Vakit adları.
abstract final class PrayerStrings {
  static const fajr = 'Sabah';
  static const sunrise = 'Güneş';
  static const dhuhr = 'Öğle';
  static const asr = 'İkindi';
  static const maghrib = 'Akşam';
  static const isha = 'Yatsı';
}

extension PrayerTypeLabel on PrayerType {
  /// Görüntülenen vakit adı.
  String get label {
    switch (this) {
      case PrayerType.fajr:
        return PrayerStrings.fajr;
      case PrayerType.dhuhr:
        return PrayerStrings.dhuhr;
      case PrayerType.asr:
        return PrayerStrings.asr;
      case PrayerType.maghrib:
        return PrayerStrings.maghrib;
      case PrayerType.isha:
        return PrayerStrings.isha;
    }
  }
}
