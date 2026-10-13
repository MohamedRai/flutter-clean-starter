/// App-wide, environment-independent constants.
///
/// Environment-dependent values (API URLs, keys) belong in `env/*.json` and
/// are read through `FlavorConfig`, never here.
abstract final class AppConstants {
  /// Default number of items requested per page.
  static const pageSize = 20;

  /// Default TTL for repository caches.
  static const defaultCacheTtl = Duration(minutes: 5);

  /// Default duration of short UI animations.
  static const shortAnimation = Duration(milliseconds: 200);

  /// Default duration of medium UI animations.
  static const mediumAnimation = Duration(milliseconds: 350);
}
