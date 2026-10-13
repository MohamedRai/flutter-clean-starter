/// A key-value store for cached values of **any** type, used by
/// `BaseRepository` to implement its `FetchPolicy` strategies.
///
/// The store is typed at access: callers state the expected type `T` at
/// each call, and a runtime check guards against mismatches. This avoids one
/// store instance per cached type.
///
/// Implementations should provide:
/// - **TTL** — expired entries behave like misses.
/// - **Bounded size** — e.g. LRU eviction.
/// - **Single-flight** — [runSingleFlight] runs at most one loader per key.
abstract interface class DataCacheStore {
  /// The value cached under [key].
  ///
  /// Throws a `CacheException` when the key is absent, expired, or holds a
  /// value that is not a [T].
  Future<T> get<T>(String key);

  /// Caches [value] under [key], replacing any previous entry.
  Future<void> set<T>(String key, T value, {Duration? ttl});

  /// Removes [key]. No-op when absent.
  Future<void> delete(String key);

  /// Removes every entry.
  Future<void> clear();

  /// Runs [loader] for [key] unless one is already running, in which case
  /// the in-flight future is returned. Does **not** write to the cache.
  Future<T> runSingleFlight<T>(String key, Future<T> Function() loader);
}
