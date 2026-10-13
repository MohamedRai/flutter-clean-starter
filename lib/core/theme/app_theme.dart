import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_colors.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_typography.dart';

/// Material 3 light and dark themes built from the design tokens.
abstract final class AppTheme {
  /// The light theme.
  static ThemeData get light => _build(Brightness.light);

  /// The dark theme.
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      // Token hook: null today, set AppTypography.fontFamily to brand.
      // ignore: avoid_redundant_argument_values
      fontFamily: AppTypography.fontFamily,
    );
    return base.copyWith(
      textTheme: AppTypography.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadius.card),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
    );
  }
}
