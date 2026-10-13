import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/domain/identifiable.dart';
import 'package:flutter_clean_starter/core/domain/paginated_result.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';

/// A cursor-paginated list of [T], with de-duplication and in-place item
/// mutations. Pair it with `PagingListView`.
///
/// ```text
/// fetch(cursor: null)  → page 1, nextCursor: "abc"
/// fetch(cursor: "abc") → page 2, nextCursor: null → end
/// ```
///
/// ```dart
/// class PostsPagingCubit extends PagingCubit<Post, GetPostsPageParams> {
///   PostsPagingCubit(this._getPage);
///   final GetPostsPage _getPage;
///
///   @override
///   FutureResult<PaginatedResult<Post>> execute(GetPostsPageParams p) =>
///       _getPage(p);
///
///   @override
///   GetPostsPageParams buildParams(String? cursor) =>
///       GetPostsPageParams(cursor: cursor);
/// }
/// ```
abstract class PagingCubit<T extends Identifiable, Params>
    extends Cubit<PagingState<T>> {
  /// Creates the cubit with an empty state.
  PagingCubit() : super(PagingState<T>());

  /// Fetches one page — delegate to a use case.
  FutureResult<PaginatedResult<T>> execute(Params params);

  /// Builds the [Params] for [cursor] (`null` = first page).
  Params buildParams(String? cursor);

  /// Fetches the next page and appends it. No-op while loading or at the
  /// end of the list. Existing items are kept on failure.
  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasNextPage) return;
    emit(state.copyWith(isLoading: true, failure: () => null));

    final result = await execute(buildParams(state.nextCursor));
    if (isClosed) return;

    switch (result) {
      case SuccessResult(:final value):
        final known = state.items.map((e) => e.id).toSet();
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...value.data.where((e) => !known.contains(e.id)),
            ],
            nextCursor: () => value.nextCursor,
            hasNextPage: value.hasMore && value.nextCursor != null,
            isLoading: false,
          ),
        );
      case FailureResult(:final failure):
        emit(state.copyWith(isLoading: false, failure: () => failure));
    }
  }

  /// Clears everything and fetches the first page again.
  Future<void> refresh() async {
    emit(PagingState<T>());
    await fetchNextPage();
  }

  /// Replaces the item with the same id as [item]. No-op if absent.
  void replaceItem(T item) => emit(
    state.copyWith(
      items: [
        for (final e in state.items)
          if (e.id == item.id) item else e,
      ],
    ),
  );

  /// Removes the item with [id].
  void removeItem(String id) => emit(
    state.copyWith(items: state.items.where((e) => e.id != id).toList()),
  );

  /// Inserts [item] at [index] (default: top). No-op if its id exists.
  void insertItem(T item, {int index = 0}) {
    if (state.items.any((e) => e.id == item.id)) return;
    final items = [...state.items]
      ..insert(index.clamp(0, state.items.length), item);
    emit(state.copyWith(items: items));
  }
}

/// State of a [PagingCubit].
final class PagingState<T> extends Equatable {
  /// Creates the state; defaults describe "nothing loaded yet".
  const PagingState({
    this.items = const [],
    this.nextCursor,
    this.hasNextPage = true,
    this.isLoading = false,
    this.failure,
  });

  /// Every item loaded so far, in order.
  final List<T> items;

  /// Cursor for the next page (`null` before the first fetch).
  final String? nextCursor;

  /// Whether more pages can be fetched.
  final bool hasNextPage;

  /// Whether a page is being fetched.
  final bool isLoading;

  /// The last fetch failure, cleared by the next fetch.
  final Failure? failure;

  /// Whether the first page is loading.
  bool get isFirstPageLoading => isLoading && items.isEmpty;

  /// Returns a copy with the given fields replaced. Nullable fields take a
  /// function so they can be explicitly set to `null`.
  PagingState<T> copyWith({
    List<T>? items,
    String? Function()? nextCursor,
    bool? hasNextPage,
    bool? isLoading,
    Failure? Function()? failure,
  }) => PagingState<T>(
    items: items ?? this.items,
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    isLoading: isLoading ?? this.isLoading,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    hasNextPage,
    isLoading,
    failure,
  ];
}
