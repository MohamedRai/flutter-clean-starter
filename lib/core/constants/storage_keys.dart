/// Every key used with `KeyValueStorage` and `SecureStorage`.
///
/// Centralized so keys never collide and are easy to migrate.
abstract final class StorageKeys {
  // KeyValueStorage
  /// Persisted `ThemeMode` name.
  static const themeMode = 'settings.theme_mode';

  /// Persisted locale language code.
  static const localeCode = 'settings.locale';

  // SecureStorage
  /// The current access token.
  static const accessToken = 'auth.access_token';

  /// The current refresh token.
  static const refreshToken = 'auth.refresh_token';
}
