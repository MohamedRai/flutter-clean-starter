import 'package:flutter_clean_starter/core/data/base_remote_data_source.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/data/models/post_model.dart';
import 'package:injectable/injectable.dart';

/// Fetches posts from the API.
///
/// Throws `AppException`s (e.g. `NetworkException`, `NotFoundException`).
abstract interface class PostRemoteDataSource {
  /// `GET /posts`
  Future<List<PostModel>> getPosts();

  /// `GET /posts/{id}`
  Future<PostModel> getPost(int id);
}

/// [PostRemoteDataSource] over HTTP.
@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PostRemoteDataSource {
  /// Creates the data source.
  PostRemoteDataSourceImpl({
    required super.dio,
    required super.exceptionMapper,
  });

  @override
  Future<List<PostModel>> getPosts() async {
    final json = await get<List<dynamic>>('/posts');
    return json.cast<Json>().map(PostModel.fromJson).toList();
  }

  @override
  Future<PostModel> getPost(int id) async =>
      PostModel.fromJson(await get<Json>('/posts/$id'));
}
