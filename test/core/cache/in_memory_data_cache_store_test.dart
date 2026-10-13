import 'dart:async';

import 'package:flutter_clean_starter/core/cache/in_memory_data_cache_store.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var now = DateTime(2026);
  DateTime clock() => now;

  late InMemoryDataCacheStore store;

  setUp(() {
    now = DateTime(2026);
    store = InMemoryDataCacheStore(maxEntries: 2, clock: clock);
  });

  test('returns what was set', () async {
    await store.set('a', 1);
    expect(await store.get<int>('a'), 1);
  });

  test('throws CacheException on a miss or a wrong type', () async {
    expect(() => store.get<int>('missing'), throwsA(isA<CacheException>()));
    await store.set('a', 'text');
    expect(() => store.get<int>('a'), throwsA(isA<CacheException>()));
    // The entry survives a wrong-type read.
    expect(await store.get<String>('a'), 'text');
  });

  test('expires entries after their ttl', () async {
    await store.set('a', 1, ttl: const Duration(minutes: 1));
    now = now.add(const Duration(minutes: 2));
    expect(() => store.get<int>('a'), throwsA(isA<CacheException>()));
  });

  test('evicts the least recently used entry', () async {
    await store.set('a', 1);
    await store.set('b', 2);
    await store.get<int>('a'); // a is now most recent
    await store.set('c', 3);
    expect(() => store.get<int>('b'), throwsA(isA<CacheException>()));
    expect(await store.get<int>('a'), 1);
    expect(await store.get<int>('c'), 3);
  });

  test('delete and clear remove entries', () async {
    await store.set('a', 1);
    await store.set('b', 2);
    await store.delete('a');
    expect(() => store.get<int>('a'), throwsA(isA<CacheException>()));
    await store.clear();
    expect(() => store.get<int>('b'), throwsA(isA<CacheException>()));
  });

  test('runSingleFlight shares one in-flight call per key', () async {
    var calls = 0;
    final completer = Completer<int>();
    Future<int> loader() {
      calls++;
      return completer.future;
    }

    final first = store.runSingleFlight('k', loader);
    final second = store.runSingleFlight('k', loader);
    completer.complete(42);
    expect(await first, 42);
    expect(await second, 42);
    expect(calls, 1);

    // Once completed, a new call starts a new flight.
    await store.runSingleFlight('k', () async => calls++);
    expect(calls, 2);
  });
}
