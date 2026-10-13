import 'package:flutter_clean_starter/core/data/base_repository.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// [SettingsRepository] backed by local storage only.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl extends BaseRepository
    implements SettingsRepository {
  /// Creates the repository.
  SettingsRepositoryImpl(this._local, {required super.cacheStore});

  final SettingsLocalDataSource _local;

  @override
  FutureResult<AppSettings> getSettings() => safeCall(
    key: 'noop',
    cache: false,
    remote: () async => _local.read().toEntity(),
  );

  @override
  FutureResultVoid saveThemeMode(AppThemeMode mode) =>
      safeWrite(write: () => _local.writeThemeMode(mode.name));

  @override
  FutureResultVoid saveLanguageCode(String? languageCode) =>
      safeWrite(write: () => _local.writeLanguageCode(languageCode));
}
