import 'dart:async';
import 'dart:collection';

import 'package:flutter_clean_starter/core/cache/cache_entry.dart';
import 'package:flutter_clean_starter/core/cache/data_cache_store.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';

/// In-memory [DataCacheStore] with TTL, LRU eviction and single-flight.
///
/// Data lives for the lifetime of the process. For data that must survive a
/// restart, add a local data source (see the `posts` example feature).
class InMemoryDataCacheStore implements DataCacheStore {
  /// Creates a store holding at most [maxEntries] entries.
  InMemoryDataCacheStore({this.maxEntries = 256, DateTime Function()? clock})
    : assert(maxEntries > 0, 'maxEntries must be positive'),
      _clock = clock ?? DateTime.now;

  /// Maximum number of entries before the least-recently-used is evicted.
  final int maxEntries;

  final DateTime Function() _clock;

  // LinkedHashMap keeps insertion order: re-inserting a key on access moves
  // it to the end, so the first key is always the least recently used.
  final LinkedHashMap<String, CacheEntry<Object?>> _store = LinkedHashMap();

  final Map<String, Future<Object?>> _inFlight = {};

  @override
  Future<T> get<T>(String key) async {
    final entry = _store.remove(key);
    if (entry == null) {
      throw CacheException(message: 'Cache miss for "$key"');
    }
    if (entry.isExpired(_clock())) {
      throw CacheException(message: 'Cache entry "$key" expired');
    }
    final value = entry.value;
    if (value is! T) {
      _store[key] = entry;
      throw CacheException(message: 'Cache entry "$key" is not a $T');
    }
    _store[key] = entry; // mark as most recently used
    return value;
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    _store
      ..remove(key)
      ..[key] = CacheEntry<Object?>(value: value, cachedAt: _clock(), ttl: ttl);
    if (_store.length > maxEntries) {
      _store.remove(_store.keys.first);
    }
  }

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<T> runSingleFlight<T>(String key, Future<T> Function() loader) {
    final existing = _inFlight[key];
    if (existing != null) return existing.then((value) => value as T);

    final future = loader();
    _inFlight[key] = future;
    // whenComplete returns a new future mirroring `future`'s error; nobody
    // listens to it, so ignore() stops it being reported as unhandled.
    future.whenComplete(() => _inFlight.remove(key)).ignore();
    return future;
  }
}
