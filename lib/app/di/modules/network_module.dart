import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';
import 'package:flutter_clean_starter/app/session/app_session.dart';
import 'package:flutter_clean_starter/core/error/exception_mapper.dart';
import 'package:flutter_clean_starter/core/network/dio_client_factory.dart';
import 'package:flutter_clean_starter/core/network/http_exception_mapper.dart';
import 'package:flutter_clean_starter/core/network/interceptors/auth_token_interceptor.dart';
import 'package:flutter_clean_starter/core/network/interceptors/error_mapping_interceptor.dart';
import 'package:flutter_clean_starter/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_clean_starter/core/network/interceptors/retry_interceptor.dart';
import 'package:injectable/injectable.dart';

/// Registers the HTTP stack.
@module
abstract class NetworkModule {
  /// Maps HTTP errors to `AppException`s. Replace it with a subclass to
  /// support your backend's error format.
  @lazySingleton
  ExceptionMapper get exceptionMapper => const HttpExceptionMapper();

  /// The configured API client for [FlavorConfig.apiBaseUrl].
  @lazySingleton
  Dio dio(FlavorConfig config, ExceptionMapper mapper, AppSession session) =>
      DioClientFactory.create(
        baseUrl: config.apiBaseUrl,
        interceptorsBuilder: (dio) => [
          AuthTokenInterceptor(
            readToken: session.readAccessToken,
            onUnauthorized: session.signOut,
          ),
          if (config.enableHttpLogs) LoggingInterceptor(),
          RetryInterceptor(dio: dio),
          ErrorMappingInterceptor(mapper),
        ],
      );
}
