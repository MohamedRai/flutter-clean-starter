import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted persistence for secrets (tokens, credentials).
///
/// Backed by the Keychain on iOS and the Keystore on Android.
abstract interface class SecureStorage {
  /// The value stored under [key], or `null`.
  Future<String?> read(String key);

  /// Stores [value] under [key].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);

  /// Removes every key — e.g. on sign-out.
  Future<void> deleteAll();
}

/// [SecureStorage] backed by `flutter_secure_storage`.
class FlutterSecureStorageImpl implements SecureStorage {
  /// Wraps a `FlutterSecureStorage` instance.
  const FlutterSecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
