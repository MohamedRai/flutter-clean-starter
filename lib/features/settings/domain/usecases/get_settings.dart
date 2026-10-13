import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';

/// Loads the saved [AppSettings].
class GetSettings implements UseCase<AppSettings, NoParams> {
  /// Creates the use case.
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  FutureResult<AppSettings> call(NoParams params) => _repository.getSettings();
}
