/// Zikir Defteri, Instagram/Sosyal Medya Yakalayıcı ve Akıllı Zikirmatik metinleri.
abstract final class DhikrStrings {
  static const screenTitle = 'Zikir ve Esma Defteri';
  static const topBarButton = 'Zikirler';
  static const subtitle =
      'Instagram videolarından yakalanan veya eklenen zikir ve esmalarınız';

  // Filtreler ve arama
  static const allGroups = 'Tümü';
  static const favoritesGroup = 'Favoriler';
  static const searchHint = 'Zikir, esma veya fazilet ara...';
  static const emptyListTitle = 'Bu grupta henüz zikir yok';
  static const emptyListBody =
      'Instagram\'da gördüğünüz dini videoları "Paylaş -> Namaz Takip" ile buraya gönderebilir veya aşağıdaki butonla ekleyebilirsiniz.';

  // Instagram / Sosyal medya kazıma kartı
  static const socialBannerTitle = 'Instagram\'dan Zikir Yakala';
  static const socialBannerSubtitle =
      'Instagram\'da Paylaş -> Namaz Takip seçin veya video bağlantısını / açıklamasını yapıştırıp kazıyın.';
  static const pasteLinkButton = 'Bağlantı / Metin Kazı';
  static const manualAddButton = 'Yeni Zikir Ekle';

  // Kazıma ve düzenleme alt sayfası
  static const scrapeSheetTitle = 'Sosyal Medyadan Zikir Kazı';
  static const editSheetTitle = 'Zikri Düzenle';
  static const addSheetTitle = 'Yeni Zikir veya Esma Ekle';
  static const sharedDetectedBanner =
      'Paylaşılan içerikten zikir, sayı ve vakit otomatik çıkarıldı. Kaydetmeden önce düzenleyebilirsiniz.';
  static const rawInputLabel = 'Instagram Bağlantısı veya Video Açıklaması';
  static const rawInputHint =
      'https://www.instagram.com/reel/... veya açıklama metni yapıştırın';
  static const analyzeButton = 'Videodan / Metinden Kazı';
  static const analyzing = 'İçerik kazınıyor...';
  static const catalogQuickPick = 'Hazır Esma / Tesbihat Seç';

  // Form alanları
  static const fieldTitle = 'Zikir / Esma Adı';
  static const fieldTitleHint = 'Örn: Yâ Rezzâk, Sübhanallahi ve Bihamdihi';
  static const fieldArabic = 'Arapça Yazılışı (İsteğe Bağlı)';
  static const fieldTransliteration = 'Türkçe Okunuşu';
  static const fieldMeaning = 'Anlamı ve Fazileti';
  static const fieldTargetCount = 'Hedef Sayı (Adet)';
  static const fieldGroup = 'Grup';
  static const fieldCustomGroupHint = 'Veya yeni grup adı yazın...';
  static const fieldPrayerTime = 'Tavsiye Edilen Vakit';
  static const prayerTimeAny = 'Her Vakit';
  static const fieldSourceUrl = 'Kaynak Video Bağlantısı';
  static const saveButton = 'Zikir Defterine Kaydet';
  static const updateButton = 'Değişiklikleri Kaydet';
  static const deleteConfirmTitle = 'Zikri Sil';
  static const deleteConfirmBody =
      'Bu zikri defterinizden silmek istediğinize emin misiniz?';
  static const deleteButton = 'Sil';

  // Kart ve Zikirmatik
  static const openVideoButton = 'Kaynak Videoyu Aç';
  static const startCounterButton = 'Zikirmatik';
  static const resetCounterButton = 'Sıfırla';
  static const counterTapHint = 'Saymak için madalyona dokunun';
  static const completedBadge = 'Hedef Tamamlandı';

  static String progressLabel(int current, int target) => '$current / $target';
  static String completedCycles(int count) => '$count kez tamamlandı';
  static String recommendedAfter(String prayerLabel) =>
      '$prayerLabel namazı sonrası';

  // Namaz sonrası tesbihat önerisi (Ana ekran)
  static String postPrayerPrompt(String prayerLabel, String dhikrTitle) =>
      'Allah kabul etsin! $prayerLabel namazı tesbihatı: $dhikrTitle';
  static const postPrayerAction = 'Tesbihata Başla';
}
