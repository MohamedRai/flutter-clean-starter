# Mason bricks

Local bricks in `bricks/`, registered in [`mason.yaml`](../mason.yaml).
Generated code follows every project convention and passes
`flutter analyze` after `dart run build_runner build`.

## Setup

```sh
dart pub global activate mason_cli   # once per machine (make setup does it)
mason get                            # once per clone
mason list                           # show available bricks
```

Run `mason make` from the **project root**. Names can be given in any case
(`OrderItems`, `order items`, `order_items`); they are normalized to
snake_case for paths.

## What every brick does

- **pre_gen hook** reads the package name from `pubspec.yaml`, so imports
  are correct after `tool/rename.dart`.
- **post_gen hook** runs `dart fix --apply` (import order depends on the
  package name) and `dart format` on the feature folders, then prints the
  next steps.
- Writes tests next to the code, mirroring `lib/` under `test/`.
- Use `--on-conflict skip|overwrite` to avoid prompts when files exist.

## Bricks

### `feature`

A complete vertical slice.

| Variable | Example | Meaning |
|---|---|---|
| `feature` | `orders` | folder under `lib/features/` |
| `entity` | `order` | main entity (singular) |
| `endpoint` | `/orders` | API collection path |

Output: entity (`id`, `name`), repository interface + implementation,
remote data source (`getAll`, `getById`), freezed model, `GetOrderList`
use case, `OrdersModule` (DI), `OrderListCubit` (`AsyncCubit`),
`OrdersPage`, `OrderTile`, and tests for model, data source, repository,
use case, cubit and page. Prints a route snippet.

```sh
mason make feature --feature orders --entity order --endpoint /orders
```

### `usecase`

| Variable | Example | Meaning |
|---|---|---|
| `feature` | `orders` | |
| `name` | `get_order_by_id` | use case, verb first |
| `entity` | `order` | whose repository is called |
| `method` | `getById` | repository method (must exist) |
| `returns` | `entity` · `list` · `nothing` | return type |
| `params` | `none` · `id` · `custom` | `NoParams`, `String`, or a generated `<Name>Params` |

Generates the use case + test and **registers it** in
`lib/features/<feature>/di/<feature>_module.dart`.

```sh
mason make usecase --feature orders --name get_order_by_id --entity order --method getById --returns entity --params id
```

### `bloc` / `cubit`

`feature`, `name`. Sealed `Initial/Loading/Success/Failure` states
(Equatable), `@injectable`, `blocTest` file. The bloc ships a
`<Name>Started` event with a `droppable()` transformer.

```sh
mason make bloc --feature orders --name order_filter
mason make cubit --feature orders --name order_form
```

### `repository`

`feature`, `name` (entity). Interface (domain) + `BaseRepository`
implementation (data, `getAll` / `getById` with caching) + test. Requires
the entity, model and remote data source (`model` + `datasource` bricks).

### `datasource`

`feature`, `name`, `type` (`remote` | `local`), `endpoint` (remote only).
Remote: `BaseRemoteDataSource` with `getAll` / `getById`. Local:
`KeyValueStorage` JSON cache with `getAll` / `saveAll`. Each with tests.
Requires the model.

### `page`

`feature`, `name`. A page taking a localized `title`, a widget test, and a
printed route snippet.

### `model`

`feature`, `name`. Domain entity + freezed/json model
(`toEntity`/`fromEntity`) + test.

## Typical sequences

New feature: `feature` → edit entity/model fields → `build_runner` → route
→ ARB strings.

New entity inside a feature: `model` → `datasource --type remote` →
`repository` → `usecase` (one per action) → `build_runner`.

## Editing bricks

Templates live in `bricks/<brick>/__brick__/` (mustache: `{{feature}}`,
`{{name.pascalCase()}}`, sections `{{#is_remote}}…{{/is_remote}}`);
variables in `brick.yaml`; hooks in `bricks/<brick>/hooks/`. Keep the
generated code consistent with `lib/features/posts`. After changing a
brick, test it in a scratch clone:

```sh
mason make <brick> … && dart run build_runner build && flutter analyze && flutter test
```

On Windows, deep clone paths can exceed the 260-character limit with brick
template paths — enable `git config core.longpaths true`.
