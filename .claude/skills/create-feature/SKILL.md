---
name: create-feature
description: Scaffold a new feature end-to-end (domain, data, presentation, DI, route, l10n, tests) using the mason `feature` brick. Use when the user asks for a new feature, module, section or screen family backed by its own data (e.g. "add an orders feature", "create a profile module").
---

# Create a feature

Follow these steps in order. Never hand-write what the brick generates.

## 1. Clarify the inputs

Decide (ask only if the request doesn't say):

- `feature` — folder name, plural snake_case (`orders`).
- `entity` — main entity, singular (`order`).
- `endpoint` — API collection path (`/orders`).
- Whether it needs a tab in the bottom navigation or a standalone route.

Check `lib/features/` so you don't duplicate an existing feature.

## 2. Generate

```sh
mason make feature --feature <feature> --entity <entity> --endpoint <endpoint>
```

(If `mason` is not on PATH: `dart pub global activate mason_cli`, then
`mason get` once.) The brick creates entity, repository contract + impl,
remote data source, freezed model, `Get<Entity>List` use case, DI module,
`AsyncCubit`, page, tile widget and tests.

## 3. Shape the domain

Edit the entity fields to match the real data, then mirror them in the
model (`data/models/`). Keep the entity pure Dart. Update the generated
tests' fixtures to the new fields.

## 4. Generate code

```sh
dart run build_runner build
```

## 5. Route

Paste the route snippet the brick printed into
`lib/app/router/app_routes.dart` (inside a `TypedStatefulShellBranch` for a
tab, or as a top-level `@TypedGoRoute`). Add the path to
`lib/app/router/route_paths.dart`. For a tab, also add a
`NavigationDestination` in `lib/app/shell/app_shell_scaffold.dart` in the
same order as the branches. Run `dart run build_runner build` again.

## 6. Strings

Add the page title (and any other text) to **every**
`lib/core/l10n/arb/app_*.arb` (use the `add-localization` skill), then
`flutter gen-l10n`.

## 7. More behavior

- Extra endpoints → `add-api-endpoint` skill.
- Extra actions → `add-usecase` skill.
- More screens → `add-screen` skill.

## 8. Verify (Definition of done, CLAUDE.md §10)

```sh
dart format lib test integration_test tool
flutter analyze
flutter test
```

All must pass. Then ask the `flutter-architect` agent to review the new
feature's layer boundaries if it is non-trivial.
