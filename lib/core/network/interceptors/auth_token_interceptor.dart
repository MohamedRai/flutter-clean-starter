import 'dart:async';

import 'package:dio/dio.dart';

/// Adds `Authorization: Bearer <token>` to every request that has a token.
///
/// Opt a single request out with `Options(extra: {skipAuthKey: true})`.
///
/// On a `401` response [onUnauthorized] is called (e.g. to clear the session
/// and redirect to sign-in) and the error continues down the chain. Token
/// refresh is backend-specific: add it by overriding [onError].
class AuthTokenInterceptor extends Interceptor {
  /// Creates the interceptor.
  ///
  /// [readToken] is called before each request; return `null` when signed
  /// out.
  AuthTokenInterceptor({required this.readToken, this.onUnauthorized});

  /// `Options.extra` key that disables the header for one request.
  static const skipAuthKey = 'skipAuth';

  /// Supplies the current access token.
  final Future<String?> Function() readToken;

  /// Called when the server answers `401`.
  final FutureOr<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      final token = await readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
