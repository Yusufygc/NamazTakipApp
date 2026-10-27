/// Hicri ay başlarının Diyanet takvimindeki Miladi karşılıkları (1447 ve 1448).
///
/// Tablo algoritması (Kuveyt) Diyanet takvimiyle her ay aynı yönde sapmaz: 2026-27
/// örneklerinde bazı ayları bir gün erken, bazılarını doğru verir. Bayram ve kandil
/// günlerinin yanlış güne düşmemesi için bu yıllarda ay başları doğrudan
/// tablodan okunur; tablo dışındaki tarihlerde algoritma kullanılır.
///
/// Kaynak: Diyanet takvimine dayanan yayınlardan derlendi (bayramlar, Hicri
/// yılbaşı, üç aylar, Ramazan başı Diyanet duyurularıyla örtüşüyor); resmî
/// duyuru değildir. Yeni yıl eklenirken Diyanet'in ilan ettiği tarihlerle
/// doğrulanmalıdır.
library;

/// `(yıl, ay)` → ayın ilk gününün Miladi tarihi. Sıra: ay başı tarihine göre artan.
/// Son satır (1449 Muharrem) yoktur; son ayın uzunluğu 29 veya 30'dur ve
/// tablo bu ayın içindeki günleri `day <= 30` ile ele alır.
const List<HijriMonthStart> kHijriMonthStarts = [
  // 1447
  HijriMonthStart(1447, 1, 2025, 6, 26),
  HijriMonthStart(1447, 2, 2025, 7, 26),
  HijriMonthStart(1447, 3, 2025, 8, 24),
  HijriMonthStart(1447, 4, 2025, 9, 23),
  HijriMonthStart(1447, 5, 2025, 10, 23),
  HijriMonthStart(1447, 6, 2025, 11, 21),
  HijriMonthStart(1447, 7, 2025, 12, 21),
  HijriMonthStart(1447, 8, 2026, 1, 20),
  HijriMonthStart(1447, 9, 2026, 2, 19),
  HijriMonthStart(1447, 10, 2026, 3, 20),
  HijriMonthStart(1447, 11, 2026, 4, 18),
  HijriMonthStart(1447, 12, 2026, 5, 18),
  // 1448
  HijriMonthStart(1448, 1, 2026, 6, 16),
  HijriMonthStart(1448, 2, 2026, 7, 15),
  HijriMonthStart(1448, 3, 2026, 8, 14),
  HijriMonthStart(1448, 4, 2026, 9, 12),
  HijriMonthStart(1448, 5, 2026, 10, 12),
  HijriMonthStart(1448, 6, 2026, 11, 10),
  HijriMonthStart(1448, 7, 2026, 12, 10),
  HijriMonthStart(1448, 8, 2027, 1, 9),
  HijriMonthStart(1448, 9, 2027, 2, 8),
  HijriMonthStart(1448, 10, 2027, 3, 9),
  HijriMonthStart(1448, 11, 2027, 4, 8),
  HijriMonthStart(1448, 12, 2027, 5, 7),
];

class HijriMonthStart {
  const HijriMonthStart(
    this.hijriYear,
    this.hijriMonth,
    this.year,
    this.month,
    this.day,
  );

  final int hijriYear;
  final int hijriMonth;
  final int year;
  final int month;
  final int day;

  DateTime get date => DateTime(year, month, day);
}
