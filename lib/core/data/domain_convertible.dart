/// A data-layer model (DTO) that can be converted to a domain entity [E].
///
/// Implemented by every model in `features/*/data/models/`, so the
/// conversion lives in the data layer and entities stay free of JSON.
abstract interface class DomainConvertible<E> {
  /// Converts this model to its domain entity.
  E toEntity();
}
