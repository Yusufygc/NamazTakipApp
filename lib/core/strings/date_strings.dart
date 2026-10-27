import 'package:namaz_backend/namaz_backend.dart';

/// Tarih, Hicri takvim ve mübarek gün/gece metinleri.
abstract final class DateStrings {
  static const List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> hijriMonths = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  /// Pazartesi ile başlayan kısa gün adları.
  static const List<String> weekdaysShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// `25 Ocak 2026`
  static String long(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

  /// `14 Recep 1448`
  static String hijriLong(HijriDate h) =>
      '${h.day} ${hijriMonths[(h.month - 1).clamp(0, 11)]} ${h.year}';

  /// `25 Ocak`
  static String monthAndYear(DateTime d) => '${months[d.month - 1]} ${d.year}';

  /// `25/1`
  static String short(DateTime d) => '${d.day}/${d.month}';

  static String specialDayLabel(SpecialDayId id) {
    switch (id) {
      case SpecialDayId.friday:
        return 'Hayırlı Cumalar • Kehf Suresi & Salavat';
      case SpecialDayId.hijriNewYear:
        return 'Hicri Yılbaşınız Mübarek Olsun';
      case SpecialDayId.ashura:
        return 'Aşure Gününüz Mübarek Olsun';
      case SpecialDayId.mawlidKandil:
        return 'Mevlid Kandiliniz Mübarek Olsun';
      case SpecialDayId.regaipKandil:
        return 'Regaip Kandiliniz Mübarek Olsun';
      case SpecialDayId.mirajKandil:
        return 'Miraç Kandiliniz Mübarek Olsun';
      case SpecialDayId.beratKandil:
        return 'Berat Kandiliniz Mübarek Olsun';
      case SpecialDayId.ramadanStart:
        return 'Hoş Geldin Yâ Şehr-i Ramazan';
      case SpecialDayId.qadrNight:
        return 'Kadir Geceniz Mübarek Olsun';
      case SpecialDayId.eidAlFitr:
        return 'Ramazan Bayramınız Mübarek Olsun';
      case SpecialDayId.arafah:
        return 'Arefe Gününüz Mübarek Olsun';
      case SpecialDayId.eidAlAdha:
        return 'Kurban Bayramınız Mübarek Olsun';
    }
  }
}
