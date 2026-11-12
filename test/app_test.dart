import 'package:atmos/app/composition.dart';
import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

void main() {
  group('the OS owns the language (ADR-0005)', () {
    TextDirection direction(WidgetTester tester) =>
        Directionality.of(tester.element(find.byType(Scaffold)));

    Future<void> startWith(WidgetTester tester, List<Locale> phone) async {
      final app = AppHarness()..location.result = const Err(LocationPermissionDenied());
      await app.start(tester, phone: phone);
    }

    testWidgets('an English phone gets English, left to right', (tester) async {
      await startWith(tester, const [Locale('en', 'GB')]);
      expect(find.text('Where are you?'), findsOneWidget);
      expect(direction(tester), TextDirection.ltr);
    });

    testWidgets('an Arabic (Egypt) phone gets Arabic, right to left', (tester) async {
      await startWith(tester, const [Locale('ar', 'EG')]);
      expect(find.text('أين أنت؟'), findsOneWidget);
      expect(direction(tester), TextDirection.rtl);
    });

    testWidgets('the first supported language in the phone list wins', (tester) async {
      await startWith(tester, const [Locale('de'), Locale('tr', 'TR'), Locale('en')]);
      expect(find.text('Neredesiniz?'), findsOneWidget);
    });

    testWidgets('a language the app does not ship falls back to English', (tester) async {
      await startWith(tester, const [Locale('de', 'DE')]);
      expect(find.text('Where are you?'), findsOneWidget);
    });
  });

  group('the composition root', () {
    test('sends a User-Agent with the app version and no personal data', () {
      expect(AppDependencies.userAgent, matches(RegExp(r'^Atmos/1\.0\.0 \(Flutter; \w+\)$')));
    });

    test('its overrides give the presentation layer the real data layer', () async {
      final dependencies = AppDependencies(
        store: InMemoryKeyValueStore(),
        location: _DeniedLocation(),
        platform: FakeAppPlatform(),
      );
      final container = ProviderContainer.test(overrides: dependencies.overrides);
      expect(
        await container.read(getCurrentLocationForecastProvider).call(),
        const Err<ForecastSnapshot>(LocationPermissionDenied()),
      );
      expect(container.read(cityRepositoryProvider), same(dependencies.data.cityRepository));
    });

    test('a provider without an override says which one is missing', () {
      final container = ProviderContainer.test();
      expect(
        () => container.read(weatherRepositoryProvider),
        throwsA(
          predicate((Object? e) => '$e'.contains('weatherRepositoryProvider is not provided')),
        ),
      );
    });
  });
}

final class _DeniedLocation implements LocationPlatform {
  @override
  Future<LocationPermissionStatus> checkPermission() async => LocationPermissionStatus.denied;

  @override
  Future<({double latitude, double longitude})> currentPosition() =>
      throw StateError('must not be asked for a position');
}
