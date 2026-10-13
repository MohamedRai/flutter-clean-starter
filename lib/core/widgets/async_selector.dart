import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';

/// Rebuilds only when a value derived from cubit [C]'s [AsyncState]
/// changes — e.g. a submit button that only cares about "is loading".
///
/// ```dart
/// AsyncSelector<SignInCubit, User, bool>(
///   selector: (state) => state is AsyncLoading,
///   builder: (context, isLoading) => SubmitButton(busy: isLoading),
/// )
/// ```
class AsyncSelector<C extends StateStreamable<AsyncState<T>>, T, R>
    extends StatelessWidget {
  /// Creates the selector.
  const AsyncSelector({
    required this.selector,
    required this.builder,
    super.key,
  });

  /// Projects the state to the value that drives rebuilds.
  final R Function(AsyncState<T> state) selector;

  /// Builds from the projected value.
  final Widget Function(BuildContext context, R value) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<C, AsyncState<T>, R>(
      selector: selector,
      builder: builder,
    );
  }
}
