import 'package:flutter_clean_starter/core/data/domain_convertible.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';

/// Settings as stored on the device: raw strings, possibly absent or stale.
final class SettingsModel implements DomainConvertible<AppSettings> {
  /// Creates the model.
  const SettingsModel({this.themeMode, this.languageCode});

  /// Stored `AppThemeMode` name, if any.
  final String? themeMode;

  /// Stored language code, if any.
  final String? languageCode;

  /// Unknown or missing values fall back to defaults, so a renamed enum
  /// value never breaks startup.
  @override
  AppSettings toEntity() => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[themeMode] ?? AppThemeMode.system,
    languageCode: languageCode,
  );
}
