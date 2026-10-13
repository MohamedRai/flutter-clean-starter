/// An entity with a stable, unique string identifier.
///
/// Required by `PagingCubit` to de-duplicate and mutate list items by id.
abstract interface class Identifiable {
  /// The unique identifier of this entity.
  String get id;
}
