import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/extensions/failure_message_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';

/// A full-area error message with an optional retry button.
class ErrorView extends StatelessWidget {
  /// Shows [message].
  const ErrorView({required this.message, this.onRetry, super.key});

  /// Shows the localized message for [failure].
  ///
  /// The retry button is only shown when [onRetry] is given.
  factory ErrorView.failure(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    Key? key,
  }) => ErrorView(
    message: failure.localizedMessage(context.l10n),
    onRetry: onRetry,
    key: key,
  );

  /// The message to display.
  final String message;

  /// Called when the user taps retry; hides the button when `null`.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.colors.error,
              semanticLabel: '',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
