import 'dart:io';

import 'package:atmos_source_rules/atmos_source_rules.dart';

/// Fails when an lcov report covers fewer lines than the minimum (ADR-0014).
///
/// usage: `dart run atmos_source_rules:coverage_gate LCOV_FILE MINIMUM_PERCENT LABEL`
void main(List<String> arguments) {
  if (arguments.length != 3) {
    stderr.writeln('usage: coverage_gate <lcov file> <minimum percent> <label>');
    exitCode = 64;
    return;
  }
  final [path, minimumText, label] = arguments;
  final file = File(path);
  final minimum = double.tryParse(minimumText);
  if (!file.existsSync() || minimum == null) {
    stdout.writeln('$path:1:1: error: [coverage] $label: no lcov report, or a bad minimum.');
    exitCode = 1;
    return;
  }
  final coverage = lineCoverage(file.readAsStringSync());
  final percent = coveragePercent(coverage);
  final summary =
      '$label: ${percent.toStringAsFixed(1)}% of lines '
      '(${coverage.hit}/${coverage.found}), minimum $minimumText%.';
  if (percent < minimum) {
    stdout.writeln('$path:1:1: error: [coverage] $summary');
    exitCode = 1;
  } else {
    stdout.writeln('Coverage: $summary');
  }
}
