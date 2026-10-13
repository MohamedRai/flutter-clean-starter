import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_posts.dart';
import 'package:injectable/injectable.dart';

part 'posts_event.dart';
part 'posts_state.dart';

/// Drives the posts list. Example of the **Bloc** style: explicit events,
/// with per-event concurrency control.
///
/// - [PostsRequested] is `droppable`: taps while loading are ignored.
/// - [PostsRefreshed] is `restartable`: a new pull cancels the previous one.
@injectable
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  /// Creates the bloc.
  PostsBloc(this._getPosts) : super(const PostsInitial()) {
    on<PostsRequested>(_onRequested, transformer: droppable());
    on<PostsRefreshed>(_onRefreshed, transformer: restartable());
  }

  final GetPosts _getPosts;

  Future<void> _onRequested(
    PostsRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());
    final result = await _getPosts(const GetPostsParams());
    emit(switch (result) {
      SuccessResult(:final value) => PostsLoaded(value),
      FailureResult(:final failure) => PostsFailure(failure),
    });
  }

  Future<void> _onRefreshed(
    PostsRefreshed event,
    Emitter<PostsState> emit,
  ) async {
    final previous = state;
    final result = await _getPosts(const GetPostsParams(forceRefresh: true));
    emit(switch ((result, previous)) {
      (SuccessResult(:final value), _) => PostsLoaded(value),
      // Keep showing what we had; surface the error once.
      (FailureResult(:final failure), PostsLoaded(:final posts)) => PostsLoaded(
        posts,
        refreshFailure: failure,
      ),
      (FailureResult(:final failure), _) => PostsFailure(failure),
    });
  }
}
