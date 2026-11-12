import 'package:atmos_domain/atmos_domain.dart';

/// The permission states this repository cares about.
enum LocationPermissionStatus { granted, denied, unavailable }

/// The two platform calls, injected so the logic is tested without a phone. The real ones are
/// in `GeolocatorLocationPlatform` (ADR-0009).
abstract interface class LocationPlatform {
  /// Reads the permission **without** showing a prompt.
  Future<LocationPermissionStatus> checkPermission();

  /// The current position. Throws when there is no fix in time or the location is off.
  Future<({double latitude, double longitude})> currentPosition();
}

/// Only **checks** the permission. Asking for it is a UI decision (US-01: the app explains why
/// first), so it happens in the presentation layer, not here.
final class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._platform);

  final LocationPlatform _platform;

  @override
  Future<Result<Coordinates>> currentLocation() async {
    try {
      switch (await _platform.checkPermission()) {
        case LocationPermissionStatus.denied:
          return const Err(LocationPermissionDenied());
        case LocationPermissionStatus.unavailable:
          return const Err(LocationUnavailable());
        case LocationPermissionStatus.granted:
          final position = await _platform.currentPosition();
          final coordinates = Coordinates.validated(position.latitude, position.longitude);
          return coordinates == null ? const Err(LocationUnavailable()) : Ok(coordinates);
      }
    } on Exception {
      return const Err(LocationUnavailable()); // a timeout, location switched off, no fix
    }
  }
}
