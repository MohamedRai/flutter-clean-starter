import 'package:bloc/bloc.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_language.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:injectable/injectable.dart';

/// Holds the current [AppSettings]; provided above `MaterialApp` so theme
/// and locale react to changes.
///
/// Updates are optimistic: the UI changes immediately and a failed save is
/// only logged — losing a preference is not worth an error dialog.
@injectable
class SettingsCubit extends Cubit<AppSettings> {
  /// Creates the cubit with default settings.
  SettingsCubit(this._getSettings, this._updateThemeMode, this._updateLanguage)
    : super(const AppSettings());

  final GetSettings _getSettings;
  final UpdateThemeMode _updateThemeMode;
  final UpdateLanguage _updateLanguage;

  /// Loads the saved settings.
  Future<void> load() async {
    final result = await _getSettings(const NoParams());
    if (isClosed) return;
    switch (result) {
      case SuccessResult(:final value):
        emit(value);
      case FailureResult(:final failure):
        AppLogger.warning('Could not load settings', error: failure);
    }
  }

  /// Switches the theme to [mode] and saves it.
  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(state.withThemeMode(mode));
    (await _updateThemeMode(mode))
        .onFailure((f) => AppLogger.warning('Could not save theme', error: f));
  }

  /// Switches the language to [languageCode] (`null` = device) and saves it.
  Future<void> setLanguage(String? languageCode) async {
    emit(state.withLanguageCode(languageCode));
    (await _updateLanguage(
      languageCode,
    )).onFailure((f) => AppLogger.warning('Could not save language', error: f));
  }
}
