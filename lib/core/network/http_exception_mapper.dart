import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/error/exception_mapper.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';

/// Maps HTTP / IO errors to [AppException]s by status code.
///
/// Backend-agnostic by default. If your API returns error codes in its body
/// (e.g. `{"error": {"code": "TOKEN_EXPIRED"}}`), subclass it and override
/// [mapResponse] or [extractMessage] — that is the single place to encode
/// backend-specific error conventions.
class HttpExceptionMapper implements ExceptionMapper {
  /// Creates the mapper.
  const HttpExceptionMapper();

  @override
  AppException map(Object error, [StackTrace? stackTrace]) => switch (error) {
    final AppException e => e,
    // ErrorMappingInterceptor stores the mapped exception in `error`.
    DioException(error: final AppException e) => e,
    final DioException e => mapDioException(e),
    final SocketException e => NetworkException(message: e.message, cause: e),
    final TimeoutException e => NetworkException(message: '$e', cause: e),
    final FormatException e => ServerException(
      message: 'Malformed response: ${e.message}',
      cause: e,
    ),
    _ => UnknownException(message: '$error', cause: error),
  };

  /// Maps a [DioException] that has not been mapped yet.
  AppException mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(message: e.type.name, cause: e);
      case DioExceptionType.badCertificate:
        return NetworkException(message: 'Bad certificate', cause: e);
      case DioExceptionType.cancel:
        return UnknownException(message: 'Request cancelled', cause: e);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final response = e.response;
        if (response == null) {
          return e.error is SocketException
              ? NetworkException(message: '${e.error}', cause: e)
              : UnknownException(message: e.message, cause: e);
        }
        return mapResponse(response, e);
    }
  }

  /// Maps an error [response] by HTTP status code.
  AppException mapResponse(Response<Object?> response, DioException cause) {
    final status = response.statusCode ?? 0;
    final message = extractMessage(response.data);
    return switch (status) {
      400 || 409 => BadRequestException(message: message, cause: cause),
      401 => UnauthorizedException(message: message, cause: cause),
      403 => ForbiddenException(message: message, cause: cause),
      404 => NotFoundException(message: message, cause: cause),
      422 => ValidationException(
        field: extractField(response.data),
        message: message,
        cause: cause,
      ),
      429 => RateLimitException(
        retryAfter: parseRetryAfter(response.headers),
        message: message,
        cause: cause,
      ),
      >= 500 => ServerException(
        statusCode: status,
        message: message,
        cause: cause,
      ),
      _ => ServerException(statusCode: status, message: message, cause: cause),
    };
  }

  /// Pulls a human-readable message out of an error body, trying common
  /// shapes: `{"message": ...}`, `{"error": "..."}`,
  /// `{"error": {"message": ...}}`.
  String? extractMessage(Object? body) {
    if (body is String && body.isNotEmpty) return body;
    if (body is! Map) return null;
    final error = body['error'];
    return switch ((body['message'], error)) {
      (final String m, _) => m,
      (_, final String e) => e,
      (_, final Map<dynamic, dynamic> e) when e['message'] is String =>
        e['message'] as String,
      _ => null,
    };
  }

  /// Pulls the offending field name out of a validation error body
  /// (`{"field": "email"}`), when present.
  String? extractField(Object? body) =>
      body is Map && body['field'] is String ? body['field'] as String : null;

  /// Reads `Retry-After` (seconds or HTTP-date), falling back to the
  /// `RateLimit-Reset` header (seconds).
  Duration? parseRetryAfter(Headers headers, {DateTime? now}) {
    final retryAfter = headers.value('retry-after')?.trim();
    if (retryAfter != null && retryAfter.isNotEmpty) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) return Duration(seconds: seconds);
      try {
        final until = HttpDate.parse(retryAfter)
            .difference(now ?? DateTime.now());
        return until.isNegative ? Duration.zero : until;
      } on HttpException {
        // Not a date either — fall through.
      }
    }
    final reset = int.tryParse(headers.value('ratelimit-reset')?.trim() ?? '');
    return reset == null ? null : Duration(seconds: reset);
  }
}
