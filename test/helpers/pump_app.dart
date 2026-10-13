import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/l10n/gen/app_localizations.dart';
import 'package:flutter_clean_starter/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-test helpers.
extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed, localized [MaterialApp].
  Future<void> pumpApp(Widget widget, {Locale locale = const Locale('en')}) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
