/// Saat gösterimi: `05:55`. Gösterim biçimi arayüze aittir.
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
