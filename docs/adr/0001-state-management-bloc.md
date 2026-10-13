# 0001. Bloc/Cubit with sealed Equatable states

- Status: Accepted
- Date: 2026-10-13

## Context

The starter needs one state-management approach that scales from simple
screens to complex flows, is testable without widgets, and is familiar to
most Flutter developers. The reused core already shipped `AsyncCubit`,
`AsyncState` and paging cubits built on `flutter_bloc`.

## Decision

- Use `flutter_bloc`: **Cubit** for simple flows, **Bloc** when events and
  concurrency matter (`bloc_concurrency` transformers).
- Model states (and events) as **sealed classes extending `Equatable`**,
  not freezed unions.
- Blocs depend on use cases only; they are created per route through DI.

## Consequences

- Exhaustive `switch` over states in the UI with plain Dart 3 — no codegen
  for states, readable stack traces, fewer generated files.
- Slightly more boilerplate than freezed for `copyWith`; mitigated by the
  `bloc`/`cubit` bricks and by keeping states small.
- `bloc_test` + `mocktail` give fast, deterministic tests for every state
  transition.
