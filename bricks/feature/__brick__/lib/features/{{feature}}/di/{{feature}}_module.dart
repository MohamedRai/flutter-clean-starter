import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';
import 'package:{{package}}/features/{{feature}}/domain/usecases/get_{{entity}}_list.dart';
import 'package:injectable/injectable.dart' show lazySingleton, module;

/// Registers the {{feature.sentenceCase()}} use cases (the domain layer
/// stays free of DI annotations). The `usecase` brick appends to this file.
@module
abstract class {{feature.pascalCase()}}Module {
  /// See [Get{{entity.pascalCase()}}List].
  @lazySingleton
  Get{{entity.pascalCase()}}List get{{entity.pascalCase()}}List({{entity.pascalCase()}}Repository repository) => Get{{entity.pascalCase()}}List(repository);
}
