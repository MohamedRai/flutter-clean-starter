import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Retries transient failures (timeouts, connection errors, 5xx, 429) of
/// **idempotent** requests, with exponential back-off.
///
/// Non-idempotent methods (`POST`, `PATCH`) are never retried, to avoid
/// creating duplicates. Opt a request out with
/// `Options(extra: {noRetryKey: true})`.
class RetryInterceptor extends Interceptor {
  /// Creates the interceptor. [dio] is the client used to re-send requests.
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
    Future<void> Function(Duration delay)? wait,
  }) : _wait = wait ?? Future<void>.delayed;

  /// `Options.extra` key that disables retries for one request.
  static const noRetryKey = 'noRetry';

  static const _attemptKey = '_retryAttempt';

  static const _idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  /// Client used to re-send the request.
  final Dio dio;

  /// Maximum number of retries per request.
  final int maxRetries;

  /// Delay before the first retry; doubles on each following retry.
  final Duration baseDelay;

  final Future<void> Function(Duration delay) _wait;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxRetries || !shouldRetry(err)) {
      return handler.next(err);
    }

    final delay = baseDelay * (1 << attempt);
    AppLogger.debug(
      'Retrying ${options.method} ${options.uri} '
      '(${attempt + 1}/$maxRetries) in ${delay.inMilliseconds}ms',
    );
    await _wait(delay);

    options.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Whether [err] is transient and its request safe to repeat.
  bool shouldRetry(DioException err) {
    final options = err.requestOptions;
    if (options.extra[noRetryKey] == true) return false;
    if (!_idempotentMethods.contains(options.method.toUpperCase())) {
      return false;
    }
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => switch (err.response?.statusCode) {
        429 || 502 || 503 || 504 => true,
        _ => false,
      },
      _ => false,
    };
  }
}
