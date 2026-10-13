import 'dart:async';

import 'package:flutter_clean_starter/core/cache/data_cache_store.dart';
import 'package:flutter_clean_starter/core/domain/fetch_policy.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';

/// Base class for repository implementations.
///
/// It is the boundary where exceptions become values: every public method of
/// a repository should go through [safeCall] (reads) or [safeWrite]
/// (mutations), both of which return a [Result] and never throw.
///
/// ## What it gives you
/// - **Fetch strategies** — five [FetchPolicy] modes, including
///   stale-while-revalidate, backed by [cacheStore].
/// - **Single-flight** — concurrent identical requests share one call.
/// - **Mutations** — [safeWrite] with cache invalidation / update.
/// - **Error mapping** — [AppException]s become typed [Failure]s. A
///   `TypeError` (typically a bad cast in `fromJson` when the API returns an
///   unexpected shape) becomes an [UnknownFailure] instead of crashing.
///
/// ## Read example
/// ```dart
/// FutureResult<List<Post>> getPosts() => safeCall(
///   key: 'posts',
///   policy: FetchPolicy.staleWhileRevalidate,
///   remote: () async {
///     final models = await _remote.getPosts();
///     return models.map((m) => m.toEntity()).toList();
///   },
/// );
/// ```
///
/// ## Write example
/// ```dart
/// FutureResultVoid deletePost(int id) => safeWrite(
///   write: () => _remote.deletePost(id),
///   invalidateKeys: ['posts', 'post:$id'],
/// );
/// ```
///
/// ## Opting out of caching
/// Pass `cache: false` to [safeCall] for one-shot requests; `key` is then
/// ignored, so pass a sentinel such as `'noop'`.
abstract class BaseRepository {
  /// Creates the repository.
  ///
  /// [defaultTtl] applies to every cache write unless overridden per call.
  /// Leaving it `null` means cached entries never expire — set it.
  const BaseRepository({required this.cacheStore, this.defaultTtl});

  /// The structured-data cache behind every [FetchPolicy].
  final DataCacheStore cacheStore;

