import 'package:flutter_clean_starter/core/data/base_repository.dart';
import 'package:flutter_clean_starter/core/domain/paginated_result.dart';
import 'package:flutter_clean_starter/core/domain/refresh_policy.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';

/// Adds cursor-based pagination caching to a [BaseRepository].
///
/// ## Storage model
/// ```text
/// <baseKey>:page:first     → PaginatedResult<T>  (first page)
/// <baseKey>:page:<cursor>  → PaginatedResult<T>  (following pages)
/// <baseKey>:cursors        → List<String>        (ordered cursor index)
/// ```
/// The index shares its pages' TTL, so the whole chain expires together.
///
/// ## Rules
/// - Call [invalidatePaginatedKey] after any mutation that affects the
///   feed: one stale page breaks cursor continuity for every later page.
/// - Use [refreshPaginatedKey] for pull-to-refresh.
/// - Apply `FetchPolicy.staleWhileRevalidate` to the **first page only**;
///   revalidating a mid-chain page can shift every cursor after it.
///
/// ## Usage
/// ```dart
/// class PostRepositoryImpl extends BaseRepository
///     with PaginatedCacheMixin
///     implements PostRepository {
///   FutureResult<PaginatedResult<Post>> getPosts({String? cursor}) async {
///     final cached = await getCachedPage<Post>('posts', cursor);
///     if (cached != null) return SuccessResult(cached);
///     return safeCall(
///       key: 'noop',
///       cache: false,
///       remote: () async {
///         final page = (await _remote.getPosts(cursor)).toEntities();
///         await cachePage('posts', cursor, page);
///         return page;
///       },
///     );
///   }
/// }
/// ```
mixin PaginatedCacheMixin on BaseRepository {
  static const _first = 'first';

  /// The cached page for [cursor] (`null` = first page), or `null` on a
  /// miss. Never throws.
  Future<PaginatedResult<T>?> getCachedPage<T>(
    String baseKey,
    String? cursor,
  ) async {
    try {
      return await cacheStore.get<PaginatedResult<T>>(
        _pageKey(baseKey, cursor),
      );
    } on CacheException {
      return null;
    }
  }

  /// Rebuilds the full list from cached pages in cursor order.
  ///
  /// Stops at the first missing page or at the last page. One cache lookup
  /// per page — use it for cold-start restoration, not in hot paths.
  Future<List<T>> getAccumulatedItems<T>(String baseKey) async {
    final result = <T>[];
    for (final cursorId in await _readCursors(baseKey)) {
      final page = await getCachedPage<T>(
        baseKey,
        cursorId == _first ? null : cursorId,
      );
      if (page == null) break;
      result.addAll(page.data);
      if (!page.hasMore) break;
    }
    return result;
  }

  /// Caches [page] for [cursor] and records it in the cursor index.
  ///
  /// [ttl] (default: `defaultTtl`) applies to both the page and the index.
  /// Idempotent: caching the same cursor twice does not duplicate it.
  Future<void> cachePage<T>(
    String baseKey,
    String? cursor,
    PaginatedResult<T> page, {
    Duration? ttl,
  }) async {
    final effectiveTtl = ttl ?? defaultTtl;
    await cacheStore.set<PaginatedResult<T>>(
      _pageKey(baseKey, cursor),
      page,
      ttl: effectiveTtl,
    );

    final cursors = await _readCursors(baseKey);
    final cursorId = cursor ?? _first;
    if (!cursors.contains(cursorId)) cursors.add(cursorId);
    // Always rewrite the index to renew its TTL alongside the page.
    await cacheStore.set<List<String>>(
      _indexKey(baseKey),
      cursors,
      ttl: effectiveTtl,
    );
  }

  /// Re-fetches the first page with [fetchFirstPage] and resets the chain.
  ///
  /// With [RefreshPolicy.silentOverwrite] (default) the cache is never left
  /// empty: the new first page replaces the old one, then later pages are
  /// evicted. With [RefreshPolicy.full] the chain is cleared first; if the
  /// fetch then fails, the cache stays empty.
  FutureResult<PaginatedResult<T>> refreshPaginatedKey<T>({
    required String baseKey,
    required Future<PaginatedResult<T>> Function() fetchFirstPage,
    RefreshPolicy policy = RefreshPolicy.silentOverwrite,
    Duration? ttl,
  }) => safeCall(
    key: 'noop',
    cache: false,
    remote: () async {
      final effectiveTtl = ttl ?? defaultTtl;
      if (policy == RefreshPolicy.full) {
        await invalidatePaginatedKey(baseKey);
      }
      // Capture the old cursors before the index is overwritten.
      final staleCursors = await _readCursors(baseKey);

      final freshPage = await fetchFirstPage();
      await cacheStore.set<PaginatedResult<T>>(
        _pageKey(baseKey, null),
        freshPage,
        ttl: effectiveTtl,
      );
      await cacheStore.set<List<String>>(_indexKey(baseKey), [
        _first,
      ], ttl: effectiveTtl);
      await _evictPages(baseKey, staleCursors, preserveFirst: true);
      return freshPage;
    },
  );

  /// Deletes every page and the cursor index for [baseKey].
  Future<void> invalidatePaginatedKey(String baseKey) async {
    final cursors = await _readCursors(baseKey);
    if (cursors.isEmpty) return;
    await _evictPages(baseKey, cursors, preserveFirst: false);
    await cacheStore.delete(_indexKey(baseKey));
  }

  Future<List<String>> _readCursors(String baseKey) async {
    try {
      return List<String>.of(
        await cacheStore.get<List<String>>(_indexKey(baseKey)),
      );
    } on CacheException {
      return <String>[];
    }
  }

  Future<void> _evictPages(
    String baseKey,
    List<String> cursors, {
    required bool preserveFirst,
  }) async {
    for (final cursorId in cursors) {
      if (preserveFirst && cursorId == _first) continue;
      await cacheStore.delete(
        _pageKey(baseKey, cursorId == _first ? null : cursorId),
      );
    }
  }

  String _pageKey(String baseKey, String? cursor) =>
      '$baseKey:page:${cursor ?? _first}';

  String _indexKey(String baseKey) => '$baseKey:cursors';
}
