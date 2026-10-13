# 0004. Own sealed `Result<T>` instead of dartz/fpdart `Either`

- Status: Accepted
- Date: 2026-10-13

## Context

Repositories and use cases must return failures as values. Common choices
are `Either<Failure, T>` from `dartz` (unmaintained since 2021) or `fpdart`.
The core reused for this starter already had a sealed `Result<T>` with
`SuccessResult` / `FailureResult`, used throughout its base repository and
cubits.

## Decision

Keep the core's own `Result<T>` (typedef `FutureResult<T>`), extended with
`map`, `flatMap`, `getOrElse`, `when`, `onSuccess`, `onFailure`. Do not add
`dartz` or `fpdart`.

## Consequences

- Zero dependency; Dart 3 sealed classes give exhaustive pattern matching:
  `switch (result) { SuccessResult(:final value) => …, FailureResult(:final failure) => … }`.
- Names are explicit for developers unfamiliar with functional
  programming (`Left`/`Right` are not intuitive).
- No functional toolbox (`TaskEither`, `traverse`); add small helpers to
  `Result` when a real need appears, or revisit with a new ADR.
