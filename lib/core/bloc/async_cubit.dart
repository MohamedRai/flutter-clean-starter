import 'package:bloc/bloc.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';

/// A [Cubit] that runs one async operation and exposes it as an
/// [AsyncState]. Subclasses only say *what* to run, in [execute].
///
/// ```dart
/// class PostDetailCubit extends AsyncCubit<Post, int> {
///   PostDetailCubit(this._getPostById);
///   final GetPostById _getPostById;
///
///   @override
///   FutureResult<Post> execute(int id) =>
///       _getPostById(GetPostByIdParams(id: id));
/// }
///
/// // UI: AsyncBuilder<PostDetailCubit, Post>(successBuilder: ...)
/// ```
abstract class AsyncCubit<T, Params> extends Cubit<AsyncState<T>> {
  /// Creates the cubit in [AsyncInitial].
  AsyncCubit() : super(AsyncInitial<T>());

  Params? _lastParams;

  // Tracked separately from _lastParams: `null` is a valid Params value for
  // `AsyncCubit<T, void>`, so it can't mean "never loaded".
  bool _hasLoaded = false;

  /// Performs the work — delegate to a use case. Never emit from here.
  FutureResult<T> execute(Params params);

  /// Runs [execute] and emits [AsyncLoading] then [AsyncSuccess] or
  /// [AsyncFailure].
  ///
  /// With [silent] the loading state is skipped, so the current content
  /// stays visible (pull-to-refresh, polling).
  Future<void> load(Params params, {bool silent = false}) async {
    _lastParams = params;
    _hasLoaded = true;
    if (!silent) emit(AsyncLoading<T>());

    final result = await execute(params);
    if (isClosed) return;

    emit(switch (result) {
      SuccessResult(:final value) => AsyncSuccess<T>(value),
      FailureResult(:final failure) => AsyncFailure<T>(failure),
    });
  }

  /// Re-runs [load] with the last params. No-op before the first [load].
  Future<void> retry({bool silent = false}) async {
    if (!_hasLoaded) return;
    await load(_lastParams as Params, silent: silent);
  }

  /// Returns to [AsyncInitial] and forgets the last params.
  void reset() {
    _lastParams = null;
    _hasLoaded = false;
    emit(AsyncInitial<T>());
  }
}
