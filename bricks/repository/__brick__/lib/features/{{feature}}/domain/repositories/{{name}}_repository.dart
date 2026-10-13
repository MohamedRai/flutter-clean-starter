import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{name}}.dart';

/// Access to [{{name.pascalCase()}}]s. Returns `Failure`s, never throws.
abstract interface class {{name.pascalCase()}}Repository {
  /// Every [{{name.pascalCase()}}]; [forceRefresh] bypasses the in-memory cache.
  FutureResultList<{{name.pascalCase()}}> getAll({bool forceRefresh = false});

  /// The [{{name.pascalCase()}}] with [id].
  FutureResult<{{name.pascalCase()}}> getById(String id);
}
