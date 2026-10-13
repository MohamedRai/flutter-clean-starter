import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/extensions/string_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';
import 'package:flutter_clean_starter/core/widgets/async_builder.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/presentation/cubit/post_detail_cubit.dart';

/// One post. Expects a [PostDetailCubit] above it (provided by the route).
class PostDetailPage extends StatelessWidget {
  /// Creates the page.
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.postDetailTitle)),
      body: AsyncBuilder<PostDetailCubit, Post>(
        onRetry: () => context.read<PostDetailCubit>().retry(),
        successBuilder: (context, post) => _PostContent(post: post),
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        Text(post.title.capitalized, style: context.textTheme.headlineSmall),
        AppSpacing.gapSm,
        Text(
          context.l10n.postAuthor(post.userId),
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
        AppSpacing.gapLg,
        Text(post.body.capitalized, style: context.textTheme.bodyLarge),
      ],
    );
  }
}
