import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/constants/app_constants.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/widgets/app_loader.dart';
import 'package:flutter_clean_starter/core/widgets/error_view.dart';

/// Builds a widget for each [AsyncState] emitted by cubit [C].
///
/// Only [successBuilder] is required; loading and failure default to
/// [AppLoader] and [ErrorView]. State changes cross-fade unless [animate] is
/// `false`.
///
/// ```dart
/// AsyncBuilder<PostDetailCubit, Post>(
///   successBuilder: (context, post) => PostContent(post: post),
///   onRetry: () => context.read<PostDetailCubit>().retry(),
/// )
/// ```
class AsyncBuilder<C extends StateStreamable<AsyncState<T>>, T>
    extends StatelessWidget {
  /// Creates the builder.
  const AsyncBuilder({
    required this.successBuilder,
    this.initialBuilder,
    this.loadingBuilder,
    this.failureBuilder,
    this.onRetry,
    this.buildWhen,
    this.animate = true,
    super.key,
  });

  /// Builds the success UI from the data.
  final Widget Function(BuildContext context, T data) successBuilder;

  /// Builds [AsyncInitial]; defaults to nothing.
  final WidgetBuilder? initialBuilder;

  /// Builds [AsyncLoading]; defaults to [AppLoader].
  final WidgetBuilder? loadingBuilder;

  /// Builds [AsyncFailure]; defaults to [ErrorView.failure].
  final Widget Function(BuildContext context, Failure failure)? failureBuilder;

  /// Retry callback for the default failure view.
  final VoidCallback? onRetry;

  /// Forwarded to [BlocBuilder.buildWhen].
  final BlocBuilderCondition<AsyncState<T>>? buildWhen;

  /// Whether to cross-fade between states.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, AsyncState<T>>(
      buildWhen: buildWhen,
      builder: (context, state) {
        final child = KeyedSubtree(
          key: ValueKey(state.runtimeType),
          child: switch (state) {
            AsyncInitial() =>
              initialBuilder?.call(context) ?? const SizedBox.shrink(),
            AsyncLoading() =>
              loadingBuilder?.call(context) ?? const AppLoader(),
            AsyncSuccess(:final data) => successBuilder(context, data),
            AsyncFailure(:final failure) =>
              failureBuilder?.call(context, failure) ??
                  ErrorView.failure(context, failure, onRetry: onRetry),
          },
        );
        if (!animate) return child;
        return AnimatedSwitcher(
          duration: AppConstants.shortAnimation,
          child: child,
        );
      },
    );
  }
}
