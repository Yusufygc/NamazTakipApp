import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/dates.dart';
import '../domain/models.dart';
import '../domain/prayer.dart';
import '../domain/prayer_time_service.dart';
import 'secret_store.dart';

/// Kullanıcı ayarları ve küçük kalıcı durumlar (SharedPreferences).
class SettingsRepository {
  /// [secrets] verilmezse gizli değerler (Gemini anahtarı) hiç saklanmaz ve
  /// okunmaz; arka plan görevi gibi anahtarı kullanmayan yerler böyle açar.
  // Adlandırılmış parametre özel alana başlatıcı biçimle bağlanamaz.
  // ignore: prefer_initializing_formals
  SettingsRepository(this._prefs, {SecretStore? secrets}) : _secrets = secrets;

  final SharedPreferences _prefs;
  final SecretStore? _secrets;

  /// Anahtar deposundan açılışta okunan değer; getter eşzamanlı kalsın diye.
  String? _geminiKey;

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
  static const _kQazaBacklog = 'qaza_backlog';
  static const _kQazaDailyTarget = 'qaza_daily_target';

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

  /// Açılışta bir kez çağrılır: anahtarı anahtar deposundan belleğe alır. Eski
  /// sürümde `SharedPreferences`'a düz metin yazılmış anahtar varsa depoya
  /// taşır ve düz kopyayı siler. Taşıma başarısız olursa düz kopya silinmez
  /// (anahtar kaybolmaz) ve o oturumda kullanılır.
  Future<void> loadSecrets() async {
    final store = _secrets;
    final legacy = _prefs.getString(_kGeminiApiKey)?.trim();
    if (store == null) {
      _geminiKey = null;
      return;
    }
    try {
      final stored = (await store.read(_kGeminiApiKey))?.trim();
      if (stored != null && stored.isNotEmpty) {
        _geminiKey = stored;
      } else if (legacy != null && legacy.isNotEmpty) {
        await store.write(_kGeminiApiKey, legacy);
        _geminiKey = legacy;
      }
      if (legacy != null) await _prefs.remove(_kGeminiApiKey);
    } catch (_) {
      _geminiKey = (legacy == null || legacy.isEmpty) ? null : legacy;
    }
  }

  /// Sosyal medya videoları/açıklamaları için isteğe bağlı Gemini API anahtarı.
  String? get geminiApiKey => _geminiKey;

  Future<void> setGeminiApiKey(String? key) async {
    final trimmed = key?.trim();
    final store = _secrets;
    if (store == null) return;
    if (trimmed == null || trimmed.isEmpty) {
      await store.delete(_kGeminiApiKey);
      _geminiKey = null;
    } else {
      await store.write(_kGeminiApiKey, trimmed);
      _geminiKey = trimmed;
    }
    // Eski sürümden kalan düz metin kopya hiçbir durumda kalmasın.
    await _prefs.remove(_kGeminiApiKey);
  }

  /// Geçmiş yıllardan kalan vakit bazlı toplu kaza borcu.
  Map<PrayerType, int> get qazaBacklog {
    final raw = _prefs.getString(_kQazaBacklog);
    if (raw == null || raw.isEmpty) {
      return {for (final p in PrayerType.values) p: 0};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final p in PrayerType.values)
          p: ((decoded[p.name] as num?)?.toInt() ?? 0).clamp(0, 1000000),
      };
    } catch (_) {
      return {for (final p in PrayerType.values) p: 0};
    }
  }

  Future<void> setQazaBacklog(Map<PrayerType, int> counts) {
    final map = {
      for (final p in PrayerType.values)
        p.name: (counts[p] ?? 0).clamp(0, 1000000),
    };
    return _prefs.setString(_kQazaBacklog, jsonEncode(map));
  }

  int get qazaDailyTarget => (_prefs.getInt(_kQazaDailyTarget) ?? 2).clamp(1, 50);

  Future<void> setQazaDailyTarget(int target) =>
      _prefs.setInt(_kQazaDailyTarget, target.clamp(1, 50));
}
