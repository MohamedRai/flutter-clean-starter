---
name: add-screen
description: Add a new page to an existing feature with its route, bloc or cubit wiring and localized strings. Use when the user asks for a new screen, page, detail view or form inside a feature that already exists.
---

# Add a screen

## 1. Generate the page

```sh
mason make page --feature <f> --name <name>          # e.g. order_detail
```

Creates `presentation/pages/<name>_page.dart` + a widget test and prints a
route snippet.

## 2. State

- Loads one thing → a cubit extending `AsyncCubit<T, Params>` (see
  `PostDetailCubit`), rendered with `AsyncBuilder`.
- Several events / concurrency → `mason make bloc --feature <f> --name <name>`.
- Local form state → `mason make cubit --feature <f> --name <name>`.

The bloc/cubit depends on **use cases only**. Add any missing ones with the
`add-usecase` skill.

## 3. Build the UI

- Keep the page a thin shell; extract sections into `presentation/widgets/`.
- Read state with `BlocBuilder`/`AsyncBuilder`; side effects with
  `BlocListener`/`AsyncListener`.
- Navigation arrives as constructor callbacks (`onItemTap`), never via
  `context.go` with hard-coded strings and never by importing `app/`.
- Use `context.l10n`, `context.colors`, `AppSpacing`, `const` widgets.
- Use the `ui-builder` agent for complex or responsive layouts.

## 4. Route

Paste the snippet into `lib/app/router/app_routes.dart`; add the path to
`route_paths.dart`. In the route's `build`, create the bloc/cubit with
`getIt<...>()` inside a `BlocProvider` and pass navigation callbacks using
typed routes (`OtherRoute(id: id).go(context)`). Protected page? Add its
path to `AuthGuard.protectedPaths`.

## 5. Strings

Add every new string to **all** ARB files (`add-localization` skill), then
`flutter gen-l10n`.

## 6. Verify

```sh
dart run build_runner build
dart format lib test
flutter analyze
flutter test
```

Widget test must cover loading, success and failure rendering.
