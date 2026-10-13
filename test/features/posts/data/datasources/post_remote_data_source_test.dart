import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/http_exception_mapper.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late PostRemoteDataSourceImpl dataSource;

  Response<Object?> ok(Object? data, String path) => Response<Object?>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );

  void stubGet(String path, Future<Response<Object?>> Function() answer) {
    when(
      () => dio.get<Object?>(
        path,
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) => answer());
  }

  setUp(() {
    dio = _MockDio();
    dataSource = PostRemoteDataSourceImpl(
      dio: dio,
      exceptionMapper: const HttpExceptionMapper(),
    );
  });

  group('getPosts', () {
    test('GETs /posts and decodes the list', () async {
      stubGet('/posts', () async => ok([Fixtures.postJson], '/posts'));
      expect(await dataSource.getPosts(), [Fixtures.postModel]);
    });

    test('maps Dio errors to AppExceptions', () async {
      stubGet(
        '/posts',
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/posts'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(dataSource.getPosts, throwsA(isA<NetworkException>()));
    });

    test('maps a malformed body to an AppException', () async {
      stubGet('/posts', () async => ok({'not': 'a list'}, '/posts'));
      expect(dataSource.getPosts, throwsA(isA<AppException>()));
    });
  });

  group('getPost', () {
    test('GETs /posts/{id}', () async {
      stubGet('/posts/1', () async => ok(Fixtures.postJson, '/posts/1'));
      expect(await dataSource.getPost(1), Fixtures.postModel);
    });

    test('maps 404 to NotFoundException', () async {
      final options = RequestOptions(path: '/posts/9');
      stubGet(
        '/posts/9',
        () async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<Object?>(requestOptions: options, statusCode: 404),
        ),
      );
      expect(() => dataSource.getPost(9), throwsA(isA<NotFoundException>()));
    });
  });
}
