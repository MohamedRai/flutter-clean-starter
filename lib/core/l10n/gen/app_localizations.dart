import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Application name shown in the app bar and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Clean Starter'**
  String get appTitle;

  /// Button that retries a failed action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Accessibility label for loading indicators.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Default empty-state message.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptyGeneric;

  /// Shown for server errors.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get failureServer;

  /// Shown when offline or on timeout.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get failureNetwork;

  /// Shown when offline data is missing.
  ///
  /// In en, this message translates to:
  /// **'No saved data is available.'**
  String get failureCache;

  /// Shown on HTTP 401.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get failureUnauthorized;

  /// Shown on HTTP 403.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get failureForbidden;

  /// Shown on HTTP 404.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get failureNotFound;

  /// Shown on HTTP 400/409.
  ///
  /// In en, this message translates to:
  /// **'The request couldn\'t be processed. Please check your input.'**
  String get failureBadRequest;

  /// Shown on HTTP 429.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get failureRateLimit;

  /// Shown for validation failures.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get failureValidation;

  /// Fallback error message.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get failureUnknown;

  /// Bottom navigation label for the posts tab.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get navPosts;

  /// Bottom navigation label for the settings tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Settings section title for theme mode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Follow the system theme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings section title for the app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Follow the device language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// Settings entry for the protected account page.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Title of the protected account page.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Body of the account page.
  ///
  /// In en, this message translates to:
  /// **'You are signed in (demo session).'**
  String get accountSignedIn;

  /// Sign-out button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Title of the sign-in page.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// Explains the demo sign-in page.
  ///
  /// In en, this message translates to:
  /// **'This page demonstrates the router\'s auth guard. Sign in to open the account page.'**
  String get signInMessage;

  /// Starts a demo session.
  ///
  /// In en, this message translates to:
  /// **'Sign in (demo)'**
  String get signInButton;

  /// Title of the 404 page.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Body of the 404 page.
  ///
  /// In en, this message translates to:
  /// **'The page you requested doesn\'t exist.'**
  String get notFoundMessage;

  /// Button that navigates to the home page.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// Title of the posts list page.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsTitle;

  /// Empty state of the posts list.
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get postsEmpty;

  /// Title of the post detail page.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetailTitle;

  /// Author line of a post.
  ///
  /// In en, this message translates to:
  /// **'By user #{userId}'**
  String postAuthor(int userId);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
