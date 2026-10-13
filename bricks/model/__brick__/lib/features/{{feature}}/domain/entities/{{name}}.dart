import 'package:equatable/equatable.dart';

/// A {{name.sentenceCase()}}. Pure Dart: no Flutter, no JSON.
final class {{name.pascalCase()}} extends Equatable {
  /// Creates the entity.
  const {{name.pascalCase()}}({required this.id, required this.name});

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  @override
  List<Object?> get props => [id, name];
}
