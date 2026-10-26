import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/dates.dart';
import '../domain/models.dart';
import '../domain/prayer_time_service.dart';

/// Kullanıcı ayarları ve küçük kalıcı durumlar (SharedPreferences).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'theme';
  static const _kNotifications = 'notifications_enabled';
  static const _kReminderMinutes = 'reminder_minutes';
  static const _kCalcMethod = 'calc_method';
  static const _kLocationMode = 'location_mode';
  static const _kManualLocation = 'manual_location';
  static const _kLastLocation = 'last_location';
  static const _kInstallDate = 'install_date';
  static const _kCorruptedDbBackup = 'corrupted_db_backup';
  static const _kGeminiApiKey = 'gemini_api_key';

  String get themeKey => _prefs.getString(_kTheme) ?? 'default';
  Future<void> setThemeKey(String v) => _prefs.setString(_kTheme, v);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotifications, v);

  /// Ezandan kaç dakika sonra "kıldın mı" hatırlatması gelsin.
  int get reminderMinutes => _prefs.getInt(_kReminderMinutes) ?? 15;
  Future<void> setReminderMinutes(int v) => _prefs.setInt(_kReminderMinutes, v);

  CalcMethod get calcMethod => CalcMethod.fromKey(_prefs.getString(_kCalcMethod));
  Future<void> setCalcMethod(CalcMethod m) => _prefs.setString(_kCalcMethod, m.key);

  LocationMode get locationMode => _prefs.getString(_kLocationMode) == 'manual'
      ? LocationMode.manual
      : LocationMode.auto;
  Future<void> setLocationMode(LocationMode m) =>
      _prefs.setString(_kLocationMode, m.name);

  AppLocation? get manualLocation => _readLocation(_kManualLocation);
  Future<void> setManualLocation(AppLocation l) => _writeLocation(_kManualLocation, l);

  /// Son başarılı GPS konumu; GPS alınamazsa ve arka planda kullanılır.
  AppLocation? get lastLocation => _readLocation(_kLastLocation);
  Future<void> setLastLocation(AppLocation l) => _writeLocation(_kLastLocation, l);

  /// Uygulamanın ilk kullanıldığı gün; kaza hesabının başlangıcı.
  DateTime? get installDate {
    final v = _prefs.getString(_kInstallDate);
    return v == null ? null : parseDateKey(v);
  }

  Future<void> ensureInstallDate(DateTime day) async {
    if (_prefs.getString(_kInstallDate) == null) {
      await _prefs.setString(_kInstallDate, dateKey(day));
    }
  }

  AppLocation? _readLocation(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return AppLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeLocation(String key, AppLocation l) =>
      _prefs.setString(key, jsonEncode(l.toJson()));

  /// Hesaplamada kullanılacak konum: elle seçim, yoksa son GPS konumu.
  AppLocation? get effectiveLocation =>
      locationMode == LocationMode.manual && manualLocation != null
          ? manualLocation
          : lastLocation;

  /// Bozuk veritabanı sıfırlandığında kullanıcıya gösterilecek yedek dosya yolu.
  /// Kullanıcı uyarıyı onayladığında temizlenir.
  String? get corruptedDbBackup => _prefs.getString(_kCorruptedDbBackup);

  Future<void> setCorruptedDbBackup(String? path) => path == null
      ? _prefs.remove(_kCorruptedDbBackup)
      : _prefs.setString(_kCorruptedDbBackup, path);

  /// Sosyal medya videoları/açıklamaları için isteğe bağlı Gemini API anahtarı.
  String? get geminiApiKey {
    final v = _prefs.getString(_kGeminiApiKey)?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> setGeminiApiKey(String? key) {
    final trimmed = key?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _prefs.remove(_kGeminiApiKey);
    }
    return _prefs.setString(_kGeminiApiKey, trimmed);
  }
}
