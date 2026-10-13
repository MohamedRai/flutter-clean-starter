import 'package:flutter_clean_starter/app/bootstrap.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';

/// Entry point for the `staging` flavor.
///
/// ```sh
/// flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.json
/// ```
Future<void> main() => bootstrap(Flavor.staging);
