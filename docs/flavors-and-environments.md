# Flavors and environments

Three flavors, each with its own entry point, env file, app id and name:

| Flavor | Entry point | Env file | Android id | iOS bundle id | Name |
|---|---|---|---|---|---|
| dev | `lib/main_dev.dart` | `env/dev.json` | `io.github.mohamedrai.flutter_clean_starter.dev` | `io.github.mohamedrai.flutterCleanStarter.dev` | Clean Starter Dev |
| staging | `lib/main_staging.dart` | `env/staging.json` | `….stg` | `….stg` | Clean Starter Stg |
| prod | `lib/main_prod.dart` | `env/prod.json` | `io.github.mohamedrai.flutter_clean_starter` | `io.github.mohamedrai.flutterCleanStarter` | Clean Starter |

All three can be installed side by side. `tool/rename.dart` updates the ids
and names.

## Running

```sh
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
make run-dev | make run-staging | make run-prod
./scripts/run-dev.ps1   # Windows
```

VS Code (`.vscode/launch.json`) and Android Studio (`.run/*.run.xml`) have
one run configuration per flavor.

## Env files

`env/<flavor>.json` is passed with `--dart-define-from-file` and read at
compile time. Real files are **git-ignored**; the committed
`env/<flavor>.example.json` are templates (`make env` / `setup` copy them).

| Key | Type | Used for |
|---|---|---|
| `FLAVOR` | string | Must match the entry point — checked at startup |
| `API_BASE_URL` | string | `Dio` base URL |
| `ENABLE_HTTP_LOGS` | bool | `LoggingInterceptor` on/off |

`FlavorConfig.fromEnvironment` reads them with `const
String.fromEnvironment(...)` and throws a clear `StateError` if the file is
missing or belongs to another flavor. `FlavorConfig` is registered in
GetIt; inject it where needed. Never call `String.fromEnvironment`
elsewhere.

> Values compiled into an app can be extracted from the binary. Env files
> are for configuration, not secrets — keep private keys on a server.

### Adding a variable

1. Add it to all six files in `env/`.
2. Read it in `FlavorConfig.fromEnvironment`, add a documented field.
3. Update `FlavorConfig(...)` constructions in tests.
4. Document it in the table above.

(The `add-flavor-config` Claude skill does this.)

### Why `--dart-define-from-file` and not `envied`?

No code generation, no generated file that could leak values, works the
same in `flutter run`, CI and IDE configs, and values are compile-time
constants. See [ADR 0005](adr/0005-environment-configuration.md).

## Android

`android/app/build.gradle.kts`:

```kotlin
buildFeatures { resValues = true }          // required by AGP 9 for resValue
flavorDimensions += "environment"
productFlavors {
    create("dev")     { applicationIdSuffix = ".dev"; resValue("string", "app_name", "Clean Starter Dev") }
    create("staging") { applicationIdSuffix = ".stg"; resValue("string", "app_name", "Clean Starter Stg") }
    create("prod")    { resValue("string", "app_name", "Clean Starter") }
}
```

`AndroidManifest.xml` uses `android:label="@string/app_name"`. Per-flavor
icons or Firebase files go in `android/app/src/<flavor>/`.

Release signing: replace the debug `signingConfig` in `buildTypes.release`
with your keystore (keep it out of git).

## iOS

`ios/Runner.xcodeproj` has build configurations `Debug-<flavor>`,
`Release-<flavor>`, `Profile-<flavor>` and shared schemes `dev`, `staging`,
`prod` (Flutter maps `--flavor dev` to the `dev` scheme). Per
configuration:

- `PRODUCT_BUNDLE_IDENTIFIER` — with `.dev` / `.stg` suffix;
- `FLAVOR_APP_NAME` — used by `CFBundleDisplayName` in `Info.plist`.

To add a flavor: duplicate the three configurations in Xcode (Project →
Info → Configurations), add a scheme using them, set the two settings above,
and add a Dart entry point and env files.

> These configurations were generated on Windows and verified structurally;
> run the first iOS build on a Mac (`flutter build ios --flavor dev -t
> lib/main_dev.dart --dart-define-from-file=env/dev.json --no-codesign`)
> and set your signing team in Xcode.
