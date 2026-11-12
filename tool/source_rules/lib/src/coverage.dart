/// Line coverage from an lcov report (the format `dart test --coverage-path` and
/// `flutter test --coverage` write), with no dependency (ADR-0014).
///
/// Adds up the `LF` (lines found) and `LH` (lines hit) records of every file.
({int found, int hit}) lineCoverage(String lcov) {
  var found = 0;
  var hit = 0;
  for (final line in lcov.split('\n')) {
    if (line.startsWith('LF:')) found += int.tryParse(line.substring(3).trim()) ?? 0;
    if (line.startsWith('LH:')) hit += int.tryParse(line.substring(3).trim()) ?? 0;
  }
  return (found: found, hit: hit);
}

/// The percentage of lines hit; an empty report is 0%, so a broken setup fails the gate.
double coveragePercent(({int found, int hit}) coverage) =>
    coverage.found == 0 ? 0 : 100 * coverage.hit / coverage.found;
