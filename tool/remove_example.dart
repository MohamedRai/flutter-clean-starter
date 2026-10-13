// A command-line tool: printing progress is its whole job.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Removes the `posts` example feature: its code, tests, routes, navigation
/// tab, DI registrations (regenerated) and translations.
///
/// ```sh
/// dart run tool/remove_example.dart            # remove and regenerate
/// dart run tool/remove_example.dart --dry-run  # only list what changes
/// ```
///
/// How it works: in shared files, imports of `features/posts/` are
/// deleted, and example-only code is wrapped in `// example:begin` /
/// `// example:end` and deleted. A line written as
/// `// example:uncomment <code>` is turned into `<code>` (e.g. the new home
/// route). Afterwards `gen-l10n` and `build_runner` are re-run so the DI
/// config and typed routes no longer mention the feature, and imports that
/// became unused are removed with `dart fix`.
///
/// Imports are never wrapped in markers: `dart fix` may re-sort them (e.g.
/// after `tool/rename.dart`), which would move unrelated imports inside a
/// marked block.
Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final root = Directory.current;
  if (!File('${root.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('Run this from the project root.');
    exit(64);
  }

  final changes = <String>[];

  // 1. Delete example-only folders and files.
  const deletions = ['lib/features/posts', 'test/features/posts'];
  for (final path in deletions) {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.notFound) continue;
    changes.add('delete  $path');
    if (!dryRun) await Directory(path).delete(recursive: true);
  }

  // 2. Strip marked blocks from shared files.
  final sources =
      [
        ...Directory('lib').listSync(recursive: true),
        ...Directory('test').listSync(recursive: true),
        if (Directory('integration_test').existsSync())
          ...Directory('integration_test').listSync(recursive: true),
      ].whereType<File>().where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            !deletions.any(f.path.replaceAll(r'\', '/').startsWith),
      );
  for (final file in sources) {
    final original = file.readAsStringSync();
    if (!original.contains('// example:') &&
        !original.contains(exampleImport)) {
      continue;
    }
    final updated = stripExampleBlocks(original);
    if (updated == original) continue;
    changes.add('edit    ${file.path}');
    if (!dryRun) file.writeAsStringSync(updated);
  }

  // 3. Remove example translations from every ARB file.
  const arbKeys = [
    'navPosts',
    'postsTitle',
    'postsEmpty',
    'postDetailTitle',
    'postAuthor',
  ];
  for (final file in Directory(
    'lib/core/l10n/arb',
  ).listSync().whereType<File>()) {
    if (!file.path.endsWith('.arb')) continue;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final before = json.length;
    for (final key in arbKeys) {
      json
        ..remove(key)
        ..remove('@$key');
    }
    if (json.length == before) continue;
    changes.add('edit    ${file.path}');
    if (!dryRun) {
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(json)}\n',
      );
    }
  }

  if (changes.isEmpty) {
    print('Nothing to remove — the example feature is already gone.');
    return;
  }
  print(changes.join('\n'));
  if (dryRun) {
    print('\n--dry-run: no files were changed.');
    return;
  }

  // 4. Regenerate code that referenced the feature.
  for (final command in [
    ['flutter', 'gen-l10n'],
    ['dart', 'run', 'build_runner', 'build'],
    for (final dir in ['lib', 'test', 'integration_test'])
      ['dart', 'fix', '--apply', '--code=unused_import', dir],
    ['dart', 'format', 'lib', 'test', 'integration_test'],
  ]) {
    print('\n\$ ${command.join(' ')}');
    final result = await Process.run(
      command.first,
      command.skip(1).toList(),
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      stderr.writeln('Command failed — fix the error above and re-run it.');
      exit(result.exitCode);
    }
  }
  print(
    '\nExample removed. Next: `flutter analyze && flutter test`, then '
    'update the README and CLAUDE.md "Project-Specific Context".',
  );
}

/// Path fragment identifying imports of the example feature.
const exampleImport = '/features/posts/';

/// Removes imports of the example feature and `// example:begin` …
/// `// example:end` blocks (markers included), and un-comments
/// `// example:uncomment <code>` lines.
String stripExampleBlocks(String source) {
  final out = <String>[];
  var skipping = false;
  for (final line in const LineSplitter().convert(source)) {
    final trimmed = line.trim();
    if (trimmed == '// example:begin') {
      skipping = true;
      continue;
    }
    if (trimmed == '// example:end') {
      skipping = false;
      continue;
    }
    if (skipping) continue;
    if (trimmed.startsWith('import ') && trimmed.contains(exampleImport)) {
      continue;
    }
    const uncomment = '// example:uncomment ';
    if (trimmed.startsWith(uncomment)) {
      final indent = line.substring(0, line.indexOf(uncomment));
      out.add('$indent${trimmed.substring(uncomment.length)}');
      continue;
    }
    out.add(line);
  }
  return '${out.join('\n')}\n';
}
