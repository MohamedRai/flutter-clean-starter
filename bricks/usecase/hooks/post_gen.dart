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

  // Register the use case in lib/features/<feature>/di/<feature>_module.dart.
  final module = File('lib/features/$feature/di/${feature}_module.dart');
  final useCase = pascal(v('name'));
  if (module.existsSync()) {
    var source = module.readAsStringSync();
    if (!source.contains('$useCase(')) {
      final base = "import 'package:${v('package')}/features/$feature/domain";
      final imports = [
        "$base/usecases/${snake(v('name'))}.dart';",
        "$base/repositories/${snake(v('entity'))}_repository.dart';",
      ].where((line) => !source.contains(line));
      final lastImport = source.lastIndexOf(RegExp('^import ', multiLine: true));
      final lineEnd = source.indexOf('\n', lastImport);
      source = '${source.substring(0, lineEnd + 1)}'
          '${imports.map((line) => '$line\n').join()}'
          '${source.substring(lineEnd + 1)}';
      final classEnd = source.lastIndexOf('}');
      source = '${source.substring(0, classEnd)}'
          '\n  /// See [$useCase].\n'
          '  @lazySingleton\n'
          '  $useCase ${camel(v('name'))}(${pascal(v('entity'))}Repository '
          'repository) => $useCase(repository);\n'
          '${source.substring(classEnd)}';
      module.writeAsStringSync(source);
      context.logger.info('Registered $useCase in ${module.path}');
    }
  } else {
    context.logger.warn(
      'No ${module.path}: register $useCase in a DI @module yourself.',
    );
  }
  final progress = context.logger.progress('dart fix + dart format');
  for (final dir in dirs) {
    await Process.run('dart', ['fix', '--apply', dir], runInShell: true);
  }
  await Process.run('dart', ['format', ...dirs], runInShell: true);
  progress.complete();
  context.logger.info('''
Next steps:
  1. dart run build_runner build      (picks up the DI registration)
  2. Inject ${pascal(v('name'))} into a bloc/cubit and add a test for it.''');
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
