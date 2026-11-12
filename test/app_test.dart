import 'package:atmos/app/atmos_app.dart';
import 'package:atmos/app/composition.dart';
import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app starts on the placeholder screen', (tester) async {
    await tester.pumpWidget(const AtmosApp());

    expect(find.text('Atmos'), findsOneWidget);
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
