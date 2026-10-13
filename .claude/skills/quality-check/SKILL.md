---
name: quality-check
description: Run the full quality gate — format, codegen, analyze, tests, coverage and architecture checks — then fix every problem found and report the results. Use before finishing any task, before a commit or PR, or when the user asks "is everything green?".
---

# Quality check

Run each step; fix failures before moving on; report a short summary.

## 1. Format

```sh
dart format --set-exit-if-changed lib test integration_test tool
```

If it fails, run `dart format lib test integration_test tool` and re-check.

## 2. Code generation is up to date

```sh
dart run build_runner build
flutter gen-l10n
git status --short    # generated files must not change unexpectedly
```

## 3. Analyze — must be 0 issues

```sh
flutter analyze
```

Fix the cause. Only add an `// ignore:` with a comment explaining why the
rule doesn't apply.

## 4. Tests

```sh
flutter test --coverage
```

All green. For each feature touched, compute coverage of
`lib/features/<f>/domain` and `lib/features/<f>/data` from
`coverage/lcov.info` (LF/LH lines). Target ≥ 80 %; if below, use the
`write-tests` skill.

## 5. Architecture

```sh
# core must not depend on app/ or features/
grep -rnE "import 'package:[a-z_]+/(app|features)/" lib/core
# domain must stay pure Dart
grep -rnE "import 'package:(flutter|dio|json_annotation|freezed_annotation|injectable)/" lib/features/*/domain
# features must not import app/
grep -rnE "import 'package:[a-z_]+/app/" lib/features
```

Each must print nothing. Cross-feature imports: check that
`lib/features/<a>` never imports `features/<b>`.

## 6. Strings

Every key in `app_en.arb` exists in `app_fr.arb` and `app_ar.arb`
(`flutter gen-l10n` reports untranslated messages).

## 7. Report

List each step with ✅/❌, the fixes you made, and coverage numbers.
