import 'package:{{package}}/core/bloc/async_cubit.dart';
import 'package:{{package}}/core/usecase/usecase.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/usecases/get_{{entity}}_list.dart';
import 'package:injectable/injectable.dart' show injectable;

/// Loads the [{{entity.pascalCase()}}] list. Call `load(const NoParams())`.
@injectable
class {{entity.pascalCase()}}ListCubit extends AsyncCubit<List<{{entity.pascalCase()}}>, NoParams> {
  /// Creates the cubit.
  {{entity.pascalCase()}}ListCubit(this._get{{entity.pascalCase()}}List);

  final Get{{entity.pascalCase()}}List _get{{entity.pascalCase()}}List;

  @override
  FutureResultList<{{entity.pascalCase()}}> execute(NoParams params) => _get{{entity.pascalCase()}}List(params);
}
