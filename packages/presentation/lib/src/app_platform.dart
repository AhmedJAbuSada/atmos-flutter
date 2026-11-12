/// What the system permission dialog answered. [blocked]: it will not ask again.
enum PermissionAnswer { granted, denied, blocked }

/// The phone calls the screens need, behind one interface: the app implements it, tests fake
/// it. Each call is a UI decision (when to ask, which page to open), so it belongs to the
/// presentation layer, never to the data layer.
abstract interface class AppPlatform {
  /// Shows the system location dialog. Only after the explanation is on screen (US-01).
  Future<PermissionAnswer> requestLocationPermission();

  /// The app's page in the system settings, where a blocked permission can be turned on.
  Future<void> openAppSettings();

  /// The system page where the app language is changed: the OS owns it (ADR-0005).
  Future<void> openLanguageSettings();

  /// Opens a web page in the browser (About, F-11).
  Future<void> openUrl(Uri url);
}
