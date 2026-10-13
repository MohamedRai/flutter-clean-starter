import 'package:flutter/foundation.dart';
import 'package:flutter_clean_starter/app/router/app_routes.dart';
import 'package:flutter_clean_starter/app/router/guards/auth_guard.dart';
import 'package:flutter_clean_starter/app/router/route_paths.dart';
import 'package:flutter_clean_starter/app/session/app_session.dart';
import 'package:flutter_clean_starter/app/shell/not_found_page.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

/// Owns the app's single [GoRouter].
///
/// Deep links (`cleanstarter://app/posts/1` or an https App Link) are
/// handled by go_router out of the box once the platform is configured —
/// see `docs/routing.md`.
@lazySingleton
class AppRouter {
  /// Creates the router.
  AppRouter(this._session);

  final AppSession _session;

  /// The router passed to `MaterialApp.router`.
  late final GoRouter config = GoRouter(
    initialLocation: RoutePaths.home,
    routes: $appRoutes,
    refreshListenable: _session,
    redirect: AuthGuard(_session).redirect,
    errorBuilder: (context, state) => NotFoundPage(uri: state.uri),
    debugLogDiagnostics: kDebugMode,
  );
}
