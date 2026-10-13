---
name: add-usecase
description: Add one use case to an existing feature and wire it through the repository, DI and a bloc/cubit, with tests. Use when the user wants a new action or business operation in a feature that already exists (e.g. "let users delete an order", "add a search to posts").
---

# Add a use case

One use case = one action, named as a verb (`DeleteOrder`, `SearchPosts`).

## 1. Repository contract first

Open `lib/features/<f>/domain/repositories/<entity>_repository.dart` and add
the method the use case needs, returning `FutureResult<T>` /
`FutureResultList<T>` / `FutureResultVoid`. Document it with `///`.

## 2. Implement it in the data layer

In `data/repositories/<entity>_repository_impl.dart`:

- reads → `safeCall(key: ..., policy: ..., remote: ...)`
- writes → `safeWrite(write: ..., invalidateKeys: [...])` — invalidate
  every cache key the mutation affects.

If the data source lacks the call, add it there first (see the
`add-api-endpoint` skill). Add a repository test for the success path and
at least one failure path.

## 3. Generate the use case

```sh
mason make usecase --feature <f> --name <verb_object> --entity <entity> \
  --method <repositoryMethod> --returns <entity|list|nothing> \
  --params <none|id|custom>
```

The brick creates the use case and its test **and registers it** in
`lib/features/<f>/di/<f>_module.dart`. With `--params custom`, add fields
to the generated `<Name>Params` (and to `props`), and make the repository
method accept it.

## 4. Use it from presentation

Inject the use case into the bloc/cubit constructor (never the repository).
Handle both `SuccessResult` and `FailureResult` with an exhaustive `switch`.
Add `blocTest` cases for success and failure.

## 5. Generate and verify

```sh
dart run build_runner build
dart format lib test
flutter analyze
flutter test
```
