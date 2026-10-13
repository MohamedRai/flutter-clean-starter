---
name: refactor-to-clean-architecture
description: Take messy code (logic in widgets, HTTP calls in blocs, JSON in entities, god classes) and move it into proper domain/data/presentation layers without changing behavior. Use when the user asks to clean up, restructure or "make this follow the architecture", or when a review found layer violations.
---

# Refactor to Clean Architecture

Behavior must not change. Tests protect the refactor.

## 1. Map the current code

Read the code and list every responsibility it has: UI rendering, state,
business rules, HTTP/storage access, JSON parsing, navigation. Optionally
run the `flutter-architect` agent for a violations report.

## 2. Pin the behavior

If the code has no tests, write characterization tests first (widget test
for the visible behavior, unit tests for any pure logic). They must pass
before and after.

## 3. Move outward-in

1. **Entities** (domain): pure Dart classes for the business data. Strip
   JSON, Flutter and DI from them.
2. **Repository contract** (domain): the operations the UI needs, returning
   `FutureResult<T>`.
3. **Models + data sources** (data): JSON parsing → freezed models
   (`mason make model`); HTTP/storage calls → data sources
   (`mason make datasource`), throwing `AppException`s.
4. **Repository impl** (data): `extends BaseRepository`, maps exceptions to
   failures, models to entities (`mason make repository`).
5. **Use cases** (domain): one per business action (`mason make usecase`);
   move business rules here.
6. **Bloc/Cubit** (presentation): depends only on use cases; UI state as
   sealed classes.
7. **Widgets**: render state, dispatch events, receive navigation callbacks.
   Split large `build` methods into widgets.
8. **DI**: annotate data/presentation classes; register use cases in the
   feature's `di/` module. Remove manual instantiation.

Do it in small steps; run `flutter test` after each.

## 4. Clean up

Delete dead code, move strings to ARB files, replace magic numbers with
theme tokens, add dartdoc to public APIs.

## 5. Verify

```sh
dart run build_runner build
dart format lib test
flutter analyze
flutter test
```

Then re-run `flutter-architect` and confirm zero violations.
