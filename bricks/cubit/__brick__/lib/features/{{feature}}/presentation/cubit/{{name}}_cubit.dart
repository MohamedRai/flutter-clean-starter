import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:{{package}}/core/error/failures.dart';
import 'package:injectable/injectable.dart' show injectable;

part '{{name}}_state.dart';

/// {{name.sentenceCase()}}.
///
/// Inject use cases through the constructor; never repositories. For a
/// single load/retry flow, extend `AsyncCubit` instead.
@injectable
class {{name.pascalCase()}}Cubit extends Cubit<{{name.pascalCase()}}State> {
  /// Creates the cubit.
  {{name.pascalCase()}}Cubit() : super(const {{name.pascalCase()}}Initial());

  /// Starts the work.
  void load() {
    emit(const {{name.pascalCase()}}Loading());
    // Call a use case here and emit the success or failure state from
    // its Result (make the method `async`).
    emit(const {{name.pascalCase()}}Success());
  }
}
