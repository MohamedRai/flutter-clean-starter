import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';

/// Access to [{{entity.pascalCase()}}]s. Returns `Failure`s, never throws.
abstract interface class {{entity.pascalCase()}}Repository {
  /// Every [{{entity.pascalCase()}}]; [forceRefresh] bypasses the in-memory cache.
  FutureResultList<{{entity.pascalCase()}}> getAll({bool forceRefresh = false});

  /// The [{{entity.pascalCase()}}] with [id].
  FutureResult<{{entity.pascalCase()}}> getById(String id);
}
