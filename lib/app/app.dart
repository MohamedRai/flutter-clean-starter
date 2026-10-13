import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/app/di/injection.dart';
import 'package:flutter_clean_starter/app/router/app_router.dart';
import 'package:flutter_clean_starter/core/l10n/gen/app_localizations.dart';
import 'package:flutter_clean_starter/core/theme/app_theme.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/presentation/cubit/settings_cubit.dart';

/// The root widget: provides app-wide blocs and configures
/// `MaterialApp.router` (theme, locale, router).
class App extends StatelessWidget {
  /// Creates the app.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<SettingsCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: AppView(router: getIt<AppRouter>()),
    );
  }
}

/// [App] without DI, so tests can pump it with their own router/cubit.
class AppView extends StatelessWidget {
  /// Creates the view.
  const AppView({required this.router, super.key});

  /// The app router.
  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final languageCode = settings.languageCode;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: languageCode == null ? null : Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router.config,
    );
  }
}
