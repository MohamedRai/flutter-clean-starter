/// A cached value of type [T] plus the metadata needed to judge freshness.
///
/// A `null` [ttl] means the entry never expires on its own.
class CacheEntry<T> {
  /// Creates an entry written at [cachedAt].
  const CacheEntry({required this.value, required this.cachedAt, this.ttl});

  /// The cached value.
  final T value;

  /// When the entry was written.
  final DateTime cachedAt;

  /// How long the entry stays fresh; `null` → forever.
  final Duration? ttl;

  /// Whether a [ttl] is set and has elapsed (relative to [now], default
  /// `DateTime.now()`).
  bool isExpired([DateTime? now]) {
    final ttl = this.ttl;
    if (ttl == null) return false;
    return (now ?? DateTime.now()).isAfter(cachedAt.add(ttl));
  }

  @override
  String toString() =>
      'CacheEntry<$T>(cachedAt: $cachedAt, ttl: $ttl, expired: ${isExpired()})';
}
