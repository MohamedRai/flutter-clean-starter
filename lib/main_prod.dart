import 'package:flutter_clean_starter/app/bootstrap.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';

/// Entry point for the `prod` flavor.
///
/// ```sh
/// flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
/// ```
Future<void> main() => bootstrap(Flavor.prod);
