import 'package:flutter_clean_starter/app/di/injection.config.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// The app's service locator. Only the composition root (`app/`) and
/// `BlocProvider(create: ...)` calls should use it — classes receive their
/// dependencies through constructors.
final GetIt getIt = GetIt.instance;

/// Registers every dependency for [config]'s flavor.
///
/// Code is generated into `injection.config.dart` by `build_runner` from
/// `@injectable`, `@lazySingleton` and `@module` annotations. The flavor name
/// is passed as the injectable environment, so `@Environment('dev')` etc.
/// work for flavor-specific implementations.
@InjectableInit(ignoreUnregisteredTypes: [FlavorConfig])
Future<void> configureDependencies(FlavorConfig config) async {
  getIt.registerSingleton<FlavorConfig>(config);
  await getIt.init(environment: config.flavor.name);
}
