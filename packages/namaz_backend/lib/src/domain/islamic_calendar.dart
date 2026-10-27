import 'dates.dart';
import 'hijri_month_starts.dart';
import 'prayer.dart';

/// Hicri takvim tarihi (saf Dart). 1447-1448 için Diyanet ay başı tablosu,
/// diğer yıllar için Kuveyt tablo algoritması kullanılır (Diyanet'ten ±1 gün
/// sapabilir): [kHijriMonthStarts].
class HijriDate {
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month; // 1..12
  final int day; // 1..30

  /// Miladi tarihten Hicri tarihe dönüştürür.
  factory HijriDate.fromGregorian(DateTime date) {
    return _fromDiyanetTable(date) ?? HijriDate._fromTabularAlgorithm(date);
  }

  /// Diyanet ay başı tablosunun kapsadığı aralıktaysa tablodan, değilse `null`.
  static HijriDate? _fromDiyanetTable(DateTime date) {
    final day = dateOnly(date);
    final first = kHijriMonthStarts.first;
    final last = kHijriMonthStarts.last;
    // Son ayın uzunluğu tabloda yoktur; en fazla 30 gün sayılır.
    if (day.isBefore(first.date) ||
        daysDiff(day, last.date) + 1 > 30) {
      return null;
    }
    var found = first;
    for (final start in kHijriMonthStarts) {
      if (start.date.isAfter(day)) break;
      found = start;
    }
    return HijriDate(
      year: found.hijriYear,
      month: found.hijriMonth,
      day: daysDiff(day, found.date) + 1,
    );
  }

  /// Kuveyt tablo algoritması (tablo dışındaki yıllar için).
  factory HijriDate._fromTabularAlgorithm(DateTime date) {
    var d = date.day;
    var m = date.month;
    var y = date.year;

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;

    const iyear = 10631.0 / 30.0;
    const epochAstro = 1948084;
    const shift1 = 8.01 / 60.0;

    var z = jd - epochAstro;
    final cyc = (z / 10631.0).floor();
    z = z - 10631 * cyc;
    final j = ((z - shift1) / iyear).floor();
    final iy = 30 * cyc + j;
    z = z - (j * iyear + shift1).floor();
    var im = ((z + 28.5001) / 29.5).floor();
    if (im == 13) im = 12;
    final id = (z - (29.5001 * im - 29).floor()).clamp(1, 30);

    return HijriDate(year: iy, month: im, day: id);
  }
}

/// Mübarek gün, kandil gecesi veya Cuma günü bilgisi.
enum SpecialDayId {
  friday,
  hijriNewYear,
  ashura,
  mawlidKandil,
  regaipKandil,
  mirajKandil,
  beratKandil,
  ramadanStart,
  qadrNight,
  eidAlFitr,
  arafah,
  eidAlAdha,
}

/// Kerahat vakti türü.
enum KerahatType {
  /// Güneş doğduktan sonraki ~45 dakikalık işrak/kerahat süresi.
  sunrise,

  /// Öğle ezanından önceki ~30 dakikalık istiva (zeval) süresi.
  istiva,

  /// Akşam ezanından önceki ~40 dakikalık gurub/isfirar süresi.
  sunset,
}

class KerahatStatus {
  const KerahatStatus({
    required this.type,
    required this.endsAt,
  });

  final KerahatType type;
  final DateTime endsAt;

  int remainingMinutes(DateTime now) {
    final diff = endsAt.difference(now).inMinutes;
    return diff < 1 ? 1 : diff;
  }
}

/// Günün Hicri tarihine ve haftanın gününe göre mübarek gün/gece bilgisini döner.
SpecialDayId? detectSpecialDay(DateTime date, HijriDate hijri) {
  // 1) Hicri kandil, bayram ve mübarek günler
  if (hijri.month == 1 && hijri.day == 1) return SpecialDayId.hijriNewYear;
  if (hijri.month == 1 && hijri.day == 10) return SpecialDayId.ashura;
  if (hijri.month == 3 && hijri.day == 11) return SpecialDayId.mawlidKandil;
  // Regaip: Recep'in ilk Cuma'sından önceki Perşembe gecesi. Recep'in 1'i Cuma
  // ise bu Perşembe önceki ayın son günüdür, bu yüzden ertesi günün Hicri
  // tarihine bakılır.
  if (date.weekday == DateTime.thursday) {
    final tomorrow = HijriDate.fromGregorian(addDays(date, 1));
    if (tomorrow.month == 7 && tomorrow.day <= 7) {
      return SpecialDayId.regaipKandil;
    }
  }
  if (hijri.month == 7 && hijri.day == 26) return SpecialDayId.mirajKandil;
  if (hijri.month == 8 && hijri.day == 14) return SpecialDayId.beratKandil;
  if (hijri.month == 9 && hijri.day == 1) return SpecialDayId.ramadanStart;
  if (hijri.month == 9 && hijri.day == 26) return SpecialDayId.qadrNight;
  if (hijri.month == 10 && hijri.day >= 1 && hijri.day <= 3) {
    return SpecialDayId.eidAlFitr;
  }
  if (hijri.month == 12 && hijri.day == 9) return SpecialDayId.arafah;
  if (hijri.month == 12 && hijri.day >= 10 && hijri.day <= 13) {
    return SpecialDayId.eidAlAdha;
  }

  // 2) Cuma günü
  if (date.weekday == DateTime.friday) return SpecialDayId.friday;

  return null;
}

/// Verilen [now] anının kerahat vakti içinde olup olmadığını denetler.
KerahatStatus? detectKerahat(DayTimes times, DateTime now) {
  // 1) Güneş doğuşu sonrası 45 dk (sunrise zaten 1.5 dk erken ihtiyatlıdır)
  final sunriseEnd = times.sunrise.add(const Duration(minutes: 45));
  if (!now.isBefore(times.sunrise) && now.isBefore(sunriseEnd)) {
    return KerahatStatus(type: KerahatType.sunrise, endsAt: sunriseEnd);
  }

  // 2) Öğle ezanından önceki 30 dk (İstiva / Zeval)
  final istivaStart = times.dhuhr.subtract(const Duration(minutes: 30));
  if (!now.isBefore(istivaStart) && now.isBefore(times.dhuhr)) {
    return KerahatStatus(type: KerahatType.istiva, endsAt: times.dhuhr);
  }

  // 3) Akşam ezanından önceki 40 dk (İsfirar / Gurub)
  final sunsetStart = times.maghrib.subtract(const Duration(minutes: 40));
  if (!now.isBefore(sunsetStart) && now.isBefore(times.maghrib)) {
    return KerahatStatus(type: KerahatType.sunset, endsAt: times.maghrib);
  }

  return null;
}
