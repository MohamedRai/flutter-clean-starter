/// The build environments. Each has its own entry point
/// (`lib/main_<flavor>.dart`), env file (`env/<flavor>.json`), Android
/// product flavor and iOS scheme.
enum Flavor {
  /// Local development.
  dev,

  /// Pre-production / QA.
  staging,

  /// Production.
  prod,
}

/// Environment-dependent configuration, read from compile-time variables
/// supplied with `--dart-define-from-file=env/<flavor>.json`.
///
/// To add a variable, follow `docs/flavors-and-environments.md` (or the
/// `add-flavor-config` Claude skill): add it to every `env/*.json` and
/// `env/*.example.json`, then expose it here.
final class FlavorConfig {
  /// Creates a config. Prefer [FlavorConfig.fromEnvironment] outside tests.
  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableHttpLogs,
  });

  /// Reads the compile-time environment and checks it matches [flavor].
  ///
  /// Throws a [StateError] with a fix-it message when the env file is
  /// missing or belongs to another flavor — failing at startup beats
  /// silently calling the wrong backend.
  factory FlavorConfig.fromEnvironment(Flavor flavor) {
    const envFlavor = String.fromEnvironment('FLAVOR');
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const enableHttpLogs = bool.fromEnvironment('ENABLE_HTTP_LOGS');

    if (envFlavor != flavor.name || apiBaseUrl.isEmpty) {
      throw StateError(
        'Missing or mismatched environment for flavor "${flavor.name}" '
        '(got FLAVOR="$envFlavor"). Run with '
        '--dart-define-from-file=env/${flavor.name}.json — see README.',
      );
    }
    return FlavorConfig(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      enableHttpLogs: enableHttpLogs,
    );
  }

  /// The active flavor.
  final Flavor flavor;

  /// Base URL of the backend API.
  final String apiBaseUrl;

  /// Whether HTTP traffic is logged (never in prod).
  final bool enableHttpLogs;

  /// Whether this is the production flavor.
  bool get isProd => flavor == Flavor.prod;
}
