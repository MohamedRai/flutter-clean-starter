import 'package:flutter/material.dart';

/// Typography tokens.
///
/// The text theme starts from Material 3 defaults; adjust weights here. To
/// use a custom font, declare it in `pubspec.yaml` and set [fontFamily].
abstract final class AppTypography {
  /// Custom font family, or `null` for the platform default.
  static const String? fontFamily = null;

  /// Applies project-wide tweaks on top of [base].
  static TextTheme textTheme(TextTheme base) => base.copyWith(
    headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}
