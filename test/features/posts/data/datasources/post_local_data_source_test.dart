import 'dart:convert';

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockStorage extends Mock implements KeyValueStorage;

void main() {
  late _MockStorage storage;
  late PostLocalDataSourceImpl dataSource;
  const key = PostLocalDataSourceImpl.cacheKey;

  setUp(() {
    storage = _MockStorage();
    dataSource = PostLocalDataSourceImpl(storage);
  });

  test('cachePosts stores the posts as JSON', () async {
    when(() => storage.setString(any(), any())).thenAnswer((_) async {});
    await dataSource.cachePosts([Fixtures.postModel]);
    verify(() => storage.setString(key, jsonEncode([Fixtures.postJson])))
        .called(1);
  });

  test('getCachedPosts decodes stored posts', () async {
    when(() => storage.getString(key))
        .thenReturn(jsonEncode([Fixtures.postJson]));
    expect(await dataSource.getCachedPosts(), [Fixtures.postModel]);
  });

  test('getCachedPosts throws CacheException when empty', () {
    when(() => storage.getString(key)).thenReturn(null);
    expect(dataSource.getCachedPosts, throwsA(isA<CacheException>()));
  });

  test('getCachedPosts throws CacheException when corrupt', () {
    when(() => storage.getString(key)).thenReturn('{not json');
    expect(dataSource.getCachedPosts, throwsA(isA<CacheException>()));
  });

  test('getCachedPost finds a post or throws CacheException', () async {
    when(() => storage.getString(key))
        .thenReturn(jsonEncode([Fixtures.postJson]));
    expect(await dataSource.getCachedPost(1), Fixtures.postModel);
    expect(() => dataSource.getCachedPost(99), throwsA(isA<CacheException>()));
  });
}
