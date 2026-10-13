import 'package:equatable/equatable.dart';

/// A {{entity.sentenceCase()}}. Pure Dart: no Flutter, no JSON.
final class {{entity.pascalCase()}} extends Equatable {
  /// Creates the entity.
  const {{entity.pascalCase()}}({required this.id, required this.name});

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  @override
  List<Object?> get props => [id, name];
}
