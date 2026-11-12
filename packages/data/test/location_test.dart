import 'package:atmos_data/src/location/location_repository.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class FakePlatform implements LocationPlatform {
  FakePlatform(
    this.permission, [
    Future<({double latitude, double longitude})> Function()? position,
  ]) : _position = position ?? (() async => (latitude: 41.01, longitude: 28.97));

  final LocationPermissionStatus permission;
  final Future<({double latitude, double longitude})> Function() _position;
  int positionRequests = 0;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permission;

  @override
  Future<({double latitude, double longitude})> currentPosition() {
    positionRequests++;
    return _position();
  }
}

void main() {
  group('LocationRepository', () {
    test('given permission, then returns the position', () async {
      final repository = LocationRepositoryImpl(FakePlatform(LocationPermissionStatus.granted));
      expect(await repository.currentLocation(), Ok(istanbul));
    });

    test('given no permission, then fails without asking for the position', () async {
      final platform = FakePlatform(LocationPermissionStatus.denied);
      expect(
        await LocationRepositoryImpl(platform).currentLocation(),
        const Err<Coordinates>(LocationPermissionDenied()),
      );
      expect(platform.positionRequests, 0);
    });

    test('given a device without location, then fails with LocationUnavailable', () async {
      expect(
        await LocationRepositoryImpl(FakePlatform(LocationPermissionStatus.unavailable))
            .currentLocation(),
        const Err<Coordinates>(LocationUnavailable()),
      );
    });

    test('given no fix in time, then fails with LocationUnavailable', () async {
      final platform = FakePlatform(
        LocationPermissionStatus.granted,
        () async => throw Exception('Location request timed out'),
      );
      expect(
        await LocationRepositoryImpl(platform).currentLocation(),
        const Err<Coordinates>(LocationUnavailable()),
      );
    });

    test(
      'given impossible coordinates from the platform, then fails instead of using them',
      () async {
        final platform = FakePlatform(
          LocationPermissionStatus.granted,
          () async => (latitude: 999.0, longitude: 0.0),
        );
        expect(
          await LocationRepositoryImpl(platform).currentLocation(),
          const Err<Coordinates>(LocationUnavailable()),
        );
      },
    );
  });
}
