import 'package:flutter/material.dart';

/// Color tokens. Re-brand the app by changing [seed] (and, if needed, the
/// semantic colors below) — every `ColorScheme` color derives from it.
///
/// Widgets must read colors from `Theme.of(context).colorScheme` (or
/// `context.colors`), never from this class directly, so light/dark themes
/// keep working.
abstract final class AppColors {
  /// Brand seed color used to generate the Material 3 color schemes.
  static const seed = Color(0xFF3F51B5);

  /// Semantic color for success states.
  static const success = Color(0xFF2E7D32);

  /// Semantic color for warnings.
  static const warning = Color(0xFFED6C02);
}
