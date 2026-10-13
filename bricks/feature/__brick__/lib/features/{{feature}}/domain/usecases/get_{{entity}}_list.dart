import 'package:{{package}}/core/usecase/usecase.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';

/// Lists every [{{entity.pascalCase()}}].
class Get{{entity.pascalCase()}}List implements UseCase<List<{{entity.pascalCase()}}>, NoParams> {
  /// Creates the use case.
  const Get{{entity.pascalCase()}}List(this._repository);

  final {{entity.pascalCase()}}Repository _repository;

  @override
  FutureResultList<{{entity.pascalCase()}}> call(NoParams params) => _repository.getAll();
}
