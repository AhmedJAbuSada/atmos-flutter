import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/pump.dart';

void main() {
  const shown = <DomainError>[
    NoConnection(),
    RequestTimeout(),
    ServerError(503),
    NotFound(),
    LocationPermissionDenied(),
    LocationUnavailable(),
    UnknownError(),
  ];

  for (final language in languages) {
    test('[$language] every error but Cancelled has its own message', () async {
      final l10n = await l10nFor(language);
      final messages = [for (final error in shown) errorMessage(error, l10n)];
      expect(messages, everyElement(isNotEmpty));
      expect(messages.toSet(), hasLength(shown.length));
      expect(errorMessage(const Cancelled(), l10n), isNull);
    });

    test('[$language] every condition has its own label', () async {
      final l10n = await l10nFor(language);
      final labels = {for (final c in WeatherCondition.values) conditionLabel(c, l10n)};
      expect(labels, hasLength(WeatherCondition.values.length));
    });
  }

  test('a clear night shows a moon, not a sun (US-01)', () {
    expect(conditionIcon(WeatherCondition.clear), '☀️');
    expect(conditionIcon(WeatherCondition.clear, isDay: false), '🌙');
    expect(conditionIcon(WeatherCondition.mainlyClear, isDay: false), '🌙');
    expect(conditionIcon(WeatherCondition.rain, isDay: false), '🌧️');
    expect({for (final c in WeatherCondition.values) conditionIcon(c)}, isNot(contains('')));
  });
}
