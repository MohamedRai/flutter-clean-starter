import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';

/// Saves the theme preference.
class UpdateThemeMode implements UseCase<void, AppThemeMode> {
  /// Creates the use case.
  const UpdateThemeMode(this._repository);

  final SettingsRepository _repository;

  @override
  FutureResultVoid call(AppThemeMode mode) => _repository.saveThemeMode(mode);
}
