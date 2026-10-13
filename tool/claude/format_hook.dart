import 'dart:convert';
import 'dart:io';

/// Claude Code `PostToolUse` hook: formats the Dart file that was just
/// edited or written (see `.claude/settings.json`).
///
/// Reads the hook payload (JSON) from stdin and runs `dart format` on
/// `tool_input.file_path` when it is a hand-written `.dart` file. Generated
/// files are skipped. Never fails the tool call: formatting problems are
/// reported on stderr and the hook exits 0.
Future<void> main() async {
  final String path;
  try {
    final payload = jsonDecode(
      await stdin.transform(utf8.decoder).join(),
    ) as Map<String, dynamic>;
    final input = payload['tool_input'] as Map<String, dynamic>? ?? const {};
    path = (input['file_path'] ?? input['path'] ?? '') as String;
  } on Object catch (e) {
    stderr.writeln('format_hook: unreadable payload ($e)');
    return;
  }

  if (!shouldFormat(path) || !File(path).existsSync()) return;

  final result = await Process.run('dart', ['format', path], runInShell: true);
  if (result.exitCode != 0) {
    stderr
      ..writeln('format_hook: dart format failed for $path')
      ..write(result.stderr);
  }
}

/// Whether [path] is a hand-written Dart file that should be formatted.
bool shouldFormat(String path) {
  if (!path.endsWith('.dart')) return false;
  const generated = ['.g.dart', '.freezed.dart', '.config.dart', '.gen.dart'];
  if (generated.any(path.endsWith)) return false;
  final normalized = path.replaceAll(r'\', '/');
  // Mason templates contain {{mustache}} and are not valid Dart.
  return !normalized.contains('/__brick__/') &&
      !normalized.contains('/l10n/gen/');
}
