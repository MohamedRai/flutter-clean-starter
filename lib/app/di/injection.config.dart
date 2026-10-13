// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_clean_starter/app/di/modules/core_module.dart'
    as _i1003;
import 'package:flutter_clean_starter/app/di/modules/network_module.dart'
    as _i806;
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart' as _i298;
import 'package:flutter_clean_starter/app/router/app_router.dart' as _i473;
import 'package:flutter_clean_starter/app/session/app_session.dart' as _i835;
import 'package:flutter_clean_starter/core/cache/data_cache_store.dart'
    as _i153;
import 'package:flutter_clean_starter/core/error/exception_mapper.dart'
    as _i861;
import 'package:flutter_clean_starter/core/events/event_bus.dart' as _i456;
import 'package:flutter_clean_starter/core/network/network_info.dart' as _i887;
import 'package:flutter_clean_starter/core/storage/key_value_storage.dart'
    as _i436;
import 'package:flutter_clean_starter/core/storage/secure_storage.dart'
    as _i562;
import 'package:flutter_clean_starter/features/posts/data/datasources/post_local_data_source.dart'
    as _i474;
import 'package:flutter_clean_starter/features/posts/data/datasources/post_remote_data_source.dart'
    as _i431;
import 'package:flutter_clean_starter/features/posts/data/repositories/post_repository_impl.dart'
    as _i117;
import 'package:flutter_clean_starter/features/posts/di/posts_module.dart'
    as _i995;
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart'
    as _i464;
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_post_by_id.dart'
    as _i941;
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_posts.dart'
    as _i903;
import 'package:flutter_clean_starter/features/posts/presentation/bloc/posts_bloc.dart'
    as _i679;
import 'package:flutter_clean_starter/features/posts/presentation/cubit/post_detail_cubit.dart'
    as _i265;
import 'package:flutter_clean_starter/features/settings/data/datasources/settings_local_data_source.dart'
    as _i444;
import 'package:flutter_clean_starter/features/settings/data/repositories/settings_repository_impl.dart'
    as _i61;
import 'package:flutter_clean_starter/features/settings/di/settings_module.dart'
    as _i160;
import 'package:flutter_clean_starter/features/settings/domain/repositories/settings_repository.dart'
    as _i895;
import 'package:flutter_clean_starter/features/settings/domain/usecases/get_settings.dart'
    as _i23;
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_language.dart'
    as _i694;
import 'package:flutter_clean_starter/features/settings/domain/usecases/update_theme_mode.dart'
    as _i727;
import 'package:flutter_clean_starter/features/settings/presentation/cubit/settings_cubit.dart'
    as _i643;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final networkModule = _$NetworkModule();
    final settingsModule = _$SettingsModule();
    final postsModule = _$PostsModule();
    await gh.singletonAsync<_i460.SharedPreferencesWithCache>(
      () => coreModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i562.SecureStorage>(() => coreModule.secureStorage);
    gh.lazySingleton<_i887.NetworkInfo>(() => coreModule.networkInfo);
    gh.lazySingleton<_i153.DataCacheStore>(() => coreModule.dataCacheStore);
    gh.lazySingleton<_i861.ExceptionMapper>(
      () => networkModule.exceptionMapper,
    );
    gh.lazySingleton<_i436.KeyValueStorage>(
      () => coreModule.keyValueStorage(gh<_i460.SharedPreferencesWithCache>()),
    );
    await gh.lazySingletonAsync<_i835.AppSession>(() {
      final i = _i835.AppSession(gh<_i562.SecureStorage>());
      return i.restore().then((_) => i);
    }, preResolve: true);
    gh.lazySingleton<_i473.AppRouter>(
      () => _i473.AppRouter(gh<_i835.AppSession>()),
    );
    gh.lazySingleton<_i474.PostLocalDataSource>(
      () => _i474.PostLocalDataSourceImpl(gh<_i436.KeyValueStorage>()),
    );
    gh.lazySingleton<_i456.EventBus>(
      () => coreModule.eventBus(gh<_i298.FlavorConfig>()),
      dispose: _i1003.disposeEventBus,
    );
    gh.lazySingleton<_i444.SettingsLocalDataSource>(
      () => _i444.SettingsLocalDataSourceImpl(gh<_i436.KeyValueStorage>()),
    );
    gh.lazySingleton<_i895.SettingsRepository>(
      () => _i61.SettingsRepositoryImpl(
        gh<_i444.SettingsLocalDataSource>(),
        cacheStore: gh<_i153.DataCacheStore>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i298.FlavorConfig>(),
        gh<_i861.ExceptionMapper>(),
        gh<_i835.AppSession>(),
      ),
    );
    gh.lazySingleton<_i431.PostRemoteDataSource>(
      () => _i431.PostRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        exceptionMapper: gh<_i861.ExceptionMapper>(),
      ),
    );
    gh.lazySingleton<_i23.GetSettings>(
      () => settingsModule.getSettings(gh<_i895.SettingsRepository>()),
    );
    gh.lazySingleton<_i727.UpdateThemeMode>(
      () => settingsModule.updateThemeMode(gh<_i895.SettingsRepository>()),
    );
    gh.lazySingleton<_i694.UpdateLanguage>(
      () => settingsModule.updateLanguage(gh<_i895.SettingsRepository>()),
    );
    gh.factory<_i643.SettingsCubit>(
      () => _i643.SettingsCubit(
        gh<_i23.GetSettings>(),
        gh<_i727.UpdateThemeMode>(),
        gh<_i694.UpdateLanguage>(),
      ),
    );
    gh.lazySingleton<_i464.PostRepository>(
      () => _i117.PostRepositoryImpl(
        gh<_i431.PostRemoteDataSource>(),
        gh<_i474.PostLocalDataSource>(),
        cacheStore: gh<_i153.DataCacheStore>(),
      ),
    );
    gh.lazySingleton<_i903.GetPosts>(
      () => postsModule.getPosts(gh<_i464.PostRepository>()),
    );
    gh.lazySingleton<_i941.GetPostById>(
      () => postsModule.getPostById(gh<_i464.PostRepository>()),
    );
    gh.factory<_i265.PostDetailCubit>(
      () => _i265.PostDetailCubit(gh<_i941.GetPostById>()),
    );
    gh.factory<_i679.PostsBloc>(() => _i679.PostsBloc(gh<_i903.GetPosts>()));
    return this;
  }
}

class _$CoreModule extends _i1003.CoreModule {}

class _$NetworkModule extends _i806.NetworkModule {}

class _$SettingsModule extends _i160.SettingsModule {}

class _$PostsModule extends _i995.PostsModule {}
