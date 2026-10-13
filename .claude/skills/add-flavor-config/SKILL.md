---
name: add-flavor-config
description: Add a new environment variable (API key, feature flag, URL) across all flavors (dev, staging, prod) safely — env files, examples, FlavorConfig, CI and docs. Use when the user needs a per-environment setting or a new third-party key.
---

# Add a flavor config value

Values come from `--dart-define-from-file=env/<flavor>.json` and are read
once in `lib/app/flavors/flavor_config.dart`.

> Anything compiled into the app can be extracted from the binary. Never
> put real secrets (private API keys, signing keys) in env files — keep
> them on a backend.

## 1. Name it

`UPPER_SNAKE_CASE`, specific: `SENTRY_DSN`, `ENABLE_ANALYTICS`,
`MAPS_API_KEY`.

## 2. Add it to every env file

Add the key with a sensible value to all six files:

- `env/dev.json`, `env/staging.json`, `env/prod.json` (local, git-ignored)
- `env/dev.example.json`, `env/staging.example.json`,
  `env/prod.example.json` (committed — placeholder values only)

JSON types: strings, booleans and numbers are supported.

## 3. Expose it in FlavorConfig

In `flavor_config.dart`:

- read it in `FlavorConfig.fromEnvironment` with a **const**
  `String.fromEnvironment` / `bool.fromEnvironment` /
  `int.fromEnvironment`;
- validate required values (throw a `StateError` with a fix-it message,
  like `API_BASE_URL`);
- add a documented `final` field and a required constructor parameter.

Update the `FlavorConfig(...)` used in `integration_test/app_test.dart` and
any test that builds one.

## 4. Consume it through DI

Inject `FlavorConfig` (registered in `configureDependencies`) into the
module or class that needs it. Never call `String.fromEnvironment`
elsewhere.

## 5. CI and docs

- `.github/workflows/ci.yml` creates env files from the examples — check
  the placeholder is valid for tests/builds.
- Document the key in `docs/flavors-and-environments.md` (table of keys).

## 6. Verify

```sh
flutter analyze
flutter test
flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```
