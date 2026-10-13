import 'package:bloc/bloc.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Logs every bloc error, and (optionally) every transition.
///
/// Registered in `bootstrap()` via `Bloc.observer = AppBlocObserver()`.
class AppBlocObserver extends BlocObserver {
  /// Creates the observer. With [logTransitions] every state change is
  /// logged — useful in dev, too noisy for prod.
  const AppBlocObserver({this.logTransitions = false});

  /// Whether to log every state change.
  final bool logTransitions;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (logTransitions) {
      AppLogger.debug(
        '${bloc.runtimeType}: ${change.currentState.runtimeType} → '
        '${change.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Unhandled error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
