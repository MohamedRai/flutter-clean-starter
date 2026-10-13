---
name: write-tests
description: Generate the missing tests for a file, class or whole feature following the project's testing conventions (mocktail, bloc_test, pumpApp). Use when the user asks to test something, raise coverage, or when new code was added without tests.
---

# Write tests

## 1. Find the gaps

- Mirror path: `lib/x/y.dart` → `test/x/y_test.dart`.
- For a feature, list `lib/features/<f>/**.dart` (skip `*.g.dart`,
  `*.freezed.dart`, `di/`) and check each has a test.
- Optionally measure: `flutter test --coverage` then inspect
  `coverage/lcov.info` for the feature's files.

## 2. What each layer needs

| Unit | Test |
|---|---|
| Model | `fromJson`, `toJson` round-trip, `toEntity`/`fromEntity`, malformed JSON throws |
| Remote data source | mock `Dio`; success decode, HTTP error → right `AppException`, network error |
| Local data source | mock `KeyValueStorage`; round-trip, miss/corrupt → `CacheException` |
| Repository | mock data sources, real `InMemoryDataCacheStore`; success, each exception → failure, caching/offline behavior |
| Use case | mock repository; delegates and returns the result; params equality |
| Bloc / Cubit | `blocTest` for every event/method: success **and** failure sequences |
| Page / widget | mock bloc (`MockBloc`/`MockCubit`), `tester.pumpApp`; loading, success, empty, error + retry, callbacks fired |

Use existing tests in `test/features/posts/` as the reference.

## 3. Conventions

- Mocks: `class _MockX extends Mock implements X;` (private, in the test
  file). `registerFallbackValue` in `setUpAll` for custom `any()` types.
- Group by method/event; describe behavior ("emits loading then failure").
- Shared fixtures go in `test/features/<f>/helpers/`.
- No real network, timers or platform channels in unit/widget tests.
- Prefer `const` fixtures; assert full states, not fragments.

## 4. Verify

```sh
dart format test
flutter analyze
flutter test
```

Report coverage for `domain` + `data` of the feature (target ≥ 80 %).
