import 'package:{{package}}/core/cache/in_memory_data_cache_store.dart';
import 'package:{{package}}/core/domain/result.dart';
import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/error/failures.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{name}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:{{package}}/features/{{feature}}/data/repositories/{{name}}_repository_impl.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{name}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements {{name.pascalCase()}}RemoteDataSource;

void main() {
  late _MockRemote remote;
  late {{name.pascalCase()}}RepositoryImpl repository;
  const model = {{name.pascalCase()}}Model(id: '1', name: 'name');
  const entity = {{name.pascalCase()}}(id: '1', name: 'name');

  setUp(() {
    remote = _MockRemote();
    repository = {{name.pascalCase()}}RepositoryImpl(remote, cacheStore: InMemoryDataCacheStore());
  });

  test('getAll returns entities and caches them', () async {
    when(() => remote.getAll()).thenAnswer((_) async => [model]);
    expect(await repository.getAll(), const Result.success([entity]));
    await repository.getAll();
    verify(() => remote.getAll()).called(1);
  });

  test('getById maps exceptions to failures', () async {
    when(() => remote.getById('9')).thenThrow(const NotFoundException());
    final result = await repository.getById('9');
    expect(result.failureOrNull(), isA<NotFoundFailure>());
  });
}
