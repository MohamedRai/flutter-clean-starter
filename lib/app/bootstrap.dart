import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_starter/app/app.dart';
import 'package:flutter_clean_starter/app/di/injection.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';
import 'package:flutter_clean_starter/core/bloc/app_bloc_observer.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Shared startup for every flavor: global error handling, dependency
/// injection, then `runApp`.
///
/// Errors are caught at three levels:
/// - `FlutterError.onError` — errors inside the Flutter framework (build,
///   layout, paint).
/// - `PlatformDispatcher.instance.onError` — uncaught async errors outside
///   Flutter callbacks.
/// - `runZonedGuarded` — anything else thrown in the root zone.
///
/// Replace the `AppLogger.error` calls with a crash reporter (Crashlytics,
/// Sentry) when you add one.
Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        AppLogger.error(
          'Flutter error',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogger.error(
          'Uncaught platform error',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };

      final config = FlavorConfig.fromEnvironment(flavor);
      Bloc.observer = AppBlocObserver(logTransitions: !config.isProd);
      await configureDependencies(config);

      runApp(const App());
    },
    (error, stackTrace) => AppLogger.error(
      'Uncaught zone error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}
