import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';

/// The lifecycle of a single asynchronous operation producing a [T].
///
/// Sealed, so `switch` over it is exhaustive:
/// [AsyncInitial] → [AsyncLoading] → [AsyncSuccess] | [AsyncFailure].
sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  @override
  List<Object?> get props => const [];
}

/// Nothing has been requested yet.
final class AsyncInitial<T> extends AsyncState<T> {
  /// Creates the state.
  const AsyncInitial();
}

/// The operation is in progress.
final class AsyncLoading<T> extends AsyncState<T> {
  /// Creates the state.
  const AsyncLoading();
}

/// The operation succeeded with [data].
final class AsyncSuccess<T> extends AsyncState<T> {
  /// Creates the state.
  const AsyncSuccess(this.data);

  /// The operation's result.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// The operation failed with [failure].
final class AsyncFailure<T> extends AsyncState<T> {
  /// Creates the state.
  const AsyncFailure(this.failure);

  /// Why it failed.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
