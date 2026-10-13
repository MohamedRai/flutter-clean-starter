import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';

/// Reads and persists [AppSettings].
abstract interface class SettingsRepository {
  /// The saved settings (defaults when nothing was saved).
  FutureResult<AppSettings> getSettings();

  /// Persists the theme preference.
  FutureResultVoid saveThemeMode(AppThemeMode mode);

  /// Persists the language preference (`null` = device language).
  FutureResultVoid saveLanguageCode(String? languageCode);
}
