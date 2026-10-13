import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';

/// A recoverable error, returned (never thrown) from repositories and use
/// cases inside a `Result`.
///
/// Failures carry no user-facing text: the presentation layer maps them to
/// localized messages (see `FailureMessageX`). The optional [message] is for
/// logs and debugging only.
sealed class Failure extends Equatable {
  const Failure({this.message});

  /// Maps a data-layer [AppException] to its [Failure] counterpart.
  factory Failure.fromException(AppException exception) => switch (exception) {
    ServerException(:final statusCode, :final message) => ServerFailure(
      statusCode: statusCode,
      message: message,
    ),
    NetworkException(:final message) => NetworkFailure(message: message),
    CacheException(:final message) => CacheFailure(message: message),
    ValidationException(:final field, :final message) =>
      ValidationFailure<String>(message ?? '', field: field ?? ''),
    UnauthorizedException(:final message) => UnauthorizedFailure(
      message: message,
    ),
    ForbiddenException(:final message) => ForbiddenFailure(message: message),
    NotFoundException(:final message) => NotFoundFailure(message: message),
    BadRequestException(:final message) => BadRequestFailure(message: message),
    RateLimitException(:final retryAfter, :final message) => RateLimitFailure(
      retryAfter: retryAfter,
      message: message,
    ),
    UnknownException(:final message) => UnknownFailure(message: message),
  };

  /// Developer-facing detail; never display it directly.
  final String? message;

  /// Whether retrying the same operation could plausibly succeed.
  bool get isRetryable => switch (this) {
    NetworkFailure() || ServerFailure() || RateLimitFailure() => true,
    _ => false,
  };

  @override
  List<Object?> get props => [message];
}

/// The server failed to handle the request.
final class ServerFailure extends Failure {
  /// Creates the failure.
  const ServerFailure({this.statusCode, super.message});

  /// HTTP status code, when known.
  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}

/// No connection, or the request timed out.
final class NetworkFailure extends Failure {
  /// Creates the failure.
  const NetworkFailure({super.message});
}

/// Nothing usable was found in the local cache.
final class CacheFailure extends Failure {
  /// Creates the failure.
  const CacheFailure({super.message});
}

/// The user must sign in (again).
final class UnauthorizedFailure extends Failure {
  /// Creates the failure.
  const UnauthorizedFailure({super.message});
}

/// The user is not allowed to perform this action.
final class ForbiddenFailure extends Failure {
  /// Creates the failure.
  const ForbiddenFailure({super.message});
}

/// The requested resource does not exist.
final class NotFoundFailure extends Failure {
  /// Creates the failure.
  const NotFoundFailure({super.message});
}

/// The request could not be processed as sent.
final class BadRequestFailure extends Failure {
  /// Creates the failure.
  const BadRequestFailure({super.message});
}

/// Too many requests; try again after [retryAfter].
final class RateLimitFailure extends Failure {
  /// Creates the failure.
  const RateLimitFailure({this.retryAfter, super.message});

  /// How long the server asked the client to wait, when it said.
  final Duration? retryAfter;

  @override
  List<Object?> get props => [retryAfter, message];
}

/// An unexpected error.
final class UnknownFailure extends Failure {
  /// Creates the failure.
  const UnknownFailure({super.message});
}

/// A single invalid field.
///
/// [TField] is whatever identifies a field: a backend key (`String`) or a
/// form-specific enum.
final class ValidationFailure<TField> extends Failure {
  /// Creates the failure for [field].
  const ValidationFailure(String message, {required this.field})
    : super(message: message);

  /// The invalid field.
  final TField field;

  @override
  List<Object?> get props => [message, field];
}

/// Several invalid fields at once — e.g. every empty required field of a
/// form, so they can all be highlighted together.
final class ValidationFailures<TField> extends Failure {
  /// Creates the failure from a list of per-field [failures].
  const ValidationFailures(this.failures);

  /// One entry per invalid field, in on-screen order.
  final List<ValidationFailure<TField>> failures;

  /// The message for [field], or `null` when that field is valid.
  String? messageOf(TField field) =>
      failures.where((f) => f.field == field).firstOrNull?.message;

  @override
  List<Object?> get props => [failures];
}

/// Field-level lookups that work for both [ValidationFailure] and
/// [ValidationFailures].
extension ValidationFailureX on Failure {
  /// The validation message for [field], or `null` if [field] is valid or
  /// this failure is not a validation failure.
  ///
  /// Lets a form use one lookup — `errorText: failure?.errorFor(field)` —
  /// regardless of which kind of validation failure was produced.
  String? errorFor<TField>(TField field) => switch (this) {
    final ValidationFailures<TField> f => f.messageOf(field),
    final ValidationFailure<TField> f when f.field == field => f.message,
    _ => null,
  };
}
