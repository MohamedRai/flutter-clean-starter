import 'package:flutter_clean_starter/core/constants/storage_keys.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart';
import 'package:flutter_clean_starter/features/settings/data/models/settings_model.dart';
import 'package:injectable/injectable.dart';

/// Persists settings on the device.
///
/// Throws [CacheException] when storage fails.
abstract interface class SettingsLocalDataSource {
  /// The stored settings (empty model when nothing was saved).
  SettingsModel read();

  /// Stores the theme mode name.
  Future<void> writeThemeMode(String themeMode);

  /// Stores the language code, or removes it when `null`.
  Future<void> writeLanguageCode(String? languageCode);
}

/// [SettingsLocalDataSource] backed by [KeyValueStorage].
@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  /// Creates the data source.
  const SettingsLocalDataSourceImpl(this._storage);

  final KeyValueStorage _storage;

  @override
  SettingsModel read() => _guard(
    () => SettingsModel(
      themeMode: _storage.getString(StorageKeys.themeMode),
      languageCode: _storage.getString(StorageKeys.localeCode),
    ),
  );

  @override
  Future<void> writeThemeMode(String themeMode) =>
      _guardAsync(() => _storage.setString(StorageKeys.themeMode, themeMode));

  @override
  Future<void> writeLanguageCode(String? languageCode) => _guardAsync(
    () => languageCode == null
        ? _storage.remove(StorageKeys.localeCode)
        : _storage.setString(StorageKeys.localeCode, languageCode),
  );

  T _guard<T>(T Function() body) {
    try {
      return body();
    } on Exception catch (e) {
      throw CacheException(message: 'Settings read failed', cause: e);
    }
  }

  Future<void> _guardAsync(Future<void> Function() body) async {
    try {
      await body();
    } on Exception catch (e) {
      throw CacheException(message: 'Settings write failed', cause: e);
    }
  }
}
