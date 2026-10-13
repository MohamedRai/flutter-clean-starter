import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/usecase/usecase.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';

/// Loads a single post.
class GetPostById implements UseCase<Post, GetPostByIdParams> {
  /// Creates the use case.
  const GetPostById(this._repository);

  final PostRepository _repository;

  @override
  FutureResult<Post> call(GetPostByIdParams params) =>
      _repository.getPostById(params.id);
}

/// Parameters for [GetPostById].
final class GetPostByIdParams extends Equatable {
  /// Creates the parameters.
  const GetPostByIdParams({required this.id});

  /// The post to load.
  final int id;

  @override
  List<Object?> get props => [id];
}
