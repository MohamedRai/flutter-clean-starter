# Testing

## Strategy

| Level | Tools | Where | What |
|---|---|---|---|
| Unit | `flutter_test`, `mocktail` | `test/**` | models, data sources, repositories, use cases, core utilities |
| Bloc | `bloc_test` | `test/**/presentation/{bloc,cubit}` | every event/method: success **and** failure |
| Widget | `flutter_test`, `MockBloc`/`MockCubit` | `test/**/presentation/pages` | loading / success / empty / error, callbacks, RTL |
| Integration | `integration_test` | `integration_test/` | real app + DI, fake network, key user journeys |

No golden tests: they are brittle across platforms and font versions. Use
widget assertions instead.

## Commands

```sh
flutter test                                   # unit + widget
make coverage                                  # + coverage gate
flutter test test/features/posts               # one folder
flutter test integration_test --flavor dev     # on a device / emulator
```

## Conventions

- Mirror `lib/` paths; file name `<source>_test.dart`.
- Group by method or event; name tests by behavior:
  `'falls back to saved posts when offline'`.
- Mocks are private to the test file: `class _MockRepo extends Mock
  implements PostRepository;`. Use `registerFallbackValue` in `setUpAll`
  for custom types used with `any()`.
- Fixtures: `const` objects in `test/features/<f>/helpers/`.
- Widgets: `tester.pumpApp(widget)` (`test/helpers/pump_app.dart`) wraps
  the widget in a themed, localized `MaterialApp`; pass `locale:` to test
  other languages.
- No real network, timers or platform channels in unit/widget tests.

## Examples per layer

**Repository** (real in-memory cache, mocked data sources):

```dart
test('falls back to saved posts when offline', () async {
  when(() => remote.getPosts()).thenThrow(const NetworkException());
  when(() => local.getCachedPosts()).thenAnswer((_) async => [Fixtures.postModel]);

  expect(await repository.getPosts(), const Result.success([Fixtures.post]));
});
```

**Bloc**:

```dart
blocTest<PostsBloc, PostsState>(
  'keeps the posts and reports the failure',
  setUp: () => when(() => getPosts(const GetPostsParams(forceRefresh: true)))
      .thenAnswer((_) async => const Result.failure(NetworkFailure())),
  build: () => PostsBloc(getPosts),
  seed: () => const PostsLoaded([Fixtures.post]),
  act: (bloc) => bloc.add(const PostsRefreshed()),
  expect: () => const [PostsLoaded([Fixtures.post], refreshFailure: NetworkFailure())],
);
```

**Widget**:

```dart
testWidgets('shows the error and retries', (tester) async {
  when(() => bloc.state).thenReturn(const PostsFailure(NetworkFailure()));
  await tester.pumpApp(BlocProvider<PostsBloc>.value(
    value: bloc, child: PostsPage(onPostTap: (_) {}),
  ));
  await tester.tap(find.text('Retry'));
  verify(() => bloc.add(const PostsRequested())).called(1);
});
```

**Integration** (`integration_test/app_test.dart`): resets GetIt,
configures the dev graph, swaps `PostRemoteDataSource` for a fake, then
drives the real app (list → detail, auth guard redirect, Arabic).

## Coverage

`tool/coverage.dart` reads `coverage/lcov.info`, excludes generated files
and prints coverage per feature layer. The gate (`--min 80`, used by
`make coverage` and CI) applies to **`domain` + `data` of all features**.
Presentation and core are reported but not gated.

## What must be tested

Use cases, repositories, data sources, models, blocs/cubits: always.
Pages: at least one widget test covering their states. Core utilities:
when they contain logic. Bug fixes: a test that failed before the fix.
