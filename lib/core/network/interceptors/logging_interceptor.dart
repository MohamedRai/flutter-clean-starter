import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Logs requests, responses and errors through [AppLogger].
///
/// Sensitive headers are redacted. Add it only in non-production flavors
/// (see `NetworkModule`) — bodies can contain personal data.
class LoggingInterceptor extends Interceptor {
  /// Creates the interceptor. Set [logBodies] to `false` to log only the
  /// request line and status.
  LoggingInterceptor({this.logBodies = true});

  /// Whether request and response bodies are logged.
  final bool logBodies;

  static const _redacted = {'authorization', 'cookie', 'set-cookie'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      '→ ${options.method} ${options.uri}',
      data: {
        'headers': _redact(options.headers),
        if (logBodies && options.data != null) 'body': options.data,
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.debug(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
      data: logBodies ? response.data : null,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri}',
      data: logBodies ? err.response?.data : null,
    );
    handler.next(err);
  }

  Map<String, Object?> _redact(Map<String, Object?> headers) => {
    for (final MapEntry(:key, :value) in headers.entries)
      key: _redacted.contains(key.toLowerCase()) ? '<redacted>' : value,
  };
}
