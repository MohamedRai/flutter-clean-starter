{{#is_remote}}import 'package:dio/dio.dart';
import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/network/http_exception_mapper.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{name}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late {{name.pascalCase()}}RemoteDataSourceImpl dataSource;
  const json = <String, dynamic>{'id': '1', 'name': 'name'};

  void stubGet(Future<Response<Object?>> Function() answer) => when(
    () => dio.get<Object?>(
      any(),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).thenAnswer((_) => answer());

  Response<Object?> ok(Object? data) => Response<Object?>(
    requestOptions: RequestOptions(),
    statusCode: 200,
    data: data,
  );

  setUp(() {
    dio = _MockDio();
    dataSource = {{name.pascalCase()}}RemoteDataSourceImpl(
      dio: dio,
      exceptionMapper: const HttpExceptionMapper(),
    );
  });

  test('getAll decodes the list', () async {
    stubGet(() async => ok([json]));
    expect(await dataSource.getAll(), [const {{name.pascalCase()}}Model(id: '1', name: 'name')]);
  });

  test('getById decodes one item', () async {
    stubGet(() async => ok(json));
    expect(await dataSource.getById('1'), const {{name.pascalCase()}}Model(id: '1', name: 'name'));
  });

  test('maps Dio errors to AppExceptions', () {
    stubGet(
      () async => throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(dataSource.getAll, throwsA(isA<NetworkException>()));
  });
}
{{/is_remote}}{{#is_local}}import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/storage/key_value_storage.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{name}}_local_data_source.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements KeyValueStorage;

void main() {
  late _MockStorage storage;
  late {{name.pascalCase()}}LocalDataSourceImpl dataSource;
  const key = {{name.pascalCase()}}LocalDataSourceImpl.cacheKey;
  const item = {{name.pascalCase()}}Model(id: '1', name: 'name');

  setUp(() {
    storage = _MockStorage();
    dataSource = {{name.pascalCase()}}LocalDataSourceImpl(storage);
  });

  test('saveAll then getAll round-trips', () async {
    String? stored;
    when(() => storage.setString(key, any())).thenAnswer((i) async {
      stored = i.positionalArguments[1] as String;
    });
    await dataSource.saveAll([item]);
    when(() => storage.getString(key)).thenReturn(stored);
    expect(await dataSource.getAll(), [item]);
  });

  test('getAll throws CacheException when empty or corrupt', () {
    when(() => storage.getString(key)).thenReturn(null);
    expect(dataSource.getAll, throwsA(isA<CacheException>()));
    when(() => storage.getString(key)).thenReturn('{not json');
    expect(dataSource.getAll, throwsA(isA<CacheException>()));
  });
}
{{/is_local}}