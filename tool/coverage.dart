// A command-line tool: printing the report is its whole job.
// ignore_for_file: avoid_print

import 'dart:io';

/// Summarizes `coverage/lcov.info` (run `flutter test --coverage` first).
///
/// ```sh
/// dart run tool/coverage.dart                # report
/// dart run tool/coverage.dart --min 80       # fail below 80 % (CI)
/// ```
///
/// Generated files are excluded. The gate (`--min`) applies to the
/// `domain` + `data` layers of every feature — the project's coverage
/// target (see docs/testing.md).
void main(List<String> args) {
  final minIndex = args.indexOf('--min');
  final min = minIndex >= 0 ? double.parse(args[minIndex + 1]) : null;

  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found: run `flutter test --coverage`.',
    );
    exit(66);
  }

  final records = parseLcov(file.readAsLinesSync())
      .where((r) => !isGenerated(r.path))
      .toList();

  final groups = <String, Coverage>{};
  for (final r in records) {
    groups.update(
      groupOf(r.path),
      (c) => c + r.coverage,
      ifAbsent: () => r.coverage,
    );
  }

  final total = records.fold(const Coverage(0, 0), (c, r) => c + r.coverage);
  final gate = records
      .where(
        (r) => RegExp('lib/features/[^/]+/(domain|data)/').hasMatch(r.path),
      )
      .fold(const Coverage(0, 0), (c, r) => c + r.coverage);

  print('Coverage by area');
  for (final key in groups.keys.toList()..sort()) {
    print('  ${key.padRight(40)} ${groups[key]}');
  }
  print('  ${'TOTAL'.padRight(40)} $total');
  print('  ${'features domain + data (gate)'.padRight(40)} $gate');

  if (min != null && gate.percent < min) {
    stderr.writeln(
      'Coverage gate failed: ${gate.percent.toStringAsFixed(1)} % < $min %',
    );
    exit(1);
  }
}

/// Lines found / hit for one file or group.
class Coverage {
  /// Creates a coverage count.
  const Coverage(this.found, this.hit);

  /// Instrumented lines.
  final int found;

  /// Lines executed by tests.
  final int hit;

  /// Hit ratio in percent (100 when nothing is instrumented).
  double get percent => found == 0 ? 100 : hit * 100 / found;

  /// Sums two counts.
  Coverage operator +(Coverage other) =>
      Coverage(found + other.found, hit + other.hit);

  @override
  String toString() =>
      '${percent.toStringAsFixed(1).padLeft(5)} %  ($hit/$found)';
}

/// One `SF:` record of an lcov file.
class LcovRecord {
  /// Creates a record.
  const LcovRecord(this.path, this.coverage);

  /// Source path, with forward slashes.
  final String path;

  /// Its coverage.
  final Coverage coverage;
}

/// Parses lcov [lines] into one record per source file.
List<LcovRecord> parseLcov(List<String> lines) {
  final records = <LcovRecord>[];
  String? path;
  var found = 0;
  var hit = 0;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      path = line.substring(3).replaceAll(r'\', '/');
      found = 0;
      hit = 0;
    } else if (line.startsWith('DA:')) {
      found++;
      if (!line.endsWith(',0')) hit++;
    } else if (line == 'end_of_record' && path != null) {
      records.add(LcovRecord(path, Coverage(found, hit)));
      path = null;
    }
  }
  return records;
}

/// Whether [path] is generated code that should not count.
bool isGenerated(String path) =>
    const [
      '.g.dart',
      '.freezed.dart',
      '.config.dart',
      '.gen.dart',
    ].any(path.endsWith) ||
    path.contains('/l10n/gen/');

/// Groups `lib/features/<f>/<layer>/...` by feature and layer, everything
/// else by its top-level folder under `lib/`.
String groupOf(String path) {
  final match = RegExp('lib/features/([^/]+)/([^/]+)/').firstMatch(path);
  if (match != null) return 'features/${match[1]}/${match[2]}';
  final top = RegExp('lib/([^/]+)/').firstMatch(path);
  return top == null ? 'lib' : top[1]!;
}
