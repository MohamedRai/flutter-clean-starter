# CLAUDE.md

Rules for working in this repository. Details live in [`docs/`](docs/) —
read the linked page before changing an area, don't guess.

## 1. Project overview

`flutter_clean_starter` is a production-grade Flutter starter (Android + iOS)
built on strict Clean Architecture. It ships a reusable `core`, an app shell
(flavors, routing, DI, l10n, theming), one reference feature (`posts`,
removable with `dart run tool/remove_example.dart`), a `settings` feature,
mason bricks, and this AI setup.

## 2. Tech stack

Flutter 3.47 / Dart 3.13 · flutter_bloc + bloc_concurrency · get_it +
injectable · go_router + go_router_builder · freezed + json_serializable ·
dio · connectivity_plus · flutter_secure_storage + shared_preferences ·
gen-l10n (en, fr, ar) · logger · very_good_analysis · bloc_test + mocktail ·
mason. Functional errors use the project's own `Result<T>` (no dartz/fpdart).
See [ADRs](docs/adr/).

## 3. Architecture rules

```
presentation ──▶ domain ◀── data          app/ wires everything together
```

- `lib/core/` — feature-agnostic. **Never** imports `app/` or `features/`.
- `lib/app/` — composition root: bootstrap, DI, router, flavors, shell.
- `lib/features/<f>/{domain,data,presentation,di}` — one folder per feature.
- **domain**: pure Dart. No `package:flutter`, `dio`, `json_annotation`,
  `freezed_annotation`, `injectable`. Entities, repository *interfaces*,
  use cases (one class = one action).
- **data**: models (freezed + json, `implements DomainConvertible<E>`),
  data sources (abstract + impl), repository implementations
  (`extends BaseRepository`).
- **presentation**: blocs/cubits, pages, widgets. Blocs depend on **use
  cases only** — never on repositories or data sources.
