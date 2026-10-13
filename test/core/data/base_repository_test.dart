import 'package:flutter_clean_starter/core/cache/in_memory_data_cache_store.dart';
import 'package:flutter_clean_starter/core/data/base_repository.dart';
import 'package:flutter_clean_starter/core/domain/fetch_policy.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRepository extends BaseRepository {
  _TestRepository(InMemoryDataCacheStore store) : super(cacheStore: store);
}

void main() {
  late InMemoryDataCacheStore store;
  late _TestRepository repository;
  late int calls;

  Future<String> remoteOk() async {
    calls++;
    return 'fresh';
  }

  Future<String> remoteOffline() async {
    calls++;
    throw const NetworkException();
  }

  setUp(() {
    store = InMemoryDataCacheStore();
    repository = _TestRepository(store);
    calls = 0;
  });

  group('safeCall', () {
    test('networkOnly fetches and writes the cache', () async {
      final result = await repository.safeCall(key: 'k', remote: remoteOk);
      expect(result, const Result.success('fresh'));
      expect(await store.get<String>('k'), 'fresh');
    });

    test('cacheOnly reads the cache, or fails with CacheFailure', () async {
      final miss = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.cacheOnly,
      );
      expect(miss.failureOrNull(), isA<CacheFailure>());

      await store.set('k', 'cached');
      final hit = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.cacheOnly,
      );
      expect(hit.getOrNull(), 'cached');
      expect(calls, 0);
    });

    test('cacheFirst uses the cache and only fetches on a miss', () async {
      final first = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.cacheFirst,
      );
      final second = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.cacheFirst,
      );
      expect(first.getOrNull(), 'fresh');
      expect(second.getOrNull(), 'fresh');
      expect(calls, 1);
    });

    test('networkFirst falls back to the cache when offline', () async {
      await store.set('k', 'cached');
      final result = await repository.safeCall(
        key: 'k',
        remote: remoteOffline,
        policy: FetchPolicy.networkFirst,
      );
      expect(result.getOrNull(), 'cached');
    });

    test(
      'networkFirst fails with NetworkFailure when offline and no cache',
      () async {
        final result = await repository.safeCall(
          key: 'k',
          remote: remoteOffline,
          policy: FetchPolicy.networkFirst,
        );
        expect(result.failureOrNull(), isA<NetworkFailure>());
      },
    );

    test('staleWhileRevalidate returns cache, then refreshes it', () async {
      await store.set('k', 'stale');
      final seen = <String>[];
      final result = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.staleWhileRevalidate,
        onSuccess: seen.add,
      );
      expect(result.getOrNull(), 'stale');
      await pumpEventQueue();
      expect(await store.get<String>('k'), 'fresh');
      expect(seen, ['stale', 'fresh']);
    });

    test('staleWhileRevalidate swallows background errors', () async {
      await store.set('k', 'stale');
      final result = await repository.safeCall(
        key: 'k',
        remote: remoteOffline,
        policy: FetchPolicy.staleWhileRevalidate,
      );
      await pumpEventQueue();
      expect(result.getOrNull(), 'stale');
    });

    test('staleWhileRevalidate fetches when nothing is cached', () async {
      final result = await repository.safeCall(
        key: 'k',
        remote: remoteOk,
        policy: FetchPolicy.staleWhileRevalidate,
      );
      expect(result.getOrNull(), 'fresh');
    });

    test('cache: false bypasses the store entirely', () async {
      await repository.safeCall(key: 'k', remote: remoteOk, cache: false);
      expect(() => store.get<String>('k'), throwsA(isA<CacheException>()));
    });

    test('maps AppException, Exception and TypeError to failures', () async {
      final app = await repository.safeCall<String>(
        key: 'a',
        remote: () async => throw const NotFoundException(),
      );
      final generic = await repository.safeCall<String>(
        key: 'b',
        remote: () async => throw Exception('boom'),
      );
      final type = await repository.safeCall<String>(
        key: 'c',
        remote: () async => (null as dynamic) as String,
      );
      expect(app.failureOrNull(), isA<NotFoundFailure>());
      expect(generic.failureOrNull(), isA<UnknownFailure>());
      expect(type.failureOrNull(), isA<UnknownFailure>());
    });
  });

  group('safeWrite', () {
    test('updates then invalidates keys and calls onSuccess', () async {
      await store.set('list', 'old');
      var succeeded = false;
      final result = await repository.safeWrite(
        write: () async => 'saved',
        updateKeys: {'item': 'saved'},
        invalidateKeys: ['list'],
        onSuccess: (_) => succeeded = true,
      );
      expect(result.getOrNull(), 'saved');
      expect(await store.get<String>('item'), 'saved');
      expect(() => store.get<String>('list'), throwsA(isA<CacheException>()));
      expect(succeeded, isTrue);
    });

    test('calls onFailure with the mapped failure', () async {
      Failure? seen;
      final result = await repository.safeWrite<void>(
        write: () async => throw const ForbiddenException(),
        onFailure: (f) => seen = f,
      );
      expect(result.failureOrNull(), isA<ForbiddenFailure>());
      expect(seen, isA<ForbiddenFailure>());
    });
  });

  test('invalidate and invalidateAll clear the store', () async {
    await store.set('a', 1);
    await store.set('b', 2);
    await repository.invalidate('a');
    expect(() => store.get<int>('a'), throwsA(isA<CacheException>()));
    await repository.invalidateAll();
    expect(() => store.get<int>('b'), throwsA(isA<CacheException>()));
  });
}
