import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';

/// Runs side effects (navigation, snackbars, analytics) on [AsyncState]
/// transitions of cubit [C]. Never rebuilds [child].
///
/// ```dart
/// AsyncListener<SignInCubit, User>(
///   onSuccess: (user) => const HomeRoute().go(context),
///   onFailure: (f) => context.showSnackBar(f.localizedMessage(context.l10n)),
///   child: const SignInForm(),
/// )
/// ```
class AsyncListener<C extends StateStreamable<AsyncState<T>>, T>
    extends StatelessWidget {
  /// Creates the listener. Every callback is optional.
  const AsyncListener({
    required this.child,
    this.onInitial,
    this.onLoading,
    this.onSuccess,
    this.onFailure,
    super.key,
  });

  /// The subtree; not rebuilt by this widget.
  final Widget child;

  /// Called on [AsyncInitial].
  final VoidCallback? onInitial;

  /// Called on [AsyncLoading].
  final VoidCallback? onLoading;

  /// Called on [AsyncSuccess] with its data.
  final void Function(T data)? onSuccess;

  /// Called on [AsyncFailure] with its failure.
  final void Function(Failure failure)? onFailure;

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, AsyncState<T>>(
      listener: (context, state) => switch (state) {
        AsyncInitial() => onInitial?.call(),
        AsyncLoading() => onLoading?.call(),
        AsyncSuccess(:final data) => onSuccess?.call(data),
        AsyncFailure(:final failure) => onFailure?.call(failure),
      },
      child: child,
    );
  }
}
