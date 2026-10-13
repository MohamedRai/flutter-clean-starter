import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';

/// One row of the posts list.
class PostTile extends StatelessWidget {
  /// Creates the tile.
  const PostTile({required this.post, this.onTap, super.key});

  /// The post to show.
  final Post post;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text('${post.id}')),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        post.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall,
      ),
    );
  }
}
