/// Tarih ve takvim metinleri.
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

  /// `25 Ocak`
  static String monthAndYear(DateTime d) => '${months[d.month - 1]} ${d.year}';

  /// `25/1`
  static String short(DateTime d) => '${d.day}/${d.month}';
}
