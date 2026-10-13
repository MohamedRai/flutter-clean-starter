# 0005. `--dart-define-from-file` env files instead of envied

- Status: Accepted
- Date: 2026-10-13

## Context

Each flavor needs its own configuration (API URL, flags). Options:
`envied` (code generation from `.env`, optional obfuscation) or Flutter's
built-in `--dart-define-from-file` with JSON files.

## Decision

Use `--dart-define-from-file=env/<flavor>.json`. Real env files are
git-ignored; `env/<flavor>.example.json` are committed templates. Values
are read once, as compile-time constants, in `FlavorConfig.fromEnvironment`,
which also validates that the file matches the flavor.

## Consequences

- No codegen step and no generated file containing values.
- Same mechanism in `flutter run`, IDE launch configs, scripts and CI.
- Obfuscation is not offered — by design: anything shipped in a client app
  is extractable, so secrets must stay server-side (documented).
- Every run command must pass the flag; scripts and run configurations do
  it for you, and a missing file fails fast with a clear message.
