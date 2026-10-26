import 'package:namaz_backend/namaz_backend.dart';

/// Ayarlar ekranı, hesaplama yöntemleri ve tema adları.
abstract final class SettingsStrings {
  // Bildirimler
  static const sectionNotifications = 'Bildirimler';
  static const notifications = 'Bildirimler';
  static const notificationsSubtitle = 'Ezan vakti ve "kıldın mı" hatırlatmaları';
  static const reminderDelay = 'Hatırlatma süresi';
  static const reminderDelaySubtitle = 'Ezandan kaç dakika sonra';

  static String minutes(int n) => '$n dk';

  // Konum ve vakitler
  static const sectionLocation = 'Konum ve Vakitler';
  static const locationAuto = 'Otomatik (GPS)';
  static const locationManual = 'Elle şehir seç';
  static const locationInUse = 'Vakit hesabında kullanılan konum';
  static const calcMethod = 'Hesaplama yöntemi';

  // Tema
  static const sectionTheme = 'Tema';

  // Zikir & Yapay Zeka Kazıma
  static const sectionDhikrAi = 'Sosyal Medya Zikir Kazıma (Gemini AI)';
  static const geminiKeyTitle = 'Gemini API Anahtarı (İsteğe Bağlı)';
  static const geminiKeyConfigured =
      'Tanımlı • Instagram videoları yapay zeka ile analiz edilir';
  static const geminiKeyNotConfigured =
      'Tanımlı değil • Yerleşik Esmaül Hüsna ve akıllı metin kazıyıcı aktif';
  static const geminiDialogTitle = 'Gemini API Anahtarı';
  static const geminiDialogHint = 'AIzaSy... anahtarınızı yapıştırın';
  static const geminiDialogHelper =
      'Boş bırakırsanız uygulama yerleşik Esmaül Hüsna sözlüğü ve OpenGraph kazıyıcı ile ücretsiz çalışır.';
  static const geminiSave = 'Kaydet';
  static const geminiClear = 'Temizle';

  static String themeSemantics(String name) => 'Tema: $name';

  static String themeName(String key) {
    switch (key) {
      case 'dark':
        return 'Koyu';
      case 'ocean':
        return 'Okyanus';
      case 'rose':
        return 'Gül Kurusu';
      case 'gold':
        return 'Altın';
      default:
        return 'Varsayılan';
    }
  }

  static String themeSubtitle(String key) {
    switch (key) {
      case 'dark':
        return 'Gece Kubbesi';
      case 'ocean':
        return 'İznik Çinisi';
      case 'rose':
        return 'Bordo & Gül';
      case 'gold':
        return 'Tezhip Altını';
      default:
        return 'Selçuklu Zümrüdü';
    }
  }

  static String calcMethodName(CalcMethod m) {
    switch (m) {
      case CalcMethod.diyanet:
        return 'Diyanet (Türkiye)';
      case CalcMethod.mwl:
        return 'Müslüman Dünya Birliği';
      case CalcMethod.egyptian:
        return 'Mısır Genel Otoritesi';
      case CalcMethod.karachi:
        return 'Karaçi İslam Bilimleri Üniv.';
      case CalcMethod.ummAlQura:
        return "Ümmü'l-Kura (Mekke)";
      case CalcMethod.northAmerica:
        return 'Kuzey Amerika (ISNA)';
    }
  }
}

extension CalcMethodLabel on CalcMethod {
  String get label => SettingsStrings.calcMethodName(this);
}
