# Networking

## The client

`NetworkModule` (in `app/di/modules/`) builds one `Dio` with
`DioClientFactory.create`:

- `baseUrl` = `FlavorConfig.apiBaseUrl` (from `env/<flavor>.json`)
- JSON content type, 20 s connect/send/receive timeouts

Interceptors, in order:

| # | Interceptor | Does |
|---|---|---|
| 1 | `AuthTokenInterceptor` | Adds `Authorization: Bearer <token>` from `AppSession`; on 401 calls `session.signOut` (router redirects). Skip per request with `Options(extra: {AuthTokenInterceptor.skipAuthKey: true})`. |
| 2 | `LoggingInterceptor` | Logs requests/responses via `AppLogger`, redacting auth headers. Only when `ENABLE_HTTP_LOGS` is true (never in prod). |
| 3 | `RetryInterceptor` | Retries idempotent requests (`GET`, `PUT`, `DELETE`, …) on timeouts, connection errors, 429, 502–504; exponential back-off, 2 retries. Opt out with `Options(extra: {RetryInterceptor.noRetryKey: true})`. |
| 4 | `ErrorMappingInterceptor` | Attaches the mapped `AppException` to the `DioException`. |

`NetworkInfo` (connectivity_plus) can be passed to a data source to fail
fast when offline. A connected interface doesn't guarantee internet
access, so the HTTP error stays the source of truth.

## Data sources

Remote data sources extend `BaseRemoteDataSource`:

```dart
@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({required super.dio, required super.exceptionMapper});

  @override
  Future<List<PostModel>> getPosts() async {
    final json = await get<List<dynamic>>('/posts');
    return json.cast<Json>().map(PostModel.fromJson).toList();
  }
}
```

`get`/`post`/`put`/`patch`/`delete` run inside `safeCall`, so they only
throw `AppException`s. Paths are relative to `baseUrl`.

### Response envelopes

If your API wraps payloads (`{"data": …, "meta": …}`), override `unwrap`
once in a shared base class and extend it:

```dart
abstract class ApiDataSource extends BaseRemoteDataSource {
  ApiDataSource({required super.dio, required super.exceptionMapper});

  @override
  Object? unwrap(Object? body) => (body! as Map<String, dynamic>)['data'];
}
```

### Error formats

`HttpExceptionMapper` maps by status code and reads common message shapes
(`message`, `error`, `error.message`, `field`). For custom error codes,
subclass it and override `mapResponse`/`extractMessage`, then register it
in `NetworkModule.exceptionMapper`. See [error-handling.md](error-handling.md).

## Adding an endpoint

1. **Model**: `mason make model --feature <f> --name <entity>` → edit fields
   (`@JsonKey(name: 'snake_case')` as needed) → `dart run build_runner build`.
2. **Data source**: add the method to the interface and implementation.
3. **Repository**: add to the contract + implementation (`safeCall` for
   reads with a `FetchPolicy`; `safeWrite` + `invalidateKeys` for writes).
4. **Use case**: `mason make usecase …` (auto-registered in DI).
5. **Tests** for each step (mock `Dio` in data source tests).

The `add-api-endpoint` Claude skill walks through exactly this.

## Caching and fetch policies

`BaseRepository.safeCall(policy: …)`:

| Policy | Behavior |
|---|---|
| `networkOnly` (default) | Always fetch; write cache |
| `cacheOnly` | Read cache; `CacheFailure` on miss |
| `networkFirst` | Fetch; on `NetworkException` fall back to cache |
| `cacheFirst` | Cache if present, else fetch |
| `staleWhileRevalidate` | Return cache now, refresh in background |

The default `DataCacheStore` is in-memory (LRU, TTL, single-flight). For
data that must survive restarts, add a local data source (as the `posts`
feature does) or implement `DataCacheStore` over persistent storage.

Pagination: use `PaginatedResult<T>` + `PaginatedCacheMixin` in the
repository and `PagingCubit` + `PagingListView` in the UI.

## Auth

The demo `AppSession` stores a token in `SecureStorage`. For a real API:

1. Create an `auth` feature (sign-in use case → repository → data source).
2. On success call `AppSession.signIn(token)`; on sign-out `signOut()`.
3. Token refresh is backend-specific: extend `AuthTokenInterceptor.onError`
   to refresh on 401 and replay the request with `dio.fetch`.
