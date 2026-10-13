import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:{{package}}/core/error/failures.dart';
import 'package:injectable/injectable.dart' show injectable;

part '{{name}}_event.dart';
part '{{name}}_state.dart';

/// {{name.sentenceCase()}}.
///
/// Inject use cases through the constructor; never repositories.
@injectable
class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  /// Creates the bloc.
  {{name.pascalCase()}}Bloc() : super(const {{name.pascalCase()}}Initial()) {
    on<{{name.pascalCase()}}Started>(_onStarted, transformer: droppable());
  }

  void _onStarted({{name.pascalCase()}}Started event, Emitter<{{name.pascalCase()}}State> emit) {
    emit(const {{name.pascalCase()}}Loading());
    // Call a use case here and emit the success or failure state from
    // its Result (make the handler `async`).
    emit(const {{name.pascalCase()}}Success());
  }
}
