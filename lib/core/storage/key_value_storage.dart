import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive key-value persistence (settings, flags, small caches).
///
/// Never store secrets here — use `SecureStorage`. Reads are synchronous
/// (served from an in-memory cache); writes are asynchronous.
abstract interface class KeyValueStorage {
  /// The string stored under [key], or `null`.
  String? getString(String key);

  /// Stores [value] under [key].
  Future<void> setString(String key, String value);

  /// The bool stored under [key], or `null`.
  bool? getBool(String key);

  /// Stores [value] under [key].
  Future<void> setBool(String key, {required bool value});

  /// The int stored under [key], or `null`.
  int? getInt(String key);

  /// Stores [value] under [key].
  Future<void> setInt(String key, int value);

  /// Whether a value is stored under [key].
  bool containsKey(String key);

  /// Removes [key].
  Future<void> remove(String key);

  /// Removes every key managed by this storage.
  Future<void> clear();
}

/// [KeyValueStorage] backed by `SharedPreferencesWithCache`.
class SharedPreferencesStorage implements KeyValueStorage {
  /// Wraps an initialized [SharedPreferencesWithCache].
  const SharedPreferencesStorage(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// Creates the underlying preferences (async; call once at startup).
  static Future<SharedPreferencesWithCache> createPreferences() =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}
