import 'package:flutter_clean_starter/core/bloc/async_cubit.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:injectable/injectable.dart';

/// Loads one post. Example of the **Cubit** style: no events, one method
/// per action — here inherited from [AsyncCubit] (`load`, `retry`).
@injectable
class PostDetailCubit extends AsyncCubit<Post, int> {
  /// Creates the cubit.
  PostDetailCubit(this._getPostById);

  final GetPostById _getPostById;

  @override
  FutureResult<Post> execute(int id) => _getPostById(GetPostByIdParams(id: id));
}
