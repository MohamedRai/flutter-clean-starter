import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/extensions/failure_message_x.dart';
import 'package:flutter_clean_starter/core/widgets/app_loader.dart';
import 'package:flutter_clean_starter/core/widgets/empty_state.dart';
import 'package:flutter_clean_starter/core/widgets/error_view.dart';
import 'package:flutter_clean_starter/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_clean_starter/features/posts/presentation/widgets/post_tile.dart';

/// The posts list.
///
/// Expects a [PostsBloc] above it (provided by the route). Navigation is
/// injected through [onPostTap] so the feature never depends on the router.
class PostsPage extends StatelessWidget {
  /// Creates the page.
  const PostsPage({required this.onPostTap, super.key});

  /// Called with the id of the tapped post.
  final ValueChanged<int> onPostTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.postsTitle)),
      body: BlocConsumer<PostsBloc, PostsState>(
        listenWhen: (_, current) =>
            current is PostsLoaded && current.refreshFailure != null,
        listener: (context, state) {
          final failure = (state as PostsLoaded).refreshFailure!;
          context.showSnackBar(failure.localizedMessage(context.l10n));
        },
        builder: (context, state) => switch (state) {
          PostsInitial() || PostsLoading() => const AppLoader(),
          PostsFailure(:final failure) => ErrorView.failure(
            context,
            failure,
            onRetry: () =>
                context.read<PostsBloc>().add(const PostsRequested()),
          ),
          PostsLoaded(:final posts) => RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: posts.isEmpty
                ? _ScrollableEmpty(message: context.l10n.postsEmpty)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostTile(
                        key: ValueKey(post.id),
                        post: post,
                        onTap: () => onPostTap(post.id),
                      );
                    },
                  ),
          ),
        },
      ),
    );
  }

  /// Adds [PostsRefreshed] and completes when the bloc settles, so the
  /// refresh indicator spins exactly as long as the request.
  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<PostsBloc>()..add(const PostsRefreshed());
    return bloc.stream.firstWhere((s) => s is! PostsLoading);
  }
}

/// [EmptyState] that still supports pull-to-refresh.
class _ScrollableEmpty extends StatelessWidget {
  const _ScrollableEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: EmptyState(message: message, icon: Icons.article_outlined),
        ),
      ),
    );
  }
}
