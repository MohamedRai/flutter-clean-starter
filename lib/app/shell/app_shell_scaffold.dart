import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:go_router/go_router.dart';

/// The scaffold around every tab: shows the bottom [NavigationBar] and the
/// current branch.
///
/// Keep the destinations in the same order as the branches in
/// `AppShellRoute`.
class AppShellScaffold extends StatelessWidget {
  /// Creates the scaffold for [navigationShell].
  const AppShellScaffold({required this.navigationShell, super.key});

  /// The go_router shell that holds the branches.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      // example:begin
      NavigationDestination(
        icon: const Icon(Icons.article_outlined),
        selectedIcon: const Icon(Icons.article),
        label: l10n.navPosts,
      ),
      // example:end
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.navSettings,
      ),
    ];
    return Scaffold(
      body: navigationShell,
      // NavigationBar needs at least two destinations.
      bottomNavigationBar: destinations.length < 2
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                // Tapping the active tab returns to its root.
                initialLocation: index == navigationShell.currentIndex,
              ),
              destinations: destinations,
            ),
    );
  }
}
