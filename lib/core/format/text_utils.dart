/// Türkçe kurallarına göre büyük harfe çevirir. Dart'ın `toUpperCase()`'i
/// `i`'yi `I`'ya çevirdiği için "İkindi" → "İKINDI" olur; burada `i → İ`,
/// `ı → I` eşlemesi önce uygulanır.
String turkishUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// Arama için Türkçe harfleri ve büyük/küçük farkını yok sayar
/// (`İstanbul` ile `istanbul`, `Şanlıurfa` ile `sanliurfa` eşleşir).
String foldTurkish(String s) => s
    .replaceAll('İ', 'i')
    .replaceAll('I', 'ı')
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c')
    .replaceAll('â', 'a');
