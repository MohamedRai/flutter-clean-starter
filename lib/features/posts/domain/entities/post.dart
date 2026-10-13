import 'package:equatable/equatable.dart';

/// A blog post. Pure Dart: no Flutter, no JSON.
final class Post extends Equatable {
  /// Creates a post.
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Unique identifier.
  final int id;

  /// The author's user id.
  final int userId;

  /// Headline.
  final String title;

  /// Full text.
  final String body;

  @override
  List<Object?> get props => [id, userId, title, body];
}
