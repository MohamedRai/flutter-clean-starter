import 'package:flutter_clean_starter/core/data/domain_convertible.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

/// The JSON representation of a [Post] (API and local cache).
@freezed
abstract class PostModel with _$PostModel implements DomainConvertible<Post> {
  /// Creates the model.
  const factory PostModel({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _PostModel;

  const PostModel._();

  /// Decodes a JSON object.
  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  /// Builds the model from a domain [post].
  factory PostModel.fromEntity(Post post) => PostModel(
    id: post.id,
    userId: post.userId,
    title: post.title,
    body: post.body,
  );

  @override
  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}
