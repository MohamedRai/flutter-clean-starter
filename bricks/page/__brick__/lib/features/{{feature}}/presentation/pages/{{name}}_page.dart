import 'package:flutter/material.dart';
import 'package:{{package}}/core/theme/tokens/app_spacing.dart';
import 'package:{{package}}/core/widgets/empty_state.dart';

/// {{name.sentenceCase()}} page.
///
/// Keep it a thin shell: read state with BlocBuilder, extract sections into
/// `presentation/widgets/`, and receive navigation as callbacks.
class {{name.pascalCase()}}Page extends StatelessWidget {
  /// Creates the page. Pass a localized [title] from the route.
  const {{name.pascalCase()}}Page({required this.title, super.key});

  /// App-bar title.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Padding(padding: AppSpacing.page, child: EmptyState()),
    );
  }
}
