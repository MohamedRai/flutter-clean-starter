# Folder structure

## Repository root

| Path | Purpose |
|---|---|
| `lib/` | App source (below) |
| `test/` | Unit and widget tests, mirroring `lib/` |
| `test/helpers/` | Shared test helpers (`pumpApp`) |
| `integration_test/` | End-to-end tests on a device |
| `env/` | `<flavor>.json` (local, git-ignored) and `<flavor>.example.json` (committed) |
| `assets/` | `icons/`, `images/` — accessed through `Assets` (flutter_gen) |
| `bricks/` + `mason.yaml` | Mason code-generation bricks |
| `tool/` | Dart CLIs: `rename.dart`, `remove_example.dart`, `coverage.dart`, `claude/format_hook.dart` |
| `scripts/` | PowerShell equivalents of the `Makefile` targets |
| `docs/` | Technical documentation and ADRs |
| `.claude/` | Claude Code skills, agents and settings |
| `.github/workflows/` | CI |
| `.vscode/`, `.run/` | Run configurations per flavor (VS Code / Android Studio) |
| `android/`, `ios/` | Native projects with flavor configuration |

## `lib/`

```
lib/
├── main_dev.dart / main_staging.dart / main_prod.dart   # entry points
├── app/
│   ├── bootstrap.dart        # error handlers, Bloc observer, DI, runApp
│   ├── app.dart              # App (DI) + AppView (MaterialApp.router)
│   ├── di/
│   │   ├── injection.dart    # getIt + configureDependencies()
│   │   ├── injection.config.dart  (generated)
│   │   └── modules/          # third-party + core registrations
│   ├── flavors/              # Flavor enum, FlavorConfig
│   ├── router/
│   │   ├── app_routes.dart   # typed routes (+ .g.dart)
│   │   ├── app_router.dart   # GoRouter instance
│   │   ├── route_paths.dart  # path constants
│   │   └── guards/           # AuthGuard
│   ├── session/              # AppSession + demo sign-in/account pages
│   └── shell/                # bottom-nav scaffold, NotFoundPage
├── core/                     # see README "Project structure"
│   └── assets/               # generated Assets class (flutter_gen)
└── features/<feature>/
    ├── data/
    │   ├── datasources/      # <entity>_remote_data_source.dart, _local_
    │   ├── models/           # <entity>_model.dart (+ .freezed / .g)
    │   └── repositories/     # <entity>_repository_impl.dart
    ├── domain/
    │   ├── entities/         # <entity>.dart
    │   ├── repositories/     # <entity>_repository.dart (interface)
    │   └── usecases/         # <verb>_<object>.dart
    ├── di/                   # <feature>_module.dart (registers use cases)
    └── presentation/
        ├── bloc/             # <name>_bloc.dart + _event + _state (parts)
        ├── cubit/            # <name>_cubit.dart (+ _state part)
        ├── pages/            # <name>_page.dart
        └── widgets/          # feature-specific widgets
```

## Naming

| Thing | File | Class |
|---|---|---|
| Entity | `order.dart` | `Order` |
| Model | `order_model.dart` | `OrderModel` |
| Repository | `order_repository.dart` / `_impl.dart` | `OrderRepository` / `OrderRepositoryImpl` |
| Data source | `order_remote_data_source.dart` | `OrderRemoteDataSource` / `…Impl` |
| Use case | `get_order_by_id.dart` | `GetOrderById` + `GetOrderByIdParams` |
| Bloc | `orders_bloc.dart` | `OrdersBloc`, `OrdersEvent`, `OrdersState` |
| Page | `orders_page.dart` | `OrdersPage` |
| Test | `<file>_test.dart` in the mirrored folder | — |
