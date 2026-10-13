import 'package:flutter_clean_starter/app/bootstrap.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';

/// Entry point for the `dev` flavor.
///
/// ```sh
/// flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
/// ```
Future<void> main() => bootstrap(Flavor.dev);
