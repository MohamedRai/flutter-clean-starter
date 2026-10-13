import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/app/router/route_paths.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';
import 'package:go_router/go_router.dart';

/// Shown for any unknown location (bad deep link, typo, removed route).
class NotFoundPage extends StatelessWidget {
  /// Creates the page for [uri].
  const NotFoundPage({required this.uri, super.key});

  /// The location that could not be matched.
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_off, size: 64, color: context.colors.outline),
              AppSpacing.gapLg,
              Text(l10n.notFoundMessage, textAlign: TextAlign.center),
              AppSpacing.gapSm,
              Text(
                uri.toString(),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapLg,
              FilledButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text(l10n.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
