/// Günlük takip edilen beş vakit.
enum PrayerType {
  fajr('Sabah'),
  dhuhr('Öğle'),
  asr('İkindi'),
  maghrib('Akşam'),
  isha('Yatsı');

  const PrayerType(this.trName);

  final String trName;

  /// Veritabanında saklanan kararlı anahtar.
  String get key => name;

  PrayerType? get previous => index == 0 ? null : PrayerType.values[index - 1];

  static PrayerType fromKey(String key) =>
      PrayerType.values.firstWhere((p) => p.name == key);
}

/// Bir vaktin kullanıcı tarafından işaretlenme durumu.
enum PrayerStatus {
  pending(0),
  performed(1),
  missed(2),
  compensated(3);

  const PrayerStatus(this.code);

  final int code;

  static PrayerStatus fromCode(int code) =>
      PrayerStatus.values.firstWhere((s) => s.code == code,
          orElse: () => PrayerStatus.pending);
}

/// Bir güne ait hesaplanmış vakitler (cihaz saat diliminde).
class DayTimes {
  const DayTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Takvim günü (saat bilgisi yok).
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  DateTime timeOf(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return fajr;
      case PrayerType.dhuhr:
        return dhuhr;
      case PrayerType.asr:
        return asr;
      case PrayerType.maghrib:
        return maghrib;
      case PrayerType.isha:
        return isha;
    }
  }
}

/// Sıradaki vakit ve ona kalan süre hesabı için sonuç.
class NextPrayer {
  const NextPrayer(this.type, this.time);

  final PrayerType type;
  final DateTime time;
}
