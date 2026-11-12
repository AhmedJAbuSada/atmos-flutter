import 'package:atmos/app/atmos_app.dart';
import 'package:atmos/app/composition.dart';
import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('the OS owns the language (ADR-0005)', () {
    Future<void> startWith(WidgetTester tester, List<Locale> phone) async {
      tester.platformDispatcher.localesTestValue = phone;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(const AtmosApp());
      await tester.pump();
    }

    TextDirection direction(WidgetTester tester) =>
        Directionality.of(tester.element(find.byType(Scaffold)));

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

    test('wires the data layer to the inputs it is given', () async {
      final dependencies = AppDependencies(
        store: InMemoryKeyValueStore(),
        location: _DeniedLocation(),
      );
      expect(
        await dependencies.data.locationRepository.currentLocation(),
        const Err<Coordinates>(LocationPermissionDenied()),
      );
      expect(await dependencies.data.cityRepository.savedCities(), isEmpty);
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
