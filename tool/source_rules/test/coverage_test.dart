import 'package:atmos_source_rules/atmos_source_rules.dart';
import 'package:test/test.dart';

void main() {
  test('adds up lines found and hit over every file', () {
    const lcov =
        'SF:/a.dart\nDA:1,1\nLF:10\nLH:9\nend_of_record\nSF:/b.dart\nLF:10\nLH:8\nend_of_record\n';
    expect(lineCoverage(lcov), (found: 20, hit: 17));
    expect(coveragePercent(lineCoverage(lcov)), 85);
  });

  test('an empty or broken report is 0%, so the gate fails', () {
    expect(coveragePercent(lineCoverage('')), 0);
    expect(lineCoverage('LF:x\nLH:\n'), (found: 0, hit: 0));
  });
}
