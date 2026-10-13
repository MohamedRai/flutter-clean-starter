import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_starter/app/router/app_routes.dart';
import 'package:flutter_clean_starter/app/router/route_paths.dart';
import 'package:flutter_clean_starter/app/session/app_session.dart';
import 'package:go_router/go_router.dart';

/// Redirects signed-out users away from protected routes, and signed-in
/// users away from the sign-in page.
///
/// Used as `GoRouter.redirect`; the router re-runs it whenever
/// [AppSession] notifies (sign-in / sign-out).
class AuthGuard {
  /// Creates the guard.
  const AuthGuard(
    this._session, {
    this.protectedPaths = const [RoutePaths.accountFull],
  });

  final AppSession _session;

  /// Path prefixes that require a session.
  final List<String> protectedPaths;

  /// The redirect callback for `GoRouter`.
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final signedIn = _session.isAuthenticated;

    if (!signedIn && protectedPaths.any(location.startsWith)) {
      return SignInRoute(from: state.uri.toString()).location;
    }
    if (signedIn && location == RoutePaths.signIn) {
      return state.uri.queryParameters['from'] ?? RoutePaths.home;
    }
    return null;
  }
}
