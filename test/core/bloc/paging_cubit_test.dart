import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/bloc/paging_cubit.dart';
import 'package:flutter_clean_starter/core/domain/identifiable.dart';
import 'package:flutter_clean_starter/core/domain/paginated_result.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Item extends Equatable implements Identifiable {
  const _Item(this.id);

  @override
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Serves pages from [pages], keyed by cursor (`null` = first).
class _ItemsCubit extends PagingCubit<_Item, String?> {
  _ItemsCubit(this.pages);

  final Map<String?, FutureResult<PaginatedResult<_Item>> Function()> pages;

  @override
  FutureResult<PaginatedResult<_Item>> execute(String? cursor) =>
      pages[cursor]!();

  @override
  String? buildParams(String? cursor) => cursor;
}

void main() {
  const a = _Item('a');
  const b = _Item('b');
  const c = _Item('c');

  FutureResult<PaginatedResult<_Item>> page(
    List<_Item> items, {
    String? next,
  }) async => Result.success(
    PaginatedResult(data: items, nextCursor: next, hasMore: next != null),
  );

  group('PagingCubit', () {
    blocTest<_ItemsCubit, PagingState<_Item>>(
      'loads pages, de-duplicates, and stops at the end',
      build: () => _ItemsCubit({
        null: () => page([a, b], next: '2'),
        '2': () => page([b, c]),
      }),
      act: (cubit) async {
        await cubit.fetchNextPage();
        await cubit.fetchNextPage();
        await cubit.fetchNextPage(); // no more pages: no-op
      },
      expect: () => const [
        PagingState<_Item>(isLoading: true),
        PagingState<_Item>(items: [a, b], nextCursor: '2'),
        PagingState<_Item>(items: [a, b], nextCursor: '2', isLoading: true),
        PagingState<_Item>(items: [a, b, c], hasNextPage: false),
      ],
    );

    blocTest<_ItemsCubit, PagingState<_Item>>(
      'keeps items and exposes the failure',
      build: () => _ItemsCubit({
        null: () async => const Result.failure(NetworkFailure()),
      }),
      act: (cubit) => cubit.fetchNextPage(),
      expect: () => const [
        PagingState<_Item>(isLoading: true),
        PagingState<_Item>(failure: NetworkFailure()),
      ],
    );

    blocTest<_ItemsCubit, PagingState<_Item>>(
      'mutates items in place',
      build: () => _ItemsCubit({}),
      seed: () => const PagingState<_Item>(items: [a, b]),
      act: (cubit) => cubit
        ..insertItem(c)
        ..insertItem(c) // duplicate: ignored
        ..replaceItem(b)
        ..removeItem('a'),
      expect: () => const [
        PagingState<_Item>(items: [c, a, b]),
        PagingState<_Item>(items: [c, b]),
      ],
    );

    blocTest<_ItemsCubit, PagingState<_Item>>(
      'refresh starts over from the first page',
      build: () => _ItemsCubit({
        null: () => page([a]),
      }),
      seed: () => const PagingState<_Item>(items: [b], hasNextPage: false),
      act: (cubit) => cubit.refresh(),
      expect: () => const [
        PagingState<_Item>(),
        PagingState<_Item>(isLoading: true),
        PagingState<_Item>(items: [a], hasNextPage: false),
      ],
    );
  });
}
