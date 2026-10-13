part of '{{name}}_bloc.dart';

/// Events handled by [{{name.pascalCase()}}Bloc].
sealed class {{name.pascalCase()}}Event extends Equatable {
  const {{name.pascalCase()}}Event();

  @override
  List<Object?> get props => const [];
}

/// The screen opened.
final class {{name.pascalCase()}}Started extends {{name.pascalCase()}}Event {
  /// Creates the event.
  const {{name.pascalCase()}}Started();
}
