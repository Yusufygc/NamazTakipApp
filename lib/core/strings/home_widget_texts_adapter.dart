import 'package:namaz_backend/namaz_backend.dart';

import 'home_strings.dart';
import 'prayer_strings.dart';
import 'settings_strings.dart';

/// Backend'in [HomeWidgetTexts] portunu, ön yüzün metin sistemiyle doldurur.
class AppHomeWidgetTexts implements HomeWidgetTexts {
  const AppHomeWidgetTexts();

  @override
  String prayerLabel(PrayerType prayer) => prayer.label;

  @override
  String get sunriseLabel => PrayerStrings.sunrise;

  @override
  String get nextTag => HomeStrings.nextBadge;

  @override
  String header(String city) => SettingsStrings.homeWidgetHeader(city);

  @override
  String doneBadge(int done) => SettingsStrings.homeWidgetDoneBadge(done);
}
