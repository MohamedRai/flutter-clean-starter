part of 'posts_bloc.dart';

/// States of [PostsBloc].
sealed class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object?> get props => const [];
}

/// Nothing requested yet.
final class PostsInitial extends PostsState {
  /// Creates the state.
  const PostsInitial();
}

/// First load in progress (no data to show yet).
final class PostsLoading extends PostsState {
  /// Creates the state.
  const PostsLoading();
}

/// Posts are available (possibly empty).
final class PostsLoaded extends PostsState {
  /// Creates the state.
  const PostsLoaded(this.posts, {this.refreshFailure});

  /// The posts to display.
  final List<Post> posts;

  /// Set when a pull-to-refresh failed; [posts] still holds the previous
  /// data. Shown once as a snackbar.
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [posts, refreshFailure];
}

/// The first load failed and there is nothing to show.
final class PostsFailure extends PostsState {
  /// Creates the state.
  const PostsFailure(this.failure);

  /// Why loading failed.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
