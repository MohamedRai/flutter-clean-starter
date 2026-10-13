import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';

/// A full-area placeholder for lists or pages with no content.
class EmptyState extends StatelessWidget {
  /// Creates the placeholder. [message] defaults to a generic text.
  const EmptyState({
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  /// The text to show; defaults to `l10n.emptyGeneric`.
  final String? message;

  /// The illustration icon.
  final IconData icon;

  /// Optional call to action below the message (e.g. a "Create" button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.colors.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? context.l10n.emptyGeneric,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
