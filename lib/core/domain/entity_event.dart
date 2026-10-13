/// A change to an entity, broadcast so other parts of the app can react
/// (e.g. a detail page deleting an item that a list page is showing).
///
/// Typically emitted by a repository on a `Stream<EntityEvent<T>>` or through
/// the `EventBus`.
sealed class EntityEvent<T> {
  const EntityEvent(this.value);

  /// The entity that changed.
  final T value;
}

/// [value] was created.
final class EntityCreated<T> extends EntityEvent<T> {
  /// Creates the event.
  const EntityCreated(super.value);
}

/// [value] was updated.
final class EntityUpdated<T> extends EntityEvent<T> {
  /// Creates the event.
  const EntityUpdated(super.value);
}

/// [value] was deleted.
final class EntityDeleted<T> extends EntityEvent<T> {
  /// Creates the event.
  const EntityDeleted(super.value);
}
