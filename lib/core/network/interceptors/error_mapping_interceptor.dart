import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/error/exception_mapper.dart';

/// Attaches a typed `AppException` to every failed request.
///
/// The original [DioException] is kept (so `type`, `response` etc. are still
/// available) but its `error` field now holds the mapped `AppException`,
/// which `HttpExceptionMapper` unwraps. Register it **last** so that it sees
/// the final error after retries.
class ErrorMappingInterceptor extends Interceptor {
  /// Creates the interceptor around [mapper].
  ErrorMappingInterceptor(this.mapper);

  /// Converts the error to an `AppException`.
  final ExceptionMapper mapper;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: mapper.map(err, err.stackTrace)));
  }
}
