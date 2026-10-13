import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_language.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  late _MockSettingsRepository repository;

  setUp(() => repository = _MockSettingsRepository());

  test('GetSettings returns the saved settings', () async {
    const settings = AppSettings(themeMode: AppThemeMode.dark);
    when(() => repository.getSettings())
        .thenAnswer((_) async => const Result.success(settings));

    expect(
      await GetSettings(repository)(const NoParams()),
      const Result.success(settings),
    );
  });

  test('UpdateThemeMode saves the mode', () async {
    when(() => repository.saveThemeMode(AppThemeMode.light))
        .thenAnswer((_) async => const Result.success(null));

    await UpdateThemeMode(repository)(AppThemeMode.light);

    verify(() => repository.saveThemeMode(AppThemeMode.light)).called(1);
  });

  test('UpdateLanguage saves the language code', () async {
    when(() => repository.saveLanguageCode('fr'))
        .thenAnswer((_) async => const Result.success(null));

    await UpdateLanguage(repository)('fr');

    verify(() => repository.saveLanguageCode('fr')).called(1);
  });

  test('AppSettings copies keep the other field', () {
    const settings = AppSettings(themeMode: AppThemeMode.dark);
    expect(settings.withLanguageCode('ar').themeMode, AppThemeMode.dark);
    expect(
      settings.withLanguageCode('ar').withThemeMode(AppThemeMode.light),
      const AppSettings(themeMode: AppThemeMode.light, languageCode: 'ar'),
    );
  });
}
