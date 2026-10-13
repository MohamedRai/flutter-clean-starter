import 'package:flutter_clean_starter/core/cache/in_memory_data_cache_store.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_clean_starter/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockRemote extends Mock implements PostRemoteDataSource;

class _MockLocal extends Mock implements PostLocalDataSource;

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late PostRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = PostRepositoryImpl(
      remote,
      local,
      cacheStore: InMemoryDataCacheStore(),
    );
    when(() => local.cachePosts(any())).thenAnswer((_) async {});
  });

  group('getPosts', () {
    test('fetches, saves for offline use, and returns entities', () async {
      when(() => remote.getPosts())
          .thenAnswer((_) async => [Fixtures.postModel, Fixtures.postModel2]);

      final result = await repository.getPosts();

      expect(result, const Result.success([Fixtures.post, Fixtures.post2]));
      verify(() => local.cachePosts([Fixtures.postModel, Fixtures.postModel2]))
          .called(1);
    });

    test('serves the in-memory cache on the second call', () async {
      when(() => remote.getPosts())
          .thenAnswer((_) async => [Fixtures.postModel]);
      await repository.getPosts();
      await repository.getPosts();
      verify(() => remote.getPosts()).called(1);
    });

    test('forceRefresh bypasses the in-memory cache', () async {
      when(() => remote.getPosts())
          .thenAnswer((_) async => [Fixtures.postModel]);
      await repository.getPosts();
      await repository.getPosts(forceRefresh: true);
      verify(() => remote.getPosts()).called(2);
    });

    test('falls back to saved posts when offline', () async {
      when(() => remote.getPosts()).thenThrow(const NetworkException());
      when(() => local.getCachedPosts())
          .thenAnswer((_) async => [Fixtures.postModel]);

      final result = await repository.getPosts();

      expect(result, const Result.success([Fixtures.post]));
    });

    test('reports NetworkFailure when offline with nothing saved', () async {
      when(() => remote.getPosts()).thenThrow(const NetworkException());
      when(() => local.getCachedPosts()).thenThrow(const CacheException());

      final result = await repository.getPosts();

      expect(result.failureOrNull(), isA<NetworkFailure>());
    });

    test('does not hide server errors behind the offline cache', () async {
      when(() => remote.getPosts())
          .thenThrow(const ServerException(statusCode: 500));

      final result = await repository.getPosts();

      expect(result.failureOrNull(), isA<ServerFailure>());
      verifyNever(() => local.getCachedPosts());
    });
  });

  group('getPostById', () {
    test('returns the post', () async {
      when(() => remote.getPost(1)).thenAnswer((_) async => Fixtures.postModel);
      expect(
        await repository.getPostById(1),
        const Result.success(Fixtures.post),
      );
    });

    test('falls back to the saved post when offline', () async {
      when(() => remote.getPost(1)).thenThrow(const NetworkException());
      when(() => local.getCachedPost(1))
          .thenAnswer((_) async => Fixtures.postModel);
      expect(
        await repository.getPostById(1),
        const Result.success(Fixtures.post),
      );
    });

    test('maps NotFoundException to NotFoundFailure', () async {
      when(() => remote.getPost(9)).thenThrow(const NotFoundException());
      final result = await repository.getPostById(9);
      expect(result.failureOrNull(), isA<NotFoundFailure>());
    });
  });
}
