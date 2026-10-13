import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';
import 'package:flutter_clean_starter/core/cache/data_cache_store.dart';
import 'package:flutter_clean_starter/core/cache/in_memory_data_cache_store.dart';
import 'package:flutter_clean_starter/core/events/event_bus.dart';
import 'package:flutter_clean_starter/core/network/network_info.dart';
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart';
import 'package:flutter_clean_starter/core/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers core services and third-party singletons.
///
/// Core classes are annotation-free; they are wired here so `lib/core`
/// does not depend on the DI framework.
@module
abstract class CoreModule {
  /// Shared preferences, created once at startup.
  @preResolve
  @singleton
  Future<SharedPreferencesWithCache> get sharedPreferences =>
      SharedPreferencesStorage.createPreferences();

  /// Non-sensitive key-value storage.
  @lazySingleton
  KeyValueStorage keyValueStorage(SharedPreferencesWithCache prefs) =>
      SharedPreferencesStorage(prefs);

  /// Encrypted storage for secrets.
  @lazySingleton
  SecureStorage get secureStorage =>
      const FlutterSecureStorageImpl(FlutterSecureStorage());

  /// Connectivity status.
  @lazySingleton
  NetworkInfo get networkInfo => ConnectivityNetworkInfo(Connectivity());

  /// In-memory cache shared by repositories.
  @lazySingleton
  DataCacheStore get dataCacheStore => InMemoryDataCacheStore();

  /// App-wide event bus.
  @LazySingleton(dispose: disposeEventBus)
  EventBus eventBus(FlavorConfig config) => EventBus(debug: !config.isProd);
}

/// Closes the [EventBus] when GetIt is reset.
Future<void> disposeEventBus(EventBus bus) => bus.dispose();
