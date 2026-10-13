import 'package:{{package}}/core/constants/app_constants.dart';
import 'package:{{package}}/core/data/base_repository.dart';
import 'package:{{package}}/core/domain/fetch_policy.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{entity}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';
import 'package:injectable/injectable.dart' show LazySingleton;

/// [{{entity.pascalCase()}}Repository] backed by the API with an in-memory cache.
@LazySingleton(as: {{entity.pascalCase()}}Repository)
class {{entity.pascalCase()}}RepositoryImpl extends BaseRepository implements {{entity.pascalCase()}}Repository {
  /// Creates the repository.
  {{entity.pascalCase()}}RepositoryImpl(this._remote, {required super.cacheStore})
    : super(defaultTtl: AppConstants.defaultCacheTtl);

  final {{entity.pascalCase()}}RemoteDataSource _remote;

  static const _key = '{{feature}}.{{entity}}';

  @override
  FutureResultList<{{entity.pascalCase()}}> getAll({bool forceRefresh = false}) => safeCall(
    key: _key,
    policy: forceRefresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
    remote: () async =>
        (await _remote.getAll()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<{{entity.pascalCase()}}> getById(String id) => safeCall(
    key: '$_key:$id',
    policy: FetchPolicy.cacheFirst,
    remote: () async => (await _remote.getById(id)).toEntity(),
  );
}
