import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/bloc/paging_cubit.dart';
import 'package:flutter_clean_starter/core/domain/identifiable.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/extensions/failure_message_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';
import 'package:flutter_clean_starter/core/widgets/app_loader.dart';
import 'package:flutter_clean_starter/core/widgets/empty_state.dart';
import 'package:flutter_clean_starter/core/widgets/error_view.dart';

/// An infinite-scrolling list bound to a [PagingCubit] of type [C].
///
/// Fetches the first page on mount, the next page when the user scrolls
/// within [scrollThreshold] of the end, and supports pull-to-refresh.
///
/// ```dart
/// PagingListView<PostsPagingCubit, Post>(
///   itemBuilder: (context, post) => PostTile(post: post),
/// )
/// ```
class PagingListView<C extends PagingCubit<T, Object?>, T extends Identifiable>
    extends StatefulWidget {
  /// Creates the list.
  const PagingListView({
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.scrollThreshold = 200,
    this.emptyBuilder,
    this.firstPageErrorBuilder,
    super.key,
  });

  /// Builds one item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Optional separator between items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Distance from the end (logical px) at which the next page loads.
  final double scrollThreshold;

  /// Shown when the list is empty; defaults to [EmptyState].
  final WidgetBuilder? emptyBuilder;

  /// Shown when the first page fails; defaults to [ErrorView].
  final Widget Function(BuildContext context, Failure failure)?
  firstPageErrorBuilder;

  @override
  State<PagingListView<C, T>> createState() => _PagingListViewState<C, T>();
}

class _PagingListViewState<
  C extends PagingCubit<T, Object?>,
  T extends Identifiable
>
    extends State<PagingListView<C, T>> {
  final _controller = ScrollController();

  C get _cubit => context.read<C>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _cubit.state.items.isEmpty) {
        unawaited(_cubit.fetchNextPage());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= widget.scrollThreshold) {
      unawaited(_cubit.fetchNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, PagingState<T>>(
      builder: (context, state) {
        final failure = state.failure;
        if (state.isFirstPageLoading) return const AppLoader();
        if (state.items.isEmpty && failure != null) {
          return widget.firstPageErrorBuilder?.call(context, failure) ??
              ErrorView.failure(context, failure, onRetry: _cubit.refresh);
        }
        if (state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _cubit.refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child:
                      widget.emptyBuilder?.call(context) ?? const EmptyState(),
                ),
              ),
            ),
          );
        }

        final hasFooter = state.isLoading || failure != null;
        return RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: ListView.separated(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: widget.padding,
            itemCount: state.items.length + (hasFooter ? 1 : 0),
            separatorBuilder: (context, index) =>
                widget.separatorBuilder?.call(context, index) ??
                const SizedBox.shrink(),
            itemBuilder: (context, index) {
              if (index < state.items.length) {
                return widget.itemBuilder(context, state.items[index]);
              }
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: failure == null
                    ? const AppLoader()
                    : TextButton(
                        onPressed: _cubit.fetchNextPage,
                        child: Text(
                          '${failure.localizedMessage(context.l10n)} '
                          '${context.l10n.retry}',
                          textAlign: TextAlign.center,
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
