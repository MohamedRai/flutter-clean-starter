import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/app/di/injection.dart';
import 'package:flutter_clean_starter/app/router/route_paths.dart';
import 'package:flutter_clean_starter/app/session/app_session.dart';
import 'package:flutter_clean_starter/app/session/pages/account_page.dart';
import 'package:flutter_clean_starter/app/session/pages/sign_in_page.dart';
import 'package:flutter_clean_starter/app/shell/app_shell_scaffold.dart';
import 'package:flutter_clean_starter/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_clean_starter/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:flutter_clean_starter/features/posts/presentation/pages/post_detail_page.dart';
import 'package:flutter_clean_starter/features/posts/presentation/pages/posts_page.dart';
import 'package:flutter_clean_starter/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

// Typed routes (go_router_builder). After editing this file run
// `dart run build_runner build`. Route classes are the composition root
// for pages: they create the page's bloc/cubit from DI and pass navigation
// callbacks, so features never import the router or GetIt.

/// The bottom-navigation shell. One branch per tab; each keeps its own
/// navigation stack.
@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    // example:begin
    TypedStatefulShellBranch<PostsBranch>(
      routes: [
        TypedGoRoute<PostsRoute>(
          path: RoutePaths.posts,
          routes: [TypedGoRoute<PostDetailRoute>(path: RoutePaths.postDetail)],
        ),
      ],
    ),
    // example:end
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [
        TypedGoRoute<SettingsRoute>(
          path: RoutePaths.settings,
          routes: [TypedGoRoute<AccountRoute>(path: RoutePaths.account)],
        ),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  /// Creates the route.
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShellScaffold(navigationShell: navigationShell);
}

// example:begin
/// The posts tab.
class PostsBranch extends StatefulShellBranchData {
  /// Creates the branch.
  const PostsBranch();
}

/// `/posts`
class PostsRoute extends GoRouteData with $PostsRoute {
  /// Creates the route.
  const PostsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (_) => getIt<PostsBloc>()..add(const PostsRequested()),
    child: PostsPage(onPostTap: (id) => PostDetailRoute(id: id).go(context)),
  );
}

/// `/posts/:id`
class PostDetailRoute extends GoRouteData with $PostDetailRoute {
  /// Creates the route for post [id].
  const PostDetailRoute({required this.id});

  /// The post to show.
  final int id;

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (_) {
      final cubit = getIt<PostDetailCubit>();
      unawaited(cubit.load(id));
      return cubit;
    },
    child: const PostDetailPage(),
  );
}
// example:end

/// The settings tab.
class SettingsBranch extends StatefulShellBranchData {
  /// Creates the branch.
  const SettingsBranch();
}

/// `/settings`
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates the route.
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SettingsPage(onAccountTap: () => const AccountRoute().go(context));
}

/// `/settings/account` — protected by `AuthGuard`.
class AccountRoute extends GoRouteData with $AccountRoute {
  /// Creates the route.
  const AccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AccountPage(session: getIt<AppSession>());
}

/// `/sign-in?from=...` — outside the shell (no bottom bar).
@TypedGoRoute<SignInRoute>(path: RoutePaths.signIn)
class SignInRoute extends GoRouteData with $SignInRoute {
  /// Creates the route. [from] is where to go after signing in.
  const SignInRoute({this.from});

  /// Location to return to after sign-in.
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SignInPage(session: getIt<AppSession>());
}
