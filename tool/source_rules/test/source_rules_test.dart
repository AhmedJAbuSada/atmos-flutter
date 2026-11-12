import 'package:atmos_source_rules/atmos_source_rules.dart';
import 'package:test/test.dart';

/// The rules each violation names, for short assertions.
List<String> rulesIn(String path, String source) => [
  for (final v in checkSource(path, source)) v.rule,
];

void main() {
  group('layer-imports', () {
    const domain = 'packages/domain/lib/src/x.dart';

    test('given a core library or the domain itself, then the domain may import it', () {
      expect(
        rulesIn(domain, """
import 'dart:async';
import 'dart:math' as math;
import 'package:atmos_domain/atmos_domain.dart';
import '../common/result.dart';
"""),
        isEmpty,
      );
    });

    test('given Flutter, dart:ui or dart:io, then the domain fails', () {
      final violations = checkSource(domain, """
import 'package:flutter/foundation.dart';
import "dart:ui";
import 'dart:io';
export 'package:atmos_data/atmos_data.dart';
""");
      expect([for (final v in violations) v.line], [1, 2, 3, 4]);
      expect(violations.first.toString(), startsWith('$domain:1:1: error: [layer-imports] '));
    });

    test('given widgets or presentation, then data fails; services and foundation are fine', () {
      const data = 'packages/data/lib/src/x.dart';
      expect(
        rulesIn(data, """
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:atmos_domain/atmos_domain.dart';
"""),
        isEmpty,
      );
      expect(
        rulesIn(data, """
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
"""),
        List.filled(4, 'layer-imports'),
      );
    });

    test('given a data source, then presentation fails', () {
      expect(
        rulesIn('packages/presentation/lib/x.dart', """
import 'package:atmos_data/atmos_data.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:atmos/main.dart';
"""),
        List.filled(4, 'layer-imports'),
      );
    });

    test('given the app, then it may import every layer', () {
      expect(
        rulesIn('lib/app/composition.dart', """
import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
"""),
        isEmpty,
      );
    });

    test('given the test fakes, then no production code may import them', () {
      for (final path in ['packages/data/lib/src/x.dart', 'lib/main.dart']) {
        expect(rulesIn(path, "import 'package:atmos_domain/testing.dart';"), ['layer-imports']);
      }
      expect(rulesIn('packages/domain/lib/src/x.dart', "import '../../testing.dart';"), [
        'layer-imports',
      ]);
      expect(rulesIn('packages/domain/lib/x.dart', "import 'testing.dart';"), ['layer-imports']);
      expect(
        rulesIn('packages/data/test/x_test.dart', "import 'package:atmos_domain/testing.dart';"),
        isEmpty,
      );
    });

    test('given a test file, then the import rules do not apply', () {
      expect(
        rulesIn('packages/domain/test/x_test.dart', "import 'package:test/test.dart';"),
        isEmpty,
      );
    });
  });

  group('locale-casing', () {
    test('given toUpperCase or toLowerCase anywhere, then it fails', () {
      final violations = checkSource(
        'packages/domain/lib/x.dart',
        'final a = name.toUpperCase();\nfinal b = name.toLowerCase ();',
      );
      expect([for (final v in violations) v.rule], ['locale-casing', 'locale-casing']);
      expect(violations.first.column, 16);
    });

    test('given a call inside string interpolation, then it still fails', () {
      expect(rulesIn('lib/x.dart', r"final s = 'City: ${name.toUpperCase()}';"), ['locale-casing']);
    });

    test('given the words in a comment or a plain string, then it passes', () {
      expect(
        rulesIn('lib/x.dart', """
// Never call toUpperCase() here.
/* toLowerCase() */
final s = 'toUpperCase()';
final r = r'\${x.toLowerCase()}';
"""),
        isEmpty,
      );
    });
  });

  group('start-end', () {
    const screen = 'packages/presentation/lib/src/home.dart';

    test('given left/right named arguments, then it fails', () {
      expect(
        rulesIn(screen, '''
const a = EdgeInsets.only(left: 8);
const b = Positioned(right: 0, child: x);
final c = BorderRadius.only(
  topLeft: r,
);
'''),
        List.filled(3, 'start-end'),
      );
    });

    test('given Alignment, TextAlign or fromLTRB with a side, then it fails', () {
      expect(
        rulesIn('lib/x.dart', '''
final a = Alignment.centerLeft;
final b = TextAlign.right;
final c = EdgeInsets.fromLTRB(1, 2, 3, 4);
'''),
        List.filled(3, 'start-end'),
      );
    });

    test('given the directional versions, then it passes', () {
      expect(
        rulesIn(screen, '''
const a = EdgeInsetsDirectional.only(start: 8, end: 4);
final b = AlignmentDirectional.centerStart;
final c = TextAlign.start;
final d = Alignment.center;
final e = isRtl ? left : right;
'''),
        isEmpty,
      );
    });

    test('given the domain, then left and right are just words', () {
      expect(rulesIn('packages/domain/lib/x.dart', 'f(left: 1);'), isEmpty);
    });

    test('the error points at the word', () {
      final violation = checkSource(screen, 'const a = EdgeInsets.only(left: 8);').single;
      expect(violation.column, 27);
    });
  });

  group('maskCommentsAndStrings', () {
    test('keeps every line length and line break', () {
      const source = "a('x') // c\n/* d\n e */ b\n'''\nq\n''' z";
      final masked = maskCommentsAndStrings(source);
      expect(masked.split('\n').map((l) => l.length), source.split('\n').map((l) => l.length));
      expect(masked, "a(' ')     \n    \n      b\n'''\n \n''' z");
    });
  });
}
