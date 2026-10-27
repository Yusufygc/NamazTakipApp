import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/data/secret_store.dart';
import 'package:namaz_backend/src/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _BrokenStore implements SecretStore {
  @override
  Future<String?> read(String key) async => throw StateError('keystore');

  @override
  Future<void> write(String key, String value) async =>
      throw StateError('keystore');

  @override
  Future<void> delete(String key) async => throw StateError('keystore');
}

Future<SharedPreferences> _prefs([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

void main() {
  group('Gemini anahtarı depolama', () {
    test('anahtar yalnızca güvenli depoya yazılır, SharedPreferences\'a değil',
        () async {
      final prefs = await _prefs();
      final store = _MemoryStore();
      final repo = SettingsRepository(prefs, secrets: store);
      await repo.loadSecrets();

      await repo.setGeminiApiKey('  gizli-anahtar  ');

      expect(repo.geminiApiKey, 'gizli-anahtar');
      expect(store.values['gemini_api_key'], 'gizli-anahtar');
      expect(prefs.getString('gemini_api_key'), isNull);
      for (final key in prefs.getKeys()) {
        expect(prefs.get(key).toString(), isNot(contains('gizli-anahtar')));
      }
    });

    test('yeniden açılışta anahtar depodan okunur', () async {
      final prefs = await _prefs();
      final store = _MemoryStore()..values['gemini_api_key'] = 'kayitli';
      final repo = SettingsRepository(prefs, secrets: store);

      expect(repo.geminiApiKey, isNull); // yüklenmeden belleğe girmez
      await repo.loadSecrets();
      expect(repo.geminiApiKey, 'kayitli');
    });

    test('eski sürümden kalan düz metin anahtar depoya taşınır ve silinir',
        () async {
      final prefs = await _prefs({'gemini_api_key': 'eski-duz'});
      final store = _MemoryStore();
      final repo = SettingsRepository(prefs, secrets: store);

      await repo.loadSecrets();

      expect(repo.geminiApiKey, 'eski-duz');
      expect(store.values['gemini_api_key'], 'eski-duz');
      expect(prefs.getString('gemini_api_key'), isNull);
    });

    test('depoda anahtar varsa eski düz kopya onun üzerine yazmaz', () async {
      final prefs = await _prefs({'gemini_api_key': 'eski-duz'});
      final store = _MemoryStore()..values['gemini_api_key'] = 'yeni';
      final repo = SettingsRepository(prefs, secrets: store);

      await repo.loadSecrets();

      expect(repo.geminiApiKey, 'yeni');
      expect(store.values['gemini_api_key'], 'yeni');
      expect(prefs.getString('gemini_api_key'), isNull);
    });

    test('temizleme hem depodan hem bellekten hem düz kopyadan siler',
        () async {
      final prefs = await _prefs({'gemini_api_key': 'eski-duz'});
      final store = _MemoryStore();
      final repo = SettingsRepository(prefs, secrets: store);
      await repo.loadSecrets();

      await repo.setGeminiApiKey(null);

      expect(repo.geminiApiKey, isNull);
      expect(store.values, isEmpty);
      expect(prefs.getString('gemini_api_key'), isNull);

      await repo.setGeminiApiKey('x');
      await repo.setGeminiApiKey('   ');
      expect(repo.geminiApiKey, isNull);
      expect(store.values, isEmpty);
    });

    test('depo bozuksa taşıma başarısızdır ama anahtar kaybolmaz', () async {
      final prefs = await _prefs({'gemini_api_key': 'eski-duz'});
      final repo = SettingsRepository(prefs, secrets: _BrokenStore());

      await repo.loadSecrets();

      expect(repo.geminiApiKey, 'eski-duz');
      expect(prefs.getString('gemini_api_key'), 'eski-duz');
    });

    test('depo verilmezse (arka plan) anahtar okunmaz ve yazılmaz', () async {
      final prefs = await _prefs({'gemini_api_key': 'eski-duz'});
      final repo = SettingsRepository(prefs);

      await repo.loadSecrets();
      expect(repo.geminiApiKey, isNull);
      await repo.setGeminiApiKey('yeni');
      expect(repo.geminiApiKey, isNull);
      expect(prefs.getString('gemini_api_key'), 'eski-duz');
    });
  });
}
