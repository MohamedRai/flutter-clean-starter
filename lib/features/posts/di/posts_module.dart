import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_posts.dart';
import 'package:injectable/injectable.dart';

/// Registers the posts use cases, keeping the domain layer free of DI
/// annotations.
@module
abstract class PostsModule {
  /// See [GetPosts].
  @lazySingleton
  GetPosts getPosts(PostRepository repository) => GetPosts(repository);

  /// See [GetPostById].
  @lazySingleton
  GetPostById getPostById(PostRepository repository) => GetPostById(repository);
}
