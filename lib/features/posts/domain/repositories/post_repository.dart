import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';

/// Access to [Post]s. Implementations decide where data comes from (network,
/// cache, local storage); callers only see [Post]s or `Failure`s.
abstract interface class PostRepository {
  /// All posts. With [forceRefresh] any in-memory cache is bypassed.
  ///
  /// Falls back to the last saved posts when offline.
  FutureResultList<Post> getPosts({bool forceRefresh = false});

  /// The post with [id].
  FutureResult<Post> getPostById(int id);
}
