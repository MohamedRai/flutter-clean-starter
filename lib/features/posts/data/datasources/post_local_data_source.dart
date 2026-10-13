import 'dart:convert';

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/data/models/post_model.dart';
import 'package:injectable/injectable.dart';

/// Keeps the last fetched posts on the device for offline use.
///
/// Throws [CacheException] when nothing usable is stored.
abstract interface class PostLocalDataSource {
  /// The saved posts.
  Future<List<PostModel>> getCachedPosts();

  /// The saved post with [id].
  Future<PostModel> getCachedPost(int id);

  /// Replaces the saved posts with [posts].
  Future<void> cachePosts(List<PostModel> posts);
}

/// [PostLocalDataSource] that stores JSON in [KeyValueStorage].
@LazySingleton(as: PostLocalDataSource)
class PostLocalDataSourceImpl implements PostLocalDataSource {
  /// Creates the data source.
  const PostLocalDataSourceImpl(this._storage);

  /// Storage key of the cached posts.
  static const cacheKey = 'posts.cache';

  final KeyValueStorage _storage;

  @override
  Future<List<PostModel>> getCachedPosts() async {
    final raw = _storage.getString(cacheKey);
    if (raw == null) {
      throw const CacheException(message: 'No cached posts');
    }
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .cast<Json>()
          .map(PostModel.fromJson)
          .toList();
    } on Object catch (e) {
      // Corrupt or outdated cache: treat as a miss.
      throw CacheException(message: 'Unreadable posts cache', cause: e);
    }
  }

  @override
  Future<PostModel> getCachedPost(int id) async {
    final posts = await getCachedPosts();
    return posts.firstWhere(
      (p) => p.id == id,
      orElse: () => throw CacheException(message: 'Post $id not cached'),
    );
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) => _storage.setString(
    cacheKey,
    jsonEncode(posts.map((p) => p.toJson()).toList()),
  );
}
