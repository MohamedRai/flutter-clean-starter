import 'package:flutter/widgets.dart';

/// Spacing scale (4-pt grid). Use these instead of magic numbers.
abstract final class AppSpacing {
  /// 4
  static const double xs = 4;

  /// 8
  static const double sm = 8;

  /// 12
  static const double md = 12;

  /// 16 — default page padding.
  static const double lg = 16;

  /// 24
  static const double xl = 24;

  /// 32
  static const double xxl = 32;

  /// Default padding around page content.
  static const EdgeInsets page = EdgeInsets.all(lg);

  /// Vertical gap of [sm].
  static const SizedBox gapSm = SizedBox.square(dimension: sm);

  /// Vertical/horizontal gap of [lg].
  static const SizedBox gapLg = SizedBox.square(dimension: lg);
}

/// Corner radius scale.
abstract final class AppRadius {
  /// 4
  static const double sm = 4;

  /// 8
  static const double md = 8;

  /// 16
  static const double lg = 16;

  /// Fully rounded (pills, avatars).
  static const double full = 999;

  /// [BorderRadius] of [md].
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
}
