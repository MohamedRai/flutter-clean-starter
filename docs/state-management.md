# State management

The project uses [flutter_bloc](https://bloclibrary.dev). Blocs and cubits
live in `features/<f>/presentation/` and depend **only on use cases**.

## Bloc or Cubit?

| Use a **Cubit** when… | Use a **Bloc** when… |
|---|---|
| The screen loads one thing and can retry | Several events interact (refresh vs. load vs. filter) |
| Methods map 1:1 to user actions | You need concurrency control (`droppable`, `restartable`, debounce) |
| Form state, toggles, selections | An explicit, testable event log helps |

The example feature uses both: `PostsBloc` (list, with refresh semantics)
and `PostDetailCubit` (single item).

## State shape

States are **sealed classes extending `Equatable`**:

```dart
sealed class PostsState extends Equatable { const PostsState(); … }
final class PostsInitial extends PostsState { … }
final class PostsLoading extends PostsState { … }
final class PostsLoaded extends PostsState { final List<Post> posts; … }
final class PostsFailure extends PostsState { final Failure failure; … }
```

Sealed classes make `switch` exhaustive in the UI — adding a state is a
compile error until every screen handles it. Freezed is not used for
states (see [ADR 0001](adr/0001-state-management-bloc.md)).

Rules:

- Keep previous data when a refresh fails (`PostsLoaded(posts,
  refreshFailure: f)`) instead of replacing the screen with an error.
- Never emit after `close()` — `AsyncCubit` and blocs' `emit` guard this;
  in custom cubits check `isClosed` after every `await`.
- No `BuildContext`, widgets or navigation inside blocs.

## Reusable pieces in `core/bloc` and `core/widgets`

### `AsyncCubit<T, Params>` + `AsyncBuilder`

For "load one thing" screens. Implement `execute`, get `load`, `retry`,
`reset`, and the `AsyncInitial/Loading/Success/Failure` states for free:

```dart
@injectable
class PostDetailCubit extends AsyncCubit<Post, int> {
  PostDetailCubit(this._getPostById);
  final GetPostById _getPostById;

  @override
  FutureResult<Post> execute(int id) =>
      _getPostById(GetPostByIdParams(id: id));
}

// UI — loading and error views are built in:
AsyncBuilder<PostDetailCubit, Post>(
  onRetry: () => context.read<PostDetailCubit>().retry(),
  successBuilder: (context, post) => PostContent(post: post),
)
```

`AsyncListener` runs side effects per state; `AsyncSelector` rebuilds on a
derived value only. `RevalidatesOnChange` clears field errors live for
cubits backed by a `UseCaseWithValidation`.

### `PagingCubit<T, Params>` + `PagingListView`

Cursor-based infinite lists with de-duplication, pull-to-refresh and item
mutations (`insertItem`, `replaceItem`, `removeItem`). Items implement
`Identifiable`.

## Concurrency (bloc_concurrency)

```dart
on<PostsRequested>(_onRequested, transformer: droppable());   // ignore while busy
on<PostsRefreshed>(_onRefreshed, transformer: restartable()); // latest wins
```

## Providing blocs

Create blocs in the route, not in the page:

```dart
Widget build(BuildContext context, GoRouterState state) => BlocProvider(
  create: (_) => getIt<PostsBloc>()..add(const PostsRequested()),
  child: PostsPage(onPostTap: (id) => PostDetailRoute(id: id).go(context)),
);
```

App-wide state (theme, locale) is provided above `MaterialApp`
(`SettingsCubit` in `app/app.dart`).

## Testing

Every bloc/cubit has `blocTest`s for success **and** failure — see
[testing.md](testing.md).
