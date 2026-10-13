// A command-line tool: printing progress is its whole job.
// ignore_for_file: avoid_print

import 'dart:io';

/// Renames the starter to your app: Dart package name, Android application
/// id, iOS bundle id and launcher name.
///
/// ```sh
/// dart run tool/rename.dart --package my_app --org com.acme --app-name "My App"
/// dart run tool/rename.dart ... --dry-run   # list changes only
/// ```
///
/// Results (for the example above):
/// - Dart package: `my_app` (all `package:` imports updated)
/// - Android: `com.acme.my_app` (+ `.dev` / `.stg` suffixes per flavor)
/// - iOS: `com.acme.myApp` (+ `.dev` / `.stg`)
/// - Launcher name: `My App` / `My App Dev` / `My App Stg`
///
/// Run it once, on a clean git tree, right after cloning.
Future<void> main(List<String> args) async {
  String? arg(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final newPackage = arg('package');
  final org = arg('org');
  final appName = arg('app-name');
  final dryRun = args.contains('--dry-run');

  if (newPackage == null || org == null || appName == null) {
    stderr.writeln(
      'Usage: dart run tool/rename.dart --package <snake_case> '
      '--org <reverse.domain> --app-name "<Display Name>" [--dry-run]',
    );
    exit(64);
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(newPackage)) {
    stderr.writeln('--package must be snake_case (e.g. my_app).');
    exit(64);
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(org)) {
    stderr.writeln('--org must be a reverse domain (e.g. com.acme).');
    exit(64);
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run this from the project root.');
    exit(64);
  }

  // Current identifiers, read from the project itself.
  final oldPackage = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync())![1]!;
  final gradle = File('android/app/build.gradle.kts');
  final oldAndroidId = RegExp('applicationId = "([^"]+)"')
      .firstMatch(gradle.readAsStringSync())![1]!;
  final oldIosId =
      RegExp(
        r'PRODUCT_BUNDLE_IDENTIFIER = ([A-Za-z0-9.]+?)(\.dev|\.stg|\.RunnerTests)?;',
      ).firstMatch(
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
      )![1]!;
  const oldAppName = 'Clean Starter';

  final newAndroidId = '$org.$newPackage';
  final newIosId = '$org.${camelCase(newPackage)}';

  print('package   $oldPackage → $newPackage');
  print('android   $oldAndroidId → $newAndroidId');
  print('ios       $oldIosId → $newIosId');
  print('app name  $oldAppName → $appName\n');

  final edits = <String, String Function(String)>{
    'pubspec.yaml': (s) => s.replaceFirst(
      RegExp('^name: $oldPackage', multiLine: true),
      'name: $newPackage',
    ),
    gradle.path: (s) => s
        .replaceAll('"$oldAndroidId"', '"$newAndroidId"')
        .replaceAll('"$oldAppName', '"$appName'),
    'ios/Runner.xcodeproj/project.pbxproj': (s) => s
        .replaceAll('= $oldIosId', '= $newIosId')
        .replaceAll('"$oldAppName', '"$appName'),
    'ios/Runner/Info.plist': (s) => s.replaceAll(
      '<string>$oldPackage</string>',
      '<string>$newPackage</string>',
    ),
    for (final arb in Directory(
      'lib/core/l10n/arb',
    ).listSync().whereType<File>())
      arb.path: (s) =>
          s.replaceAll('"appTitle": "$oldAppName"', '"appTitle": "$appName"'),
    for (final doc in ['README.md', 'CLAUDE.md'])
      doc: (s) => s.replaceAll(oldPackage, newPackage),
    for (final dart in _dartFiles())
      dart.path: (s) =>
          s.replaceAll('package:$oldPackage/', 'package:$newPackage/'),
  };

  for (final MapEntry(key: path, value: edit) in edits.entries) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final before = file.readAsStringSync();
    final after = edit(before);
    if (after == before) continue;
    print('edit    $path');
    if (!dryRun) file.writeAsStringSync(after);
  }

  // Move MainActivity to the new Kotlin package.
  final oldKt = File(
    'android/app/src/main/kotlin/${oldAndroidId.replaceAll('.', '/')}/MainActivity.kt',
  );
  final newKt = File(
    'android/app/src/main/kotlin/${newAndroidId.replaceAll('.', '/')}/MainActivity.kt',
  );
  if (oldKt.existsSync() && oldKt.path != newKt.path) {
    print('move    ${oldKt.path} → ${newKt.path}');
    if (!dryRun) {
      newKt.parent.createSync(recursive: true);
      newKt.writeAsStringSync(
        oldKt.readAsStringSync().replaceFirst(
          'package $oldAndroidId',
          'package $newAndroidId',
        ),
      );
      oldKt.deleteSync();
      _deleteEmptyParents(oldKt.parent, stopAt: 'android/app/src/main/kotlin');
    }
  }

  if (dryRun) {
    print('\n--dry-run: no files were changed.');
    return;
  }
  // Import order depends on the package name: re-sort, then re-format.
  for (final command in [
    ['pub', 'get'],
    ['fix', '--apply', '--code=directives_ordering'],
    ['format', 'lib', 'test', 'integration_test', 'tool'],
  ]) {
    print('\n\$ dart ${command.join(' ')}');
    final result = await Process.run('dart', command, runInShell: true);
    if (result.exitCode != 0) {
      stderr
        ..write(result.stdout)
        ..write(result.stderr)
        ..writeln('Command failed — fix the error above and re-run it.');
      exit(result.exitCode);
    }
  }
  print('\nDone. Now run: dart run build_runner build && flutter analyze');
}

Iterable<File> _dartFiles() => [
  for (final dir in ['lib', 'test', 'integration_test', 'tool'])
    if (Directory(dir).existsSync())
      ...Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
];

void _deleteEmptyParents(Directory dir, {required String stopAt}) {
  var current = dir;
  while (!current.path.replaceAll(r'\', '/').endsWith(stopAt) &&
      current.existsSync() &&
      current.listSync().isEmpty) {
    current.deleteSync();
    current = current.parent;
  }
}

/// `my_app` → `myApp` (iOS bundle ids conventionally avoid underscores).
String camelCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
