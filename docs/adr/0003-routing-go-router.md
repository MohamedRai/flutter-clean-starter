# 0003. go_router with typed routes; navigation through callbacks

- Status: Accepted
- Date: 2026-10-13

## Context

The app needs declarative routing with deep links, a bottom-navigation
shell that keeps per-tab stacks, auth redirects and a 404 page. String
paths scattered in widgets break silently when routes change, and features
importing the router couple them to the app shell.

## Decision

- Use `go_router` (the Flutter team's router) with `go_router_builder` for
  type-safe routes in one file, `app/router/app_routes.dart`.
- Use `StatefulShellRoute` for tabs, a global `redirect` (`AuthGuard`)
  refreshed by `AppSession`, and `errorBuilder` for unknown routes.
- Route classes are the composition root of their page: they create the
  bloc from DI and pass navigation as callbacks. Features never import
  `app/`.

## Consequences

- Compile-time-checked navigation and parameters.
- Pages are trivially testable (no router or GetIt needed).
- Adding a route requires editing `app_routes.dart` and running
  `build_runner`; the `feature`/`page` bricks print the snippet.
