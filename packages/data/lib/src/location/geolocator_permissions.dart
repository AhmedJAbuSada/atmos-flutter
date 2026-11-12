import 'package:geolocator/geolocator.dart';

/// What the system permission dialog answered. [blocked]: the system will not show the dialog
/// again, so only the app's settings page can turn the permission on.
enum LocationPermissionAnswer { granted, denied, blocked }

/// Shows the system location dialog and opens the app's settings page, with geolocator
/// (ADR-0009).
///
/// A separate class from `GeolocatorLocationPlatform` on purpose: the location repository only
/// receives the platform that **checks**, so it cannot ask, by construction. Asking is a UI
/// decision, made after the explanation (US-01); the app hands this class to the presentation
/// layer through its own interface. Thin glue: it needs a device, so it is not unit-tested.
final class GeolocatorPermissions {
  const GeolocatorPermissions();

  Future<LocationPermissionAnswer> request() async =>
      switch (await Geolocator.requestPermission()) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationPermissionAnswer.granted,
        LocationPermission.deniedForever => LocationPermissionAnswer.blocked,
        LocationPermission.denied ||
        LocationPermission.unableToDetermine => LocationPermissionAnswer.denied,
      };

  /// The app's page in the system settings. `false` when it could not be opened.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
