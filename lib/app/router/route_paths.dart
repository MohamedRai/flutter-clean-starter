/// Every route path, in one place. Use the typed routes in `app_routes.dart`
/// to navigate (`const PostsRoute().go(context)`); use these constants only
/// where a raw string is unavoidable (guards, deep-link docs, tests).
abstract final class RoutePaths {
  // example:begin
  /// Posts list (example feature).
  static const posts = '/posts';

  /// Post detail, relative to [posts].
  static const postDetail = ':id';
  // example:end

  /// Settings tab.
  static const settings = '/settings';

  /// Protected account page, relative to [settings].
  static const account = 'account';

  /// Absolute path of the account page, used by the auth guard.
  static const accountFull = '$settings/$account';

  /// Demo sign-in page.
  static const signIn = '/sign-in';

  // example:begin
  /// Where the app starts and "Go home" leads.
  static const String home = posts;
  // example:end
  // example:uncomment /// Where the app starts and "Go home" leads.
  // example:uncomment static const String home = settings;
}
