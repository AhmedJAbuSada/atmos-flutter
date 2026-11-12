import 'mask.dart';

/// Where a Dart file sits in the architecture, decided by its path (ADR-0001).
enum Area { domain, data, presentation, app, other }

/// One broken rule, printed the way compilers print errors, so CI turns it into an
/// annotation (`scripts/annotate-log.py` looks for `error:`).
final class Violation {
  const Violation({
    required this.path,
    required this.line,
    required this.column,
    required this.rule,
    required this.message,
  });

  final String path;
  final int line;
  final int column;
  final String rule;
  final String message;

  @override
  String toString() => '$path:$line:$column: error: [$rule] $message';
}

/// Files allowed to call `toUpperCase()`/`toLowerCase()`. Only the locale-aware casing helper
/// (ADR-0005, step 05) belongs here. Adding a file is a reviewed change, never a quick fix.
const Set<String> casingAllowList = {};

/// The area of the file at [path], a path relative to the repository root with `/`.
Area areaOf(String path) {
  if (path.startsWith('packages/domain/')) return Area.domain;
  if (path.startsWith('packages/data/')) return Area.data;
  if (path.startsWith('packages/presentation/')) return Area.presentation;
  if (path.startsWith('lib/') || path.startsWith('test/') || path.startsWith('integration_test/')) {
    return Area.app;
  }
  return Area.other;
}

/// Whether [path] is production code (a package's `lib/`), as opposed to tests.
bool isLibraryCode(String path) =>
    path.startsWith('lib/') || RegExp(r'^packages/[^/]+/lib/').hasMatch(path);

/// Checks one Dart file. [path] is relative to the repository root, with `/`.
List<Violation> checkSource(String path, String source) {
  final area = areaOf(path);
  final code = maskCommentsAndStrings(source).split('\n');
  final lines = source.split('\n');
  final violations = <Violation>[];

  void report(int index, int column, String rule, String message) {
    violations.add(
      Violation(path: path, line: index + 1, column: column + 1, rule: rule, message: message),
    );
  }

  for (var index = 0; index < lines.length; index++) {
    // Imports are read from the real line, because the URI is a string.
    if (isLibraryCode(path)) {
      final directive = _directive.firstMatch(lines[index]);
      if (directive != null) {
        final uri = directive.group(2) ?? '';
        final problem = _importProblem(area, uri);
        if (problem != null) {
          report(index, directive.start, 'layer-imports', problem);
        }
      }
    }

    // Everything else is read from code only: comments and strings are blanked out.
    final line = code[index];
    if (!casingAllowList.contains(path)) {
      for (final match in _casing.allMatches(line)) {
        report(
          index,
          match.start + 1,
          'locale-casing',
          "Dart's toUpperCase()/toLowerCase() ignore the locale: Turkish 'i' must become "
              "'İ'. Use the locale-aware helper (ADR-0005).",
        );
      }
    }
    if (area == Area.presentation || area == Area.app) {
      for (final pattern in _leftRight) {
        for (final match in pattern.allMatches(line)) {
          final word = match.group(1) ?? match.group(0) ?? '';
          report(
            index,
            match.columnOf(1),
            'start-end',
            "'$word' does not mirror in Arabic. Use start/end: EdgeInsetsDirectional, "
                'AlignmentDirectional, PositionedDirectional, BorderRadiusDirectional, '
                'TextAlign.start (ADR-0005).',
          );
        }
      }
    }
  }
  return violations;
}

final _directive = RegExp(r'''^\s*(import|export)\s+['"]([^'"]+)['"]''');

final _casing = RegExp(r'\.(toUpperCase|toLowerCase)\s*\(');

final _leftRight = [
  // A named argument: EdgeInsets.only(left: 8), Positioned(right: 0), BorderRadius.only(
  // topLeft: …). It follows `(` or `,`, or starts the line in a multi-line call.
  RegExp(r'(?:^|[(,])\s*(left|right|topLeft|topRight|bottomLeft|bottomRight)\s*:(?!:)'),
  RegExp(r'\b(Alignment\.(?:top|center|bottom)(?:Left|Right))\b'),
  RegExp(r'\b(TextAlign\.(?:left|right))\b'),
  RegExp(r'\b(EdgeInsets\.fromLTRB)\b'),
];

extension on RegExpMatch {
  /// The column of group [index], so the error points at the word, not at the `(` before it.
  int columnOf(int index) {
    final text = group(index);
    if (text == null) return start;
    return start + (group(0) ?? '').indexOf(text);
  }
}

const _coreLibraries = {
  'dart:async',
  'dart:collection',
  'dart:convert',
  'dart:core',
  'dart:math',
  'dart:typed_data',
};

const _flutterForData = {'package:flutter/foundation.dart', 'package:flutter/services.dart'};

const _forbiddenInData = [
  'package:atmos/',
  'package:atmos_presentation/',
  'package:material_ui/',
  'package:flutter_riverpod/',
  'package:riverpod/',
  'dart:ui',
];

const _forbiddenInPresentation = [
  'package:atmos/',
  'package:atmos_data/',
  'package:http/',
  'package:shared_preferences/',
  'package:geolocator/',
  'dart:io',
];

/// Why [uri] may not be imported from [area], or `null` when it may.
String? _importProblem(Area area, String uri) {
  // The fakes are for tests only, in every layer (like React Native's src/testing rule).
  if (uri == 'package:atmos_domain/testing.dart' ||
      uri == 'testing.dart' ||
      uri.endsWith('/testing.dart')) {
    return "'$uri' holds test fakes: production code must not import it.";
  }
  final relative = !uri.contains(':');
  switch (area) {
    case Area.domain:
      if (relative || _coreLibraries.contains(uri) || uri.startsWith('package:atmos_domain/')) {
        return null;
      }
      return 'atmos_domain is pure Dart: it may import only core Dart libraries and itself, '
          "not '$uri' (ADR-0001).";
    case Area.data:
      if (uri.startsWith('package:flutter/') && !_flutterForData.contains(uri)) {
        return "atmos_data may use Flutter's foundation and services only, not '$uri': "
            'widgets belong to presentation (ADR-0001).';
      }
      for (final prefix in _forbiddenInData) {
        if (uri.startsWith(prefix)) {
          return "atmos_data must not import '$uri': data knows the domain only "
              '(ADR-0001).';
        }
      }
      return null;
    case Area.presentation:
      for (final prefix in _forbiddenInPresentation) {
        if (uri.startsWith(prefix)) {
          return "atmos_presentation must not import '$uri': it talks to the domain, never "
              'to data sources (ADR-0001).';
        }
      }
      return null;
    case Area.app:
    case Area.other:
      return null;
  }
}
