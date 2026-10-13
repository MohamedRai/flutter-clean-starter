import 'package:{{package}}/core/data/base_remote_data_source.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{entity}}_model.dart';
import 'package:injectable/injectable.dart' show LazySingleton;

/// Fetches [{{entity.pascalCase()}}Model]s from the API. Throws `AppException`s.
abstract interface class {{entity.pascalCase()}}RemoteDataSource {
  /// `GET {{{endpoint}}}`
  Future<List<{{entity.pascalCase()}}Model>> getAll();

  /// `GET {{{endpoint}}}/{id}`
  Future<{{entity.pascalCase()}}Model> getById(String id);
}

/// [{{entity.pascalCase()}}RemoteDataSource] over HTTP.
@LazySingleton(as: {{entity.pascalCase()}}RemoteDataSource)
class {{entity.pascalCase()}}RemoteDataSourceImpl extends BaseRemoteDataSource
    implements {{entity.pascalCase()}}RemoteDataSource {
  /// Creates the data source.
  {{entity.pascalCase()}}RemoteDataSourceImpl({
    required super.dio,
    required super.exceptionMapper,
  });

  static const _path = '{{{endpoint}}}';

  @override
  Future<List<{{entity.pascalCase()}}Model>> getAll() async {
    final json = await get<List<dynamic>>(_path);
    return json.cast<Json>().map({{entity.pascalCase()}}Model.fromJson).toList();
  }

  @override
  Future<{{entity.pascalCase()}}Model> getById(String id) async =>
      {{entity.pascalCase()}}Model.fromJson(await get<Json>('$_path/$id'));
}
