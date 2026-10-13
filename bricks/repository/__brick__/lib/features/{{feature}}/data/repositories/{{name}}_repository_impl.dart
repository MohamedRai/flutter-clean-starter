import 'package:{{package}}/core/constants/app_constants.dart';
import 'package:{{package}}/core/data/base_repository.dart';
import 'package:{{package}}/core/domain/fetch_policy.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{name}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{name}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/repositories/{{name}}_repository.dart';
import 'package:injectable/injectable.dart' show LazySingleton;

/// [{{name.pascalCase()}}Repository] backed by the API with an in-memory cache.
@LazySingleton(as: {{name.pascalCase()}}Repository)
class {{name.pascalCase()}}RepositoryImpl extends BaseRepository implements {{name.pascalCase()}}Repository {
  /// Creates the repository.
  {{name.pascalCase()}}RepositoryImpl(this._remote, {required super.cacheStore})
    : super(defaultTtl: AppConstants.defaultCacheTtl);

  final {{name.pascalCase()}}RemoteDataSource _remote;

  static const _key = '{{feature}}.{{name}}';

  @override
  FutureResultList<{{name.pascalCase()}}> getAll({bool forceRefresh = false}) => safeCall(
    key: _key,
    policy: forceRefresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
    remote: () async =>
        (await _remote.getAll()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<{{name.pascalCase()}}> getById(String id) => safeCall(
    key: '$_key:$id',
    policy: FetchPolicy.cacheFirst,
    remote: () async => (await _remote.getById(id)).toEntity(),
  );
}
