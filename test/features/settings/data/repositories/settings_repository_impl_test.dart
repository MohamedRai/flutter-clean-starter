import 'package:flutter_clean_starter/core/cache/in_memory_data_cache_store.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart';
import 'package:flutter_clean_starter/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_clean_starter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements KeyValueStorage;

void main() {
  late _MockStorage storage;
  late SettingsRepositoryImpl repository;

  setUp(() {
    storage = _MockStorage();
    repository = SettingsRepositoryImpl(
      SettingsLocalDataSourceImpl(storage),
      cacheStore: InMemoryDataCacheStore(),
    );
  });

  test('reads saved settings', () async {
    when(() => storage.getString(any())).thenReturn(null);
    when(() => storage.getString('settings.theme_mode')).thenReturn('dark');
    when(() => storage.getString('settings.locale')).thenReturn('fr');

    expect(
      await repository.getSettings(),
      const Result.success(
        AppSettings(themeMode: AppThemeMode.dark, languageCode: 'fr'),
      ),
    );
  });

  test('falls back to defaults for unknown stored values', () async {
    when(() => storage.getString(any())).thenReturn('not-a-mode');
    final settings = (await repository.getSettings()).getOrNull()!;
    expect(settings.themeMode, AppThemeMode.system);
  });

  test('saves the theme mode by name', () async {
    when(() => storage.setString(any(), any())).thenAnswer((_) async {});
    final result = await repository.saveThemeMode(AppThemeMode.light);
    expect(result.isSuccess, isTrue);
    verify(() => storage.setString('settings.theme_mode', 'light')).called(1);
  });

  test('saves or clears the language', () async {
    when(() => storage.setString(any(), any())).thenAnswer((_) async {});
    when(() => storage.remove(any())).thenAnswer((_) async {});
    await repository.saveLanguageCode('ar');
    await repository.saveLanguageCode(null);
    verify(() => storage.setString('settings.locale', 'ar')).called(1);
    verify(() => storage.remove('settings.locale')).called(1);
  });

  test('maps storage errors to CacheFailure', () async {
    when(() => storage.setString(any(), any())).thenThrow(Exception('disk'));
    final result = await repository.saveThemeMode(AppThemeMode.dark);
    expect(result.failureOrNull(), isA<CacheFailure>());
    expect(
      () => SettingsLocalDataSourceImpl(storage).writeThemeMode('dark'),
      throwsA(isA<CacheException>()),
    );
  });
}
