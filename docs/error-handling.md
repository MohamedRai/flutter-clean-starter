# Error handling

Exceptions stay in the data layer; everything above it works with values.

```mermaid
flowchart LR
  A[Dio / IO error] -->|ErrorMappingInterceptor<br/>HttpExceptionMapper| B[AppException]
  B -->|thrown by data source| C[BaseRepository]
  C -->|Failure.fromException| D["FailureResult(Failure)"]
  D --> E[Bloc state]
  E -->|failure.localizedMessage| F[UI text]
```

## Exceptions (data layer) — `core/error/exceptions.dart`

`AppException` is sealed:

| Exception | Raised for |
|---|---|
| `NetworkException` | offline, timeouts, connection errors, bad certificate |
| `ServerException(statusCode)` | 5xx and unexpected statuses, malformed bodies |
| `BadRequestException` | 400, 409 |
| `UnauthorizedException` | 401 |
| `ForbiddenException` | 403 |
| `NotFoundException` | 404 |
| `ValidationException(field)` | 422 / local validation |
| `RateLimitException(retryAfter)` | 429 (reads `Retry-After` / `RateLimit-Reset`) |
| `CacheException` | cache miss, expired or unreadable local data |
| `UnknownException` | anything else |

Data sources extend `BaseDataSource` / `BaseRemoteDataSource`, whose
`safeCall` converts **anything** thrown into an `AppException` through the
injected `ExceptionMapper` — so callers only ever see `AppException`s.

## Failures (domain and up) — `core/error/failures.dart`

Each exception has a matching `Failure` (`NetworkFailure`, `ServerFailure`,
…, plus `ValidationFailure<TField>` and `ValidationFailures<TField>` for
forms). Failures are `Equatable` values carried by `Result<T>`:

```dart
final result = await getPosts(const GetPostsParams());
switch (result) {
  case SuccessResult(:final value): emit(PostsLoaded(value));
  case FailureResult(:final failure): emit(PostsFailure(failure));
}
```

`failure.isRetryable` is true for network, server and rate-limit failures.

## Repositories never throw

`BaseRepository.safeCall` / `safeWrite` catch:

- `AppException` → `Failure.fromException`
- any other `Exception` → `UnknownFailure` (logged)
- `TypeError` (bad cast in `fromJson` when the API changes shape) →
  `UnknownFailure` (logged). `AssertionError`s still crash in debug.

Offline fallbacks belong in the repository too — see
`PostRepositoryImpl._withOfflineFallback`: on `NetworkException` it serves
the local copy, and if there is none it keeps the *network* error (more
useful to the user than "cache miss").

## Showing errors

`FailureMessageX.localizedMessage(l10n)` (in `core/extensions/`) is the
only place failures become text — all strings come from the ARB files:

```dart
ErrorView.failure(context, failure, onRetry: cubit.retry)
context.showSnackBar(failure.localizedMessage(context.l10n))
```

Validation failures carry user-facing messages; read them per field with
`failure.errorFor('email')`. `FieldErrorScrollMixin` scrolls a form to the
first invalid field.

## Global handlers — `app/bootstrap.dart`

| Handler | Catches |
|---|---|
| `FlutterError.onError` | build/layout/paint errors in the framework |
| `PlatformDispatcher.instance.onError` | uncaught async errors |
| `runZonedGuarded` | anything else in the root zone |
| `AppBlocObserver.onError` | errors thrown inside blocs |

They log through `AppLogger`. Plug a crash reporter (Crashlytics, Sentry)
in these four places.

## Adapting to your backend

Backend error codes (e.g. `{"error": {"code": "TOKEN_EXPIRED"}}`) belong in
**one** place: subclass `HttpExceptionMapper`, override `mapResponse`, and
register your subclass in `NetworkModule.exceptionMapper`. Add new
`AppException`/`Failure` pairs only for errors the UI must treat
differently, and give each a message in `FailureMessageX` and the ARB files.
