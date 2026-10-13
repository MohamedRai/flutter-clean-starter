import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_language.dart';
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:flutter_clean_starter/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSettings extends Mock implements GetSettings;

class _MockUpdateThemeMode extends Mock implements UpdateThemeMode;

class _MockUpdateLanguage extends Mock implements UpdateLanguage;

void main() {
  late _MockGetSettings getSettings;
  late _MockUpdateThemeMode updateThemeMode;
  late _MockUpdateLanguage updateLanguage;

  setUpAll(() {
    registerFallbackValue(AppThemeMode.system);
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getSettings = _MockGetSettings();
    updateThemeMode = _MockUpdateThemeMode();
    updateLanguage = _MockUpdateLanguage();
    when(() => updateThemeMode(any()))
        .thenAnswer((_) async => const Result.success(null));
    when(() => updateLanguage(any()))
        .thenAnswer((_) async => const Result.failure(CacheFailure()));
  });

  SettingsCubit build() =>
      SettingsCubit(getSettings, updateThemeMode, updateLanguage);

  blocTest<SettingsCubit, AppSettings>(
    'load emits the saved settings',
    setUp: () => when(() => getSettings(any())).thenAnswer(
      (_) async =>
          const Result.success(AppSettings(themeMode: AppThemeMode.dark)),
    ),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [AppSettings(themeMode: AppThemeMode.dark)],
  );

  blocTest<SettingsCubit, AppSettings>(
    'load keeps defaults on failure',
    setUp: () =>
        when(() => getSettings(any()))
            .thenAnswer((_) async => const Result.failure(CacheFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const <AppSettings>[],
  );

  blocTest<SettingsCubit, AppSettings>(
    'updates optimistically, even when saving fails',
    build: build,
    act: (cubit) async {
      await cubit.setThemeMode(AppThemeMode.light);
      await cubit.setLanguage('ar');
    },
    expect: () => const [
      AppSettings(themeMode: AppThemeMode.light),
      AppSettings(themeMode: AppThemeMode.light, languageCode: 'ar'),
    ],
    verify: (_) {
      verify(() => updateThemeMode(AppThemeMode.light)).called(1);
      verify(() => updateLanguage('ar')).called(1);
    },
  );
}
