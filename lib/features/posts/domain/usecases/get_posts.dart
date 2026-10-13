import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';

/// Lists all posts.
class GetPosts implements UseCase<List<Post>, GetPostsParams> {
  /// Creates the use case.
  const GetPosts(this._repository);

  final PostRepository _repository;

  @override
  FutureResultList<Post> call(GetPostsParams params) =>
      _repository.getPosts(forceRefresh: params.forceRefresh);
}

/// Parameters for [GetPosts].
final class GetPostsParams extends Equatable {
  /// Creates the parameters.
  const GetPostsParams({this.forceRefresh = false});

  /// Bypass caches (pull-to-refresh).
  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}
