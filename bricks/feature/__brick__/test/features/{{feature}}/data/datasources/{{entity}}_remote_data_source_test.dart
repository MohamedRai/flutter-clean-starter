import 'package:dio/dio.dart';
import 'package:{{package}}/core/error/exceptions.dart';
import 'package:{{package}}/core/network/http_exception_mapper.dart';
import 'package:{{package}}/features/{{feature}}/data/datasources/{{entity}}_remote_data_source.dart';
import 'package:{{package}}/features/{{feature}}/data/models/{{entity}}_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late {{entity.pascalCase()}}RemoteDataSourceImpl dataSource;
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
    dataSource = {{entity.pascalCase()}}RemoteDataSourceImpl(
      dio: dio,
      exceptionMapper: const HttpExceptionMapper(),
    );
  });

  test('getAll decodes the list', () async {
    stubGet(() async => ok([json]));
    expect(await dataSource.getAll(), [const {{entity.pascalCase()}}Model(id: '1', name: 'name')]);
  });

  test('getById decodes one item', () async {
    stubGet(() async => ok(json));
    expect(await dataSource.getById('1'), const {{entity.pascalCase()}}Model(id: '1', name: 'name'));
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
