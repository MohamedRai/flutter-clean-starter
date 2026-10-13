import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';

/// Saves the language preference (`null` = follow the device).
class UpdateLanguage implements UseCase<void, String?> {
  /// Creates the use case.
  const UpdateLanguage(this._repository);

  final SettingsRepository _repository;

  @override
  FutureResultVoid call(String? languageCode) =>
      _repository.saveLanguageCode(languageCode);
}
