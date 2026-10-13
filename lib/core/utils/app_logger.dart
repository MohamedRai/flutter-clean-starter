import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// The project's single logging entry point — never use `print`.
///
/// A thin facade over the `logger` package so the backend can be swapped
/// (e.g. to forward errors to Crashlytics) in one place.
///
/// `data` is pretty-printed below the message: pass payloads there rather
/// than interpolating them into the message.
///
/// ```dart
/// AppLogger.info('Fetched posts', data: {'count': posts.length});
/// AppLogger.error('Request failed', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static Logger _logger = _defaultLogger();

  /// Replaces the underlying [Logger] — e.g. in tests, or to raise the
  /// level in production builds.
  // ignore: use_setters_to_change_properties
  static void configure(Logger logger) => _logger = logger;

  static Logger _defaultLogger() => Logger(
    // Logs are silent in release builds unless reconfigured.
    level: kReleaseMode ? Level.off : Level.trace,
    printer: PrettyPrinter(methodCount: 0),
  );

  /// Verbose diagnostic detail.
  static void debug(String message, {Object? data}) =>
      _logger.d(_compose(message, data));

  /// Notable but expected events.
  static void info(String message, {Object? data}) =>
      _logger.i(_compose(message, data));

  /// Something unexpected that the app recovered from.
  static void warning(String message, {Object? data, Object? error}) =>
      _logger.w(_compose(message, data), error: error);

  /// A failure worth investigating.
  static void error(
    String message, {
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(_compose(message, data), error: error, stackTrace: stackTrace);

  static Object _compose(String message, Object? data) =>
      data == null ? message : {'message': message, 'data': data};
}
