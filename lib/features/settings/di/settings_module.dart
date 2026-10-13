import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_language.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:injectable/injectable.dart';

/// Registers the settings use cases, keeping the domain layer free of DI
/// annotations.
@module
abstract class SettingsModule {
  /// See [GetSettings].
  @lazySingleton
  GetSettings getSettings(SettingsRepository repository) =>
      GetSettings(repository);

  /// See [UpdateThemeMode].
  @lazySingleton
  UpdateThemeMode updateThemeMode(SettingsRepository repository) =>
      UpdateThemeMode(repository);

  /// See [UpdateLanguage].
  @lazySingleton
  UpdateLanguage updateLanguage(SettingsRepository repository) =>
      UpdateLanguage(repository);
}