- **di/**: a `@module` registering the feature's use cases (keeps domain
  annotation-free).
- Features never import other features. Share through `core/` or the
  `EventBus`.
- Features never import `app/`. Routes (in `app/router/app_routes.dart`)
  create the page's bloc via `getIt` and pass navigation as callbacks.

Details: [architecture](docs/architecture.md) ·
[folder structure](docs/folder-structure.md).

## 4. Coding standards

- SOLID; small classes; **one public class per file** (a bloc's
  `part` event/state files are the exception).
- Files ≤ 300 lines, `build` methods ≤ ~60 lines — extract widgets.
- Naming: files `snake_case`, classes `PascalCase`, use cases are verbs
  (`GetPosts`), params `<UseCase>Params`, states `<Name>State` subclasses.
- No business logic in widgets. Widgets render state and dispatch events.
- `const` constructors and literals everywhere possible.
- No `!` unless the invariant is local and obvious; prefer pattern matching.
- No `print` / `debugPrint` — use `AppLogger`.
- No hard-coded user-facing strings — use `context.l10n` (ARB files).
- No raw colors/sizes in widgets — use `context.colors`, `AppSpacing`,
  `AppRadius`.
- Package imports only (`package:flutter_clean_starter/...`).
- Dartdoc (`///`) on every public API. `flutter analyze` must report 0
  issues; never add `// ignore:` without a comment explaining why.
- Use cases and data sources are plain `class`es (mockable), not `final`.

## 5. State management

- **Cubit** for simple flows (load / retry / form). Extend `AsyncCubit` for
  "load one thing" screens.
- **Bloc** when events matter: concurrency (`droppable`, `restartable`),
  debouncing, or a clear event log.
- States are **sealed classes + Equatable** (`Initial/Loading/Success/
  Failure` shape). One state stream per screen.
- Side effects (snackbars, navigation) go in `BlocListener` / `AsyncListener`.

Details: [state management](docs/state-management.md).

## 6. Error handling

- Data sources **throw** `AppException`s (via `BaseDataSource.safeCall` /
  `HttpExceptionMapper`).
- Repositories **return** `FutureResult<T>` (`Future<Result<T>>`), using
  `BaseRepository.safeCall` / `safeWrite`. They never throw.
- Presentation maps a `Failure` to text with
  `failure.localizedMessage(context.l10n)`.
- Never catch `Object`/`Error` in features; never swallow a failure silently.

Details: [error handling](docs/error-handling.md) ·
[networking](docs/networking.md).

## 7. Testing

- Every use case, repository, data source, model, bloc/cubit gets a unit
  test; every page gets at least one widget test.
- Mirror `lib/` under `test/`; name files `<file>_test.dart`.
- Mock with **mocktail** (`class _MockX extends Mock implements X;`);
  bloc tests with **bloc_test**; widgets via `tester.pumpApp` from
  `test/helpers/pump_app.dart`.
- Test behavior and failures, not implementation details.
- Coverage target: **≥ 80 %** on `domain` + `data` of every feature.

Details: [testing](docs/testing.md).

## 8. Code generation

- **Always prefer a mason brick** over hand-writing boilerplate
  ([bricks](docs/mason-bricks.md)): `feature`, `usecase`, `bloc`, `cubit`,
  `repository`, `datasource`, `page`, `model`.
- Run `dart run build_runner build` after changing anything annotated
  (`@freezed`, `@JsonSerializable`, `@injectable`, `@module`, typed routes)
  or files under `assets/`.
- Run `flutter gen-l10n` after editing ARB files.
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`,
  `*.gen.dart`, `lib/core/l10n/gen/`) are committed — never hand-edit them.

Details: [code generation](docs/code-generation.md).

## 9. Commands

| Task | Command (macOS/Linux: `make <task>`, Windows: `./scripts/<task>.ps1`) |
|---|---|
| Install + generate | `make setup` |
| Codegen once / watch | `make gen` / `make watch` |
| Format / analyze | `make format` / `make analyze` |
| Tests / coverage | `make test` / `make coverage` |
| Run a flavor | `make run-dev` · `make run-staging` · `make run-prod` |
| Clean | `make clean` |

Raw equivalents: `dart format lib test integration_test tool` ·
`flutter analyze` · `flutter test` ·
`flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`.

## 10. Definition of done

Before saying a task is finished, run and report:

1. `dart format --set-exit-if-changed lib test integration_test tool`
2. `dart run build_runner build` (if annotated files or assets changed)
3. `flutter analyze` → **0 issues**
4. `flutter test` → all green; new code has tests
5. Layer check: no `features/` import in `core/`; no Flutter/Dio/JSON
   import in any `domain/`; no feature imports another feature
6. New user-facing text exists in **all** ARB files (en, fr, ar)
7. Docs updated if behavior or structure changed (`docs-writer` agent)

## 11. Skills & agents

Skills (`.claude/skills/`):

- `create-feature` — scaffold a complete feature (brick → DI → route → tests).
- `add-usecase` — add a use case wired through repository and bloc/cubit.
- `add-api-endpoint` — data source → model → repository → use case → tests.
- `add-screen` — page + route + bloc/cubit + l10n strings.
- `write-tests` — add missing tests for a file or feature.
- `add-localization` — add/translate keys in every ARB file.
- `refactor-to-clean-architecture` — move messy code into proper layers.
- `quality-check` — format, analyze, test, coverage; fix what fails.
- `add-flavor-config` — add an env variable to every flavor safely.

Agents (`.claude/agents/`):

- `flutter-architect` — read-only layer/SOLID review → violations report.
- `code-reviewer` — read-only diff review (clean code, perf, security).
- `test-engineer` — writes/fixes tests to reach coverage targets.
- `ui-builder` — responsive, accessible, theme-compliant widgets.
- `bug-hunter` — reproduce with a failing test, then fix.
- `performance-auditor` — rebuilds, const, lists, images.
- `docs-writer` — keeps README, `docs/` and dartdoc in sync.

How to extend them: [docs/claude-code.md](docs/claude-code.md).

## Project-Specific Context

<!--
Describe the app built on this starter here. Keep each item short; link to
docs for detail. Delete this comment once filled in.

### App purpose
What the app does and for whom.

### Domain glossary
- Term — meaning (e.g. "Booking — a confirmed reservation of a slot").

### Backend / API
Base URLs per flavor, auth scheme, error format (and whether
HttpExceptionMapper was customized), API docs link.

### Features
- feature_name — one line each.

### Business rules
Invariants the code must respect (limits, validation, permissions).

### Environment details
Extra env keys, third-party services (analytics, crash reporting, push).

### Team conventions
Branching, review rules, anything that overrides the defaults above.
-->
