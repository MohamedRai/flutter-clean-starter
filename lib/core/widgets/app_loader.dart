import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';

/// A centered, platform-adaptive progress indicator with an accessible
/// label.
class AppLoader extends StatelessWidget {
  /// Creates the loader.
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.loading,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
