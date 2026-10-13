# Dependency injection

[get_it](https://pub.dev/packages/get_it) is the container;
[injectable](https://pub.dev/packages/injectable) generates the
registrations into `lib/app/di/injection.config.dart`.

## How it starts

`bootstrap()` → `configureDependencies(config)`:

```dart
@InjectableInit(ignoreUnregisteredTypes: [FlavorConfig])
Future<void> configureDependencies(FlavorConfig config) async {
  getIt.registerSingleton<FlavorConfig>(config);
  await getIt.init(environment: config.flavor.name);
}
```

`FlavorConfig` is registered by hand (it comes from the environment), and
the flavor name is the injectable **environment**.

## Where registrations live

| Kind | How | Example |
|---|---|---|
| Third-party & core services | `@module` in `app/di/modules/` | `CoreModule` (storage, cache, NetworkInfo, EventBus), `NetworkModule` (Dio, ExceptionMapper) |
| Data sources, repositories | Annotation on the implementation | `@LazySingleton(as: PostRepository)` |
| Use cases | Feature `@module` in `features/<f>/di/` | `PostsModule` (keeps domain annotation-free) |
| Blocs / cubits | `@injectable` (new instance per screen) | `PostsBloc` |
| App services | `@lazySingleton` | `AppSession`, `AppRouter` |

`core/` has **no** DI annotations: its classes are wired in `app/di`, so
`core` doesn't depend on the DI framework.

### Async and startup work

- `@preResolve` — awaited during `configureDependencies` (e.g.
  `SharedPreferencesWithCache`).
- `@PostConstruct(preResolve: true)` — async init after construction
  (`AppSession.restore()` reads the token).
- `@LazySingleton(dispose: …)` — cleanup on `getIt.reset()`
  (`EventBus`).

## Environments (per flavor)

Give one implementation per flavor:

```dart
@Environment('dev')
@LazySingleton(as: AnalyticsService)
class ConsoleAnalytics implements AnalyticsService { … }

@Environment('prod')
@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService { … }
```

Classes without `@Environment` are registered for every flavor.

## Rules

- Classes receive dependencies through their constructor. Only `app/`
  (routes, `App`) calls `getIt<…>()`.
- Depend on interfaces; register implementations `as:` the interface.
- After adding or changing an annotation: `dart run build_runner build`.

## Overriding in tests

- **Unit/widget tests** don't use GetIt: construct the class with mocks.
  Pages get blocs via `BlocProvider.value(value: mockBloc, …)`.
- **Integration tests** run the real graph and swap specific services:

```dart
await getIt.reset();
await configureDependencies(const FlavorConfig(
  flavor: Flavor.dev,
  apiBaseUrl: 'https://example.invalid',
  enableHttpLogs: false,
));
getIt
  ..allowReassignment = true
  ..registerLazySingleton<PostRemoteDataSource>(_FakeRemote.new);
```

Re-register before the dependent singletons are first resolved (lazy
singletons are created on first use).
