import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';

/// A network image with disk caching, a neutral placeholder and an error
/// fallback. Use it instead of `Image.network` everywhere.
///
/// Pass [width]/[height] whenever known: the image is then decoded at that
/// size, which saves memory in long lists.
class AppNetworkImage extends StatelessWidget {
  /// Creates the image for [url].
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    super.key,
  });

  /// Image URL.
  final String url;

  /// Display width.
  final double? width;

  /// Display height.
  final double? height;

  /// How the image fills its box.
  final BoxFit fit;

  /// Corner radius.
  final BorderRadius borderRadius;

  /// Accessibility description; `null` marks the image as decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final placeholder = ColoredBox(
      color: context.colors.surfaceContainerHighest,
      child: SizedBox(width: width, height: height),
    );
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: width == null ? null : (width! * pixelRatio).round(),
          memCacheHeight: height == null
              ? null
              : (height! * pixelRatio).round(),
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => Stack(
            alignment: Alignment.center,
            children: [
              placeholder,
              Icon(Icons.broken_image_outlined, color: context.colors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
