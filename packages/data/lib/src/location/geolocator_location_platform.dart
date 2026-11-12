import 'package:geolocator/geolocator.dart';

import 'location_repository.dart';

/// The real platform calls, with geolocator (ADR-0009). Coarse accuracy is enough for weather
/// and asks the user for less (NF-06).
///
/// Thin glue, not unit-tested: it needs a device. The logic around it is in
/// [LocationRepositoryImpl], tested with a fake; the journey tests (step 07) cover this class.
final class GeolocatorLocationPlatform implements LocationPlatform {
  const GeolocatorLocationPlatform();

  static const timeLimit = Duration(seconds: 15);

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationPermissionStatus.unavailable;
    return switch (await Geolocator.checkPermission()) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionStatus.granted,
      LocationPermission.denied ||
      LocationPermission.deniedForever => LocationPermissionStatus.denied,
      LocationPermission.unableToDetermine => LocationPermissionStatus.unavailable,
    };
  }

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: timeLimit,
      ),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }
}
