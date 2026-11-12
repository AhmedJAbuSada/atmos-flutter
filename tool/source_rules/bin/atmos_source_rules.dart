import 'dart:io';

import 'package:atmos_source_rules/atmos_source_rules.dart';

/// Checks every Dart file of the repository (ADR-0012).
///
/// usage: dart run atmos_source_rules [repository root, default: the current directory]
///
/// Prints one `file:line:column: error: [rule] message` line per violation and exits with 1
/// if there is any, so CI fails and annotates it.
void main(List<String> arguments) {
  final root = Directory(arguments.isEmpty ? '.' : arguments.first).absolute;
  final files = _dartFiles(root);
  final violations = [
    for (final file in files) ...checkSource(_relative(file, root), file.readAsStringSync()),
  ];
  for (final violation in violations) {
    stdout.writeln(violation);
  }
  if (violations.isEmpty) {
    stdout.writeln('Source rules: ${files.length} files checked, no problems.');
  } else {
    stdout.writeln('Source rules: ${violations.length} problem(s) in ${files.length} files.');
    exitCode = 1;
  }
}

/// Directories that hold no source of ours: build output, tool caches, the native host
/// projects, and this checker (its tests contain the violations it must find).
const _skipped = {'build', 'android', 'ios'};

List<File> _dartFiles(Directory root) {
  final files = <File>[];
  void walk(Directory directory) {
    final entries = directory.listSync()..sort((a, b) => a.path.compareTo(b.path));
    for (final entry in entries) {
      final name = entry.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      if (entry is Directory) {
        final skip =
            name.startsWith('.') ||
            _skipped.contains(name) ||
            _relative(entry, root) == 'tool/source_rules';
        if (!skip) walk(entry);
      } else if (entry is File && name.endsWith('.dart')) {
        files.add(entry);
      }
    }
  }

  walk(root);
  return files;
}

String _relative(FileSystemEntity entity, Directory root) {
  final rootPath = root.uri.normalizePath().path;
  final path = entity.absolute.uri.normalizePath().path;
  final relative = path.startsWith(rootPath) ? path.substring(rootPath.length) : path;
  return relative.endsWith('/') ? relative.substring(0, relative.length - 1) : relative;
}
