# Code generation

| Generator | Input | Output |
|---|---|---|
| freezed | `@freezed` models | `*.freezed.dart` (equality, `copyWith`) |
| json_serializable | `fromJson`/`toJson` in models | `*.g.dart` |
| injectable_generator | `@injectable`, `@lazySingleton`, `@module`, … | `lib/app/di/injection.config.dart` |
| go_router_builder | typed routes in `app/router/app_routes.dart` | `app_routes.g.dart` (`$appRoutes`, `$XRoute` mixins) |
| flutter_gen_runner | files in `assets/` | `lib/core/assets/assets.gen.dart` (`Assets.icons.logo.svg()`) |
| gen-l10n (Flutter) | `lib/core/l10n/arb/*.arb` | `lib/core/l10n/gen/` (`AppLocalizations`) |

## Commands

```sh
dart run build_runner build     # once        (make gen also runs gen-l10n)
dart run build_runner watch     # continuous  (make watch)
flutter gen-l10n                # after editing ARB files
```

build_runner 2.16 resolves conflicting outputs automatically; the old
`-d` / `--delete-conflicting-outputs` flag is accepted but ignored.

Configuration: [`build.yaml`](../build.yaml) (json options, freezed without
`map`/`when` — use Dart patterns instead), the `flutter_gen` section of
`pubspec.yaml`, and [`l10n.yaml`](../l10n.yaml).

## Policy: generated files are committed

- A fresh clone compiles and runs without a codegen step.
- Reviews show what changed in generated APIs (DI graph, routes).
- CI regenerates and fails on any diff (`git diff --exit-code -- lib`), so
  stale files can't be merged.

Generated files are excluded from analysis (`analysis_options.yaml`) and
from coverage (`tool/coverage.dart`). Never edit them by hand.

## Freezed models

```dart
@freezed
abstract class PostModel with _$PostModel implements DomainConvertible<Post> {
  const factory PostModel({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _PostModel;

  const PostModel._();   // enables custom methods (toEntity)

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  @override
  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}
```

- Use `@JsonKey(name: 'user_id')` for snake_case APIs (the
  `invalid_annotation_target` warning is disabled for this).
- Models are data-layer only; entities stay plain Dart + Equatable.

## Mason vs. build_runner

Mason creates *source* files you own and edit (features, blocs, tests);
build_runner creates *derived* files from annotations. A typical flow:
`mason make …` → edit → `dart run build_runner build`. See
[mason-bricks.md](mason-bricks.md).
