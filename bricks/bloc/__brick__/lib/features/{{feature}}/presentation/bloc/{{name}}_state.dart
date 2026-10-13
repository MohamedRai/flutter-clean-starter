part of '{{name}}_bloc.dart';

/// States of [{{name.pascalCase()}}Bloc].
sealed class {{name.pascalCase()}}State extends Equatable {
  const {{name.pascalCase()}}State();

  @override
  List<Object?> get props => const [];
}

/// Nothing requested yet.
final class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {
  /// Creates the state.
  const {{name.pascalCase()}}Initial();
}

/// Work in progress.
final class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {
  /// Creates the state.
  const {{name.pascalCase()}}Loading();
}

/// Work finished. Add the resulting data as fields.
final class {{name.pascalCase()}}Success extends {{name.pascalCase()}}State {
  /// Creates the state.
  const {{name.pascalCase()}}Success();
}

/// Work failed.
final class {{name.pascalCase()}}Failure extends {{name.pascalCase()}}State {
  /// Creates the state.
  const {{name.pascalCase()}}Failure(this.failure);

  /// Why it failed.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