  /// TTL applied to cache writes when a call does not pass its own.
  final Duration? defaultTtl;

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Runs a **read**: fetch with [remote] according to [policy], caching the
  /// result under [key].
  ///
  /// - [remote] is required even for [FetchPolicy.cacheOnly] (it is simply
  ///   not called).
  /// - [cache] `false` bypasses [cacheStore] entirely.
  /// - [ttl] overrides [defaultTtl] for this call.
  /// - [onSuccess] runs after any success, cached or fresh. With
  ///   [FetchPolicy.staleWhileRevalidate] it can run twice (cached value,
  ///   then refreshed value), so keep it idempotent.
  FutureResult<T> safeCall<T>({
    required String key,
    required Future<T> Function() remote,
    FetchPolicy policy = FetchPolicy.networkOnly,
    bool cache = true,
    Duration? ttl,
    FutureOr<void> Function(T result)? onSuccess,
  }) => _guard(() async {
    final effectiveTtl = ttl ?? defaultTtl;
    final T value;
    if (!cache) {
      value = await remote();
    } else {
      value = await switch (policy) {
        FetchPolicy.networkOnly => _networkOnly(key, remote, effectiveTtl),
        FetchPolicy.cacheOnly => cacheStore.get<T>(key),
        FetchPolicy.networkFirst => _networkFirst(key, remote, effectiveTtl),
        FetchPolicy.cacheFirst => _cacheFirst(key, remote, effectiveTtl),
        FetchPolicy.staleWhileRevalidate => _staleWhileRevalidate(
          key,
          remote,
          effectiveTtl,
          onSuccess,
        ),
      };
    }
    if (onSuccess != null) await onSuccess(value);
    return value;
  });

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Runs a **write** (create / update / delete) and keeps the cache
  /// consistent afterwards. Never reads from the cache.
  ///
  /// - [updateKeys] are written first (`key → value`), then
  ///   [invalidateKeys] are deleted — so if both name a key, it is deleted.
  ///   Prefer invalidation when the server may transform the data.
  /// - [onSuccess] runs after the cache operations complete.
  /// - [onFailure] runs on failure — use it to roll back optimistic UI.
  FutureResult<T> safeWrite<T>({
    required Future<T> Function() write,
    List<String> invalidateKeys = const [],
    Map<String, Object?> updateKeys = const {},
    Duration? ttl,
    FutureOr<void> Function(T result)? onSuccess,
    FutureOr<void> Function(Failure failure)? onFailure,
  }) async {
    final result = await _guard(() async {
      final value = await write();
      final effectiveTtl = ttl ?? defaultTtl;
      for (final MapEntry(:key, :value) in updateKeys.entries) {
        await cacheStore.set(key, value, ttl: effectiveTtl);
      }
      for (final key in invalidateKeys) {
        await cacheStore.delete(key);
      }
      if (onSuccess != null) await onSuccess(value);
      return value;
    });
    if (result case FailureResult(:final failure) when onFailure != null) {
      await onFailure(failure);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Cache helpers
  // ---------------------------------------------------------------------------

  /// Removes the cache entry for [key].
  Future<void> invalidate(String key) => cacheStore.delete(key);

  /// Removes every cache entry — e.g. on sign-out.
  Future<void> invalidateAll() => cacheStore.clear();

  // ---------------------------------------------------------------------------
  // Strategies
  // ---------------------------------------------------------------------------

  Future<T> _networkOnly<T>(
    String key,
    Future<T> Function() remote,
    Duration? ttl,
  ) async {
    final value = await cacheStore.runSingleFlight(key, remote);
    await cacheStore.set<T>(key, value, ttl: ttl);
    return value;
  }

  Future<T> _networkFirst<T>(
    String key,
    Future<T> Function() remote,
    Duration? ttl,
  ) async {
    try {
      return await _networkOnly(key, remote, ttl);
    } on NetworkException {
      try {
        return await cacheStore.get<T>(key);
      } on CacheException {
        throw const NetworkException(message: 'Offline and nothing cached');
      }
    }
  }

  Future<T> _cacheFirst<T>(
    String key,
    Future<T> Function() remote,
    Duration? ttl,
  ) async {
    try {
      return await cacheStore.get<T>(key);
    } on CacheException {
      return await _networkOnly(key, remote, ttl);
    }
  }

  Future<T> _staleWhileRevalidate<T>(
    String key,
    Future<T> Function() remote,
    Duration? ttl,
    FutureOr<void> Function(T result)? onSuccess,
  ) async {
    final T cached;
    try {
      cached = await cacheStore.get<T>(key);
    } on CacheException {
      return await _networkOnly(key, remote, ttl);
    }
    unawaited(_backgroundRefresh(key, remote, ttl, onSuccess));
    return cached;
  }

  /// Refreshes [key] silently. Errors are logged, never surfaced: the caller
  /// already received the cached value.
  Future<void> _backgroundRefresh<T>(
    String key,
    Future<T> Function() remote,
    Duration? ttl,
    FutureOr<void> Function(T result)? onSuccess,
  ) async {
    try {
      final fresh = await _networkOnly(key, remote, ttl);
      if (onSuccess != null) await onSuccess(fresh);
    } on Object catch (error, stackTrace) {
      AppLogger.warning('Background refresh of "$key" failed', error: error);
      AppLogger.debug('$stackTrace');
    }
  }

  /// Runs [body] and converts anything it throws into a [FailureResult].
  FutureResult<T> _guard<T>(Future<T> Function() body) async {
    try {
      return SuccessResult(await body());
    } on AppException catch (e) {
      return FailureResult(Failure.fromException(e));
    } on Exception catch (e, stackTrace) {
      AppLogger.error(
        '$runtimeType: unexpected exception',
        error: e,
        stackTrace: stackTrace,
      );
      return FailureResult(UnknownFailure(message: '$e'));
      // A malformed API response surfaces as a TypeError from a bad cast in
      // fromJson. Only TypeError is caught: AssertionErrors still crash in
      // debug builds, as they should.
      // ignore: avoid_catching_errors
    } on TypeError catch (e, stackTrace) {
      AppLogger.error(
        '$runtimeType: malformed data',
        error: e,
        stackTrace: stackTrace,
      );
      return FailureResult(UnknownFailure(message: '$e'));
    }
  }
}
