import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a dashed border around [child] — rectangular, rounded, or circular.
///
/// ```dart
/// DashedBorder(
///   color: context.colors.outline,
///   borderRadius: AppRadius.card,
///   padding: AppSpacing.page,
///   child: const Text('Drop a file here'),
/// )
/// ```
class DashedBorder extends StatelessWidget {
  /// Creates the border. [color] defaults to the theme's outline color.
  const DashedBorder({
    required this.child,
    this.color,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.dashGap = 3,
    this.borderRadius,
    this.isCircular = false,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// The widget inside the border.
  final Widget child;

  /// Stroke color; defaults to `ColorScheme.outline`.
  final Color? color;

  /// Stroke width.
  final double strokeWidth;

  /// Length of each dash.
  final double dashLength;

  /// Gap between dashes.
  final double dashGap;

  /// Corner radius; ignored when [isCircular] is `true`.
  final BorderRadius? borderRadius;

  /// Draws a circle instead of a rectangle.
  final bool isCircular;

  /// Space between the border and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(
      color: color ?? Theme.of(context).colorScheme.outline,
      strokeWidth: strokeWidth,
      dashLength: dashLength,
      dashGap: dashGap,
      borderRadius: borderRadius,
      isCircular: isCircular,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.isCircular,
    this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final BorderRadius? borderRadius;
  final bool isCircular;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final path = Path();
    if (isCircular) {
      path.addOval(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: math.min(size.width, size.height) / 2 - strokeWidth / 2,
        ),
      );
    } else if (borderRadius != null) {
      path.addRRect(borderRadius!.toRRect(rect));
    } else {
      path.addRect(rect);
    }

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final end = math.min(
          distance + (draw ? dashLength : dashGap),
          metric.length,
        );
        if (draw) canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      dashGap != oldDelegate.dashGap ||
      borderRadius != oldDelegate.borderRadius ||
      isCircular != oldDelegate.isCircular;
}
