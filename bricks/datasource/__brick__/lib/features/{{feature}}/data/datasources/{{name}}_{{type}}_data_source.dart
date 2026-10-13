{{#is_remote}}import 'package:{{package}}/core/data/base_remote_data_source.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:injectable/injectable.dart' show LazySingleton;

/// Fetches [{{name.pascalCase()}}Model]s from the API. Throws `AppException`s.
abstract interface class {{name.pascalCase()}}RemoteDataSource {
  /// `GET {{{endpoint}}}`
  Future<List<{{name.pascalCase()}}Model>> getAll();

  /// `GET {{{endpoint}}}/{id}`
  Future<{{name.pascalCase()}}Model> getById(String id);
}

/// [{{name.pascalCase()}}RemoteDataSource] over HTTP.
@LazySingleton(as: {{name.pascalCase()}}RemoteDataSource)
class {{name.pascalCase()}}RemoteDataSourceImpl extends BaseRemoteDataSource
    implements {{name.pascalCase()}}RemoteDataSource {
  /// Creates the data source.
  {{name.pascalCase()}}RemoteDataSourceImpl({
    required super.dio,
    required super.exceptionMapper,
  });

  static const _path = '{{{endpoint}}}';

  @override
  Future<List<{{name.pascalCase()}}Model>> getAll() async {
    final json = await get<List<dynamic>>(_path);
    return json.cast<Json>().map({{name.pascalCase()}}Model.fromJson).toList();
  }

  @override
  Future<{{name.pascalCase()}}Model> getById(String id) async =>
      {{name.pascalCase()}}Model.fromJson(await get<Json>('$_path/$id'));
}
{{/is_remote}}{{#is_local}}import 'dart:convert';

import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/storage/key_value_storage.dart';
import 'package:{{package}}/core/utils/typedefs.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:injectable/injectable.dart' show LazySingleton;

/// Keeps [{{name.pascalCase()}}Model]s on the device. Throws [CacheException] on a miss.
abstract interface class {{name.pascalCase()}}LocalDataSource {
  /// The saved items.
  Future<List<{{name.pascalCase()}}Model>> getAll();

  /// Replaces the saved items.
  Future<void> saveAll(List<{{name.pascalCase()}}Model> items);
}

/// [{{name.pascalCase()}}LocalDataSource] storing JSON in [KeyValueStorage].
@LazySingleton(as: {{name.pascalCase()}}LocalDataSource)
class {{name.pascalCase()}}LocalDataSourceImpl implements {{name.pascalCase()}}LocalDataSource {
  /// Creates the data source.
  const {{name.pascalCase()}}LocalDataSourceImpl(this._storage);

  /// Storage key.
  static const cacheKey = '{{feature}}.{{name}}.cache';

  final KeyValueStorage _storage;

  @override
  Future<List<{{name.pascalCase()}}Model>> getAll() async {
    final raw = _storage.getString(cacheKey);
    if (raw == null) throw const CacheException(message: 'Nothing cached');
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .cast<Json>()
          .map({{name.pascalCase()}}Model.fromJson)
          .toList();
    } on Object catch (e) {
      throw CacheException(message: 'Unreadable cache', cause: e);
    }
  }

  @override
  Future<void> saveAll(List<{{name.pascalCase()}}Model> items) => _storage.setString(
    cacheKey,
    jsonEncode(items.map((i) => i.toJson()).toList()),
  );
}
{{/is_local}}