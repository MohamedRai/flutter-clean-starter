import 'package:dio/dio.dart';

/// Builds configured [Dio] clients.
///
/// Interceptor order matters. The recommended order, used by
/// `NetworkModule`, is:
/// 1. `AuthTokenInterceptor` — adds the token before anything is logged.
/// 2. `LoggingInterceptor` (non-prod only).
/// 3. `RetryInterceptor` — retries transient errors.
/// 4. `ErrorMappingInterceptor` — last, so it maps the final error.
abstract final class DioClientFactory {
  /// Default connect / send / receive timeout.
  static const defaultTimeout = Duration(seconds: 20);

  /// Creates a [Dio] for [baseUrl] with JSON defaults.
  ///
  /// [interceptorsBuilder] receives the new client so interceptors that
  /// re-send requests (retry) can reference it.
  static Dio create({
    required String baseUrl,
    List<Interceptor> Function(Dio dio)? interceptorsBuilder,
    Duration timeout = defaultTimeout,
    Map<String, Object?> headers = const {},
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        contentType: Headers.jsonContentType,
        headers: {Headers.acceptHeader: Headers.jsonContentType, ...headers},
      ),
    );
    if (interceptorsBuilder != null) {
      dio.interceptors.addAll(interceptorsBuilder(dio));
    }
    return dio;
  }
}
