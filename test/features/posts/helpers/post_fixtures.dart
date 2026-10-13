import 'package:flutter_clean_starter/features/posts/data/models/post_model.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';

/// Shared test data. Keep fixtures small and obviously fake.
abstract final class Fixtures {
  /// A post entity.
  static const post = Post(id: 1, userId: 7, title: 'title 1', body: 'body 1');

  /// A second post entity.
  static const post2 = Post(id: 2, userId: 7, title: 'title 2', body: 'body 2');

  /// [post] as a model.
  static const postModel = PostModel(
    id: 1,
    userId: 7,
    title: 'title 1',
    body: 'body 1',
  );

  /// [post2] as a model.
  static const postModel2 = PostModel(
    id: 2,
    userId: 7,
    title: 'title 2',
    body: 'body 2',
  );

  /// [post] as API JSON.
  static const postJson = <String, dynamic>{
    'id': 1,
    'userId': 7,
    'title': 'title 1',
    'body': 'body 1',
  };
}
