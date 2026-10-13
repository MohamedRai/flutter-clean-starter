import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/app/session/app_session.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';

/// A page that requires a session (see `AuthGuard`).
class AccountPage extends StatelessWidget {
  /// Creates the page.
  const AccountPage({required this.session, super.key});

  /// The current session.
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: Padding(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.accountSignedIn, style: context.textTheme.bodyLarge),
            AppSpacing.gapLg,
            // Signing out makes the guard redirect to sign-in.
            OutlinedButton(
              onPressed: session.signOut,
              child: Text(l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
