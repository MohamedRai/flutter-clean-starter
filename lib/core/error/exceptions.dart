/// Base type for every exception thrown by the data layer.
///
/// Data sources throw [AppException]s; repositories catch them and convert
/// them to `Failure`s (see `Failure.fromException`). Nothing above the data
/// layer should ever see an exception.
sealed class AppException implements Exception {
  const AppException({this.message, this.cause});

  /// Optional developer-facing detail. Never shown to users as-is.
  final String? message;

  /// The original error (e.g. a `DioException`), kept for logging.
  final Object? cause;

  @override
  String toString() {
    final detail = [?message, ?cause?.toString()].join(' — ');
    // Debug output only (logs); never shown to users or compared.
    // ignore: no_runtimetype_tostring
    final name = '$runtimeType';
    return detail.isEmpty ? name : '$name($detail)';
  }
}

/// The server answered with an error (5xx, or an unexpected status).
final class ServerException extends AppException {
  /// Creates the exception.
  const ServerException({this.statusCode, super.message, super.cause});

  /// HTTP status code, when known.
  final int? statusCode;
}

/// The request never reached the server or timed out (offline, DNS, ...).
final class NetworkException extends AppException {
  /// Creates the exception.
  const NetworkException({super.message, super.cause});
}

/// A local cache read missed, expired, or held data of the wrong type.
final class CacheException extends AppException {
  /// Creates the exception.
  const CacheException({super.message, super.cause});
}

/// Input was rejected (HTTP 422 or a local check).
final class ValidationException extends AppException {
  /// Creates the exception.
  const ValidationException({this.field, super.message, super.cause});

  /// The offending field, when the server named one.
  final String? field;
}

/// The caller is not authenticated or the session expired (HTTP 401).
final class UnauthorizedException extends AppException {
  /// Creates the exception.
  const UnauthorizedException({super.message, super.cause});
}

/// The caller is authenticated but not allowed (HTTP 403).
final class ForbiddenException extends AppException {
  /// Creates the exception.
  const ForbiddenException({super.message, super.cause});
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  /// Creates the exception.
  const NotFoundException({super.message, super.cause});
}

/// The request was malformed (HTTP 400, 409, ...).
final class BadRequestException extends AppException {
  /// Creates the exception.
  const BadRequestException({super.message, super.cause});
}

/// Too many requests (HTTP 429).
final class RateLimitException extends AppException {
  /// Creates the exception.
  const RateLimitException({this.retryAfter, super.message, super.cause});

  /// How long the server asked the client to wait, when it said.
  final Duration? retryAfter;
}

/// Anything not covered above — including parsing errors.
final class UnknownException extends AppException {
  /// Creates the exception.
  const UnknownException({super.message, super.cause});
}
