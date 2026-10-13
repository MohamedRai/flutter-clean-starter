/// Controls how a repository balances freshness against latency and
/// offline resilience. Used by `BaseRepository.safeCall`.
///
/// | Policy                  | First source | Fallback | Background refresh |
/// |-------------------------|--------------|----------|--------------------|
/// | [networkOnly]           | Remote       | —        | —                  |
/// | [cacheOnly]             | Cache        | —        | —                  |
/// | [networkFirst]          | Remote       | Cache    | —                  |
/// | [cacheFirst]            | Cache        | Remote   | —                  |
/// | [staleWhileRevalidate]  | Cache        | Remote   | ✓ (always)         |
enum FetchPolicy {
  /// Always fetch from the remote source.
  ///
  /// The cache is written after a successful fetch but never read. Use this
  /// when stale data is never acceptable.
  networkOnly,

  /// Always read from the cache; fails with a `CacheFailure` on a miss.
  ///
  /// Use for fully offline scenarios or when freshness is guaranteed by
  /// another mechanism.
  cacheOnly,

  /// Try the remote source first; fall back to the cache **only** on a
  /// `NetworkException`.
  ///
  /// Server errors are not silenced — they propagate normally.
  networkFirst,

  /// Return cached data when present; fetch remotely only on a miss.
  ///
  /// Use when latency matters more than absolute freshness.
  cacheFirst,

  /// Return cached data immediately (even if stale) and **always** refresh
  /// it in the background.
  ///
  /// Background errors are swallowed. Falls back to a normal network fetch
  /// when nothing is cached.
  staleWhileRevalidate,
}
