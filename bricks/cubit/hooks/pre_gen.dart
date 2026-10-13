import 'dart:io';

import 'package:mason/mason.dart';

/// Adds `package` (the app's pubspec name) to the template vars, so
/// generated imports work in any project created from this starter.
void run(HookContext context) {
  var dir = Directory.current;
  while (true) {
    final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspec.existsSync()) {
      final name = RegExp(r'^name:\s*(\S+)', multiLine: true)
          .firstMatch(pubspec.readAsStringSync())
          ?.group(1);
      if (name != null) {
        // Paths and imports use the raw vars, so normalize names to
        // snake_case (`OrderItems`, `order items` -> `order_items`).
        final vars = {
          ...context.vars,
          for (final key in const ['feature', 'name', 'entity'])
            if (context.vars[key] is String)
              key: snake(context.vars[key] as String),
        };
        context.vars = {...vars, 'package': name, ...extraVars(vars)};
        return;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  context.logger.err(
    'pubspec.yaml not found: run `mason make` from the project root.',
  );
  throw Exception('pubspec.yaml not found');
}

/// Brick-specific derived variables.
Map<String, Object?> extraVars(Map<String, dynamic> vars) => const {};

/// `order_items`
String snake(String s) => s
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .toLowerCase()
    .split(RegExp('[^a-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .join('_');
