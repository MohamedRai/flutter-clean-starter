import 'dart:io';

import 'package:mason/mason.dart';

/// Applies lint fixes (import order depends on the package name), formats
/// the generated files, then prints the next steps.
Future<void> run(HookContext context) async {
  String v(String key) => '${context.vars[key] ?? ''}';
  final feature = snake(v('feature'));
  final dirs = ['lib/features/$feature', 'test/features/$feature']
      .where((d) => Directory(d).existsSync())
      .toList();

  final progress = context.logger.progress('dart fix + dart format');
  for (final dir in dirs) {
    await Process.run('dart', ['fix', '--apply', dir], runInShell: true);
  }
  await Process.run('dart', ['format', ...dirs], runInShell: true);
  progress.complete();
  context.logger.info('''
Requires the `${snake(v('name'))}` model (mason make model).
Next steps:
  1. dart run build_runner build      (registers it in DI)
  2. flutter test test/features/${snake(v('feature'))}''');
}

List<String> _words(String s) => s
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .toLowerCase()
    .split(RegExp('[^a-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .toList();

/// `order_items`
String snake(String s) => _words(s).join('_');

/// `order-items`
String param(String s) => _words(s).join('-');

/// `OrderItems`
String pascal(String s) =>
    _words(s).map((w) => w[0].toUpperCase() + w.substring(1)).join();

/// `orderItems`
String camel(String s) {
  final p = pascal(s);
  return p.isEmpty ? p : p[0].toLowerCase() + p.substring(1);
}
