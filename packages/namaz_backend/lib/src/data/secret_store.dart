import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gizli değerlerin (API anahtarı gibi) deposu. Düz `SharedPreferences` yerine
/// platform anahtar deposunu kullanır.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Android Keystore (AES-GCM, anahtar RSA ile sarılı) ve iOS Keychain üstünde
/// çalışır. iOS'ta değer yalnızca bu cihazda, ilk kilit açılışından sonra
/// okunur; iCloud Anahtar Zinciri'ne eşitlenmez.
class SecureSecretStore implements SecretStore {
  const SecureSecretStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
