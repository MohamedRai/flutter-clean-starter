import 'package:collection/collection.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:meta/meta.dart';

/// The outcome of an operation that either succeeds with a value of type [T]
/// or fails with a [Failure].
///
/// This is the project's functional error type: repositories and use cases
/// return `Future<Result<T>>` (aliased as `FutureResult<T>`) instead of
/// throwing. Because it is `sealed`, a `switch` over a [Result] is checked
/// for exhaustiveness by the compiler:
///
/// ```dart
/// final message = switch (result) {
///   SuccessResult(:final value) => 'Loaded ${value.length} posts',
///   FailureResult(:final failure) => 'Failed: $failure',
/// };
/// ```
@immutable
sealed class Result<T> {
  const Result();

  /// Creates a successful result holding [value].
  const factory Result.success(T value) = SuccessResult<T>;

  /// Creates a failed result holding [failure].
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Handles both outcomes. Exactly one callback runs.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    SuccessResult(:final value) => success(value),
    FailureResult(failure: final f) => failure(f),
  };

  /// Whether this is a [SuccessResult].
  bool get isSuccess => this is SuccessResult<T>;

  /// Whether this is a [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// The success value, or `null` when this is a failure.
  T? getOrNull() => switch (this) {
    SuccessResult(:final value) => value,
    FailureResult() => null,
  };

  /// The success value, or the result of [orElse] when this is a failure.
  T getOrElse(T Function(Failure failure) orElse) => switch (this) {
    SuccessResult(:final value) => value,
    FailureResult(:final failure) => orElse(failure),
  };

  /// The failure, or `null` when this is a success.
  Failure? failureOrNull() => switch (this) {
    SuccessResult() => null,
    FailureResult(:final failure) => failure,
  };

  /// Transforms the success value. Failures pass through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    SuccessResult(:final value) => Result.success(transform(value)),
    FailureResult(:final failure) => Result.failure(failure),
  };

  /// Chains another fallible operation on the success value.
  ///
  /// Failures short-circuit: [next] is never called for a [FailureResult].
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T value) next,
  ) async => switch (this) {
    SuccessResult(:final value) => await next(value),
    FailureResult(:final failure) => Result.failure(failure),
  };

  /// Runs [action] with the value if this is a success; returns `this`.
  Result<T> onSuccess(void Function(T value) action) {
    if (this case SuccessResult(:final value)) action(value);
    // Returning `this` enables chaining: result.onSuccess(..).onFailure(..)
    // ignore: avoid_returning_this
    return this;
  }

  /// Runs [action] with the failure if this is a failure; returns `this`.
  Result<T> onFailure(void Function(Failure failure) action) {
    if (this case FailureResult(:final failure)) action(failure);
    // Returning `this` enables chaining, as in [onSuccess].
    // ignore: avoid_returning_this
    return this;
  }
}

/// A successful [Result] carrying [value].
final class SuccessResult<T> extends Result<T> {
  /// Creates a successful result.
  const SuccessResult(this.value);

  /// The value produced by the operation.
  final T value;

  // Deep equality, so results holding equal lists/maps compare equal.
  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessResult<T> && _equality.equals(other.value, value);

  @override
  int get hashCode => _equality.hash(value);

  @override
  String toString() => 'Result.success($value)';
}

/// A failed [Result] carrying a [failure].
final class FailureResult<T> extends Result<T> {
  /// Creates a failed result.
  const FailureResult(this.failure);

  /// Why the operation failed.
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Result.failure($failure)';
}
