import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/data/base_data_source.dart';

/// Base class for HTTP data sources built on [Dio].
///
/// Paths are relative to the `baseUrl` configured on [dio] (see
/// `DioClientFactory`). Every verb runs inside [safeCall], so callers only
/// ever see `AppException`s.
///
/// If your backend wraps payloads in an envelope (e.g. `{"data": ...}`),
/// override [unwrap] once in a project-level subclass:
///
/// ```dart
/// abstract class ApiDataSource extends BaseRemoteDataSource {
///   ApiDataSource({required super.dio, required super.exceptionMapper});
///
///   @override
///   Object? unwrap(Object? body) => (body as Map<String, dynamic>)['data'];
/// }
/// ```
abstract class BaseRemoteDataSource extends BaseDataSource {
  /// Creates the data source.
  const BaseRemoteDataSource({
    required this.dio,
    required super.exceptionMapper,
    super.networkInfo,
  });

  /// The configured HTTP client.
  final Dio dio;

  /// Extracts the payload from a response body. Defaults to the body itself.
  Object? unwrap(Object? body) => body;

  /// `GET` [path] and return the (unwrapped) body as [T].
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send<T>(
    () => dio.get<Object?>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  /// `POST` [data] to [path] and return the (unwrapped) body as [T].
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send<T>(
    () => dio.post<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  /// `PUT` [data] to [path] and return the (unwrapped) body as [T].
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send<T>(
    () => dio.put<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  /// `PATCH` [data] to [path] and return the (unwrapped) body as [T].
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send<T>(
    () => dio.patch<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  /// `DELETE` [path] and return the (unwrapped) body as [T].
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _send<T>(
    () => dio.delete<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<T> _send<T>(Future<Response<Object?>> Function() request) =>
      safeCall(() async {
        final response = await request();
        return unwrap(response.data) as T;
      });
}
