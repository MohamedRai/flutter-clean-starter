import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/l10n/gen/app_localizations.dart';

/// Shortcuts for things widgets read from [BuildContext] all the time.
extension ContextX on BuildContext {
  /// The localized strings: `context.l10n.retry`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Whether the layout direction is right-to-left (e.g. Arabic).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Shows [message] in a [SnackBar], replacing any visible one.
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
