# 0002. get_it + injectable, with annotation-free domain and core

- Status: Accepted
- Date: 2026-10-13

## Context

Manual GetIt registration becomes error-prone as features grow. Clean
Architecture also requires the domain layer to be independent of
frameworks, and the reusable `core` should not force a DI framework.

## Decision

- Use `get_it` as the container and `injectable` to generate registrations.
- Annotate **implementations** in data and presentation
  (`@LazySingleton(as: Interface)`, `@injectable`).
- Register **use cases** in a per-feature `@module` (`features/<f>/di/`),
  keeping the domain layer annotation-free.
- Register `core` services and third-party objects in `app/di/modules/`,
  so `core` has no DI dependency.
- Use the flavor name as the injectable environment.

## Consequences

- Adding a class = annotate + `build_runner`; the graph is checked at
  generation time.
- One extra small file per feature (`di/<feature>_module.dart`); the
  `usecase` brick appends to it automatically.
- Only the composition root (`app/`) calls `getIt`; everything else uses
  constructor injection, so unit tests never need the container.
