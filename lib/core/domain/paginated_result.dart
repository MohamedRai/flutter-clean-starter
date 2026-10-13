import 'package:collection/collection.dart';
import 'package:flutter_clean_starter/core/data/domain_convertible.dart';
import 'package:meta/meta.dart';

/// One page of a cursor-paginated collection.
///
/// [nextCursor] is the opaque token the server returned for the following
/// page; [hasMore] is `false` once the end of the collection is reached.
@immutable
final class PaginatedResult<T> {
  /// Creates a page of [data].
  const PaginatedResult({
    required this.data,
    required this.hasMore,
    this.nextCursor,
  });

  /// An empty page with no more data — handy before the first fetch.
  const PaginatedResult.empty()
    : data = const [],
      nextCursor = null,
      hasMore = false;

  /// Items on this page.
  final List<T> data;

  /// Cursor for the next page, or `null` when there is none.
  final String? nextCursor;

  /// Whether more pages can be fetched.
  final bool hasMore;

  /// Returns a copy with the given fields replaced.
  PaginatedResult<T> copyWith({
    List<T>? data,
    String? nextCursor,
    bool? hasMore,
  }) {
    return PaginatedResult<T>(
      data: data ?? this.data,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResult<T> &&
        ListEquality<T>().equals(other.data, data) &&
        other.nextCursor == nextCursor &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode =>
      Object.hash(ListEquality<T>().hash(data), nextCursor, hasMore);

  @override
  String toString() =>
      'PaginatedResult(count: ${data.length}, hasMore: $hasMore, '
      'nextCursor: $nextCursor)';
}

/// Transformations on [PaginatedResult].
extension PaginatedResultX<T> on PaginatedResult<T> {
  /// Maps every item to [R], preserving pagination metadata.
  ///
  /// Typical use: a data source returns `PaginatedResult<PostModel>` and the
  /// repository maps it with `.transform((m) => m.toEntity())`.
  PaginatedResult<R> transform<R>(R Function(T item) mapper) {
    return PaginatedResult<R>(
      data: data.map(mapper).toList(),
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  /// Appends [nextPage] to this page, keeping the newer cursor.
  PaginatedResult<T> append(PaginatedResult<T> nextPage) {
    return PaginatedResult<T>(
      data: [...data, ...nextPage.data],
      nextCursor: nextPage.nextCursor,
      hasMore: nextPage.hasMore,
    );
  }
}

/// Converts a page of models into a page of entities.
extension PaginatedResultConvertibleX<T extends DomainConvertible<R>, R>
    on PaginatedResult<T> {
  /// Calls [DomainConvertible.toEntity] on every item.
  PaginatedResult<R> toEntities() => transform((item) => item.toEntity());
}
