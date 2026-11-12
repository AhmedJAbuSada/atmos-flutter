import 'dart:math' as math;

import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final (x, y) = (luminance(a), luminance(b));
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  test('the contrast formula gives the known extremes', () {
    expect(contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(contrast(const Color(0xFF777777), const Color(0xFF777777)), 1);
  });

  for (final (name, colors) in [('light', AtmosColors.light), ('dark', AtmosColors.dark)]) {
    group('$name theme meets WCAG AA (4.5 : 1, NF-03)', () {
      final pairs = {
        'text on background': (colors.text, colors.background),
        'text on surface': (colors.text, colors.surface),
        'secondary text on background': (colors.secondaryText, colors.background),
        'secondary text on surface': (colors.secondaryText, colors.surface),
        'accent on background': (colors.accent, colors.background),
        'accent on surface': (colors.accent, colors.surface),
        'on-accent on accent': (colors.onAccent, colors.accent),
        'warning text on warning': (colors.warningText, colors.warningBackground),
      };
      for (final MapEntry(key: pair, value: (foreground, background)) in pairs.entries) {
        test(pair, () => expect(contrast(foreground, background), greaterThanOrEqualTo(4.5)));
      }
    });
  }

  test('the user choice wins; "system" follows the phone', () {
    expect(themeModeFor(AppTheme.system), ThemeMode.system);
    expect(themeModeFor(AppTheme.light), ThemeMode.light);
    expect(themeModeFor(AppTheme.dark), ThemeMode.dark);
  });

  test('the theme carries the tokens', () {
    expect(atmosTheme(AtmosColors.dark).extension<AtmosColors>(), AtmosColors.dark);
    expect(atmosTheme(AtmosColors.dark).brightness, Brightness.dark);
  });
}
