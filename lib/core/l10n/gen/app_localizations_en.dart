// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clean Starter';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get emptyGeneric => 'Nothing here yet.';

  @override
  String get failureServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get failureNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get failureCache => 'No saved data is available.';

  @override
  String get failureUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get failureForbidden => 'You don\'t have permission to do this.';

  @override
  String get failureNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get failureBadRequest =>
      'The request couldn\'t be processed. Please check your input.';

  @override
  String get failureRateLimit =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get failureValidation => 'Please check the highlighted fields.';

  @override
  String get failureUnknown =>
      'An unexpected error occurred. Please try again.';

  @override
  String get navPosts => 'Posts';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get settingsAccount => 'Account';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSignedIn => 'You are signed in (demo session).';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInMessage =>
      'This page demonstrates the router\'s auth guard. Sign in to open the account page.';

  @override
  String get signInButton => 'Sign in (demo)';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'The page you requested doesn\'t exist.';

  @override
  String get goHome => 'Go home';

  @override
  String get postsTitle => 'Posts';

  @override
  String get postsEmpty => 'No posts yet.';

  @override
  String get postDetailTitle => 'Post';

  @override
  String postAuthor(int userId) {
    return 'By user #$userId';
  }
}
