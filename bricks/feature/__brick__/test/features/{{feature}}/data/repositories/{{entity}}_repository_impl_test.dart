import 'package:{{package}}/core/cache/in_memory_data_cache_store.dart';
import 'package:{{package}}/core/domain/result.dart';
import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/error/failures.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{entity}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{entity}}_model.dart';
import 'package:{{package}}/features/{{feature}}/data/repositories/{{entity}}_repository_impl.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements {{entity.pascalCase()}}RemoteDataSource;

void main() {
  late _MockRemote remote;
  late {{entity.pascalCase()}}RepositoryImpl repository;
  const model = {{entity.pascalCase()}}Model(id: '1', name: 'name');
  const entity = {{entity.pascalCase()}}(id: '1', name: 'name');

  setUp(() {
    remote = _MockRemote();
    repository = {{entity.pascalCase()}}RepositoryImpl(remote, cacheStore: InMemoryDataCacheStore());
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
