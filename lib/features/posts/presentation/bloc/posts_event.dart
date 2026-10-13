part of 'posts_bloc.dart';

/// Events handled by [PostsBloc].
sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => const [];
}

/// The list page opened: load posts (cached data is fine).
final class PostsRequested extends PostsEvent {
  /// Creates the event.
  const PostsRequested();
}

/// The user pulled to refresh: bypass caches.
final class PostsRefreshed extends PostsEvent {
  /// Creates the event.
  const PostsRefreshed();
}
