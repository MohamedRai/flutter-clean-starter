import 'package:flutter_clean_starter/core/constants/app_constants.dart';
import 'package:flutter_clean_starter/core/data/base_repository.dart';
import 'package:flutter_clean_starter/core/domain/fetch_policy.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';
import 'package:injectable/injectable.dart';

/// [PostRepository] with two cache levels:
///
/// 1. **In memory** (`BaseRepository` + [FetchPolicy.cacheFirst]) — instant
///    when navigating back and forth; expires after
///    [AppConstants.defaultCacheTtl].
/// 2. **On device** ([PostLocalDataSource]) — the last successful list,
///    served when the network is unavailable.
@LazySingleton(as: PostRepository)
class PostRepositoryImpl extends BaseRepository implements PostRepository {
  /// Creates the repository.
  PostRepositoryImpl(this._remote, this._local, {required super.cacheStore})
    : super(defaultTtl: AppConstants.defaultCacheTtl);

  final PostRemoteDataSource _remote;
  final PostLocalDataSource _local;

  /// In-memory cache key of the post list.
  static const postsKey = 'posts';

  /// In-memory cache key of one post.
  static String postKey(int id) => 'post:$id';

  @override
  FutureResultList<Post> getPosts({bool forceRefresh = false}) => safeCall(
    key: postsKey,
    policy: forceRefresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
    remote: () => _withOfflineFallback(
      fetch: () async {
        final models = await _remote.getPosts();
        await _local.cachePosts(models);
        return models.map((m) => m.toEntity()).toList();
      },
      fallback: () async =>
          (await _local.getCachedPosts()).map((m) => m.toEntity()).toList(),
    ),
  );

  @override
  FutureResult<Post> getPostById(int id) => safeCall(
    key: postKey(id),
    policy: FetchPolicy.cacheFirst,
    remote: () => _withOfflineFallback(
      fetch: () async => (await _remote.getPost(id)).toEntity(),
      fallback: () async => (await _local.getCachedPost(id)).toEntity(),
    ),
  );

  /// Runs [fetch]; when offline, returns [fallback] instead. If the
  /// fallback has nothing either, the original [NetworkException] is kept —
  /// "you are offline" is more useful to the user than "cache miss".
  Future<T> _withOfflineFallback<T>({
    required Future<T> Function() fetch,
    required Future<T> Function() fallback,
  }) async {
    try {
      return await fetch();
    } on NetworkException catch (networkError, stackTrace) {
      try {
        return await fallback();
      } on CacheException {
        Error.throwWithStackTrace(networkError, stackTrace);
      }
    }
  }
}
