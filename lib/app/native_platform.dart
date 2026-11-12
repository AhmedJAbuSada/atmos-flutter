import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter/services.dart';

/// The real phone calls (ADR-0017). Only glue: the decisions (when to ask, what to show) are
/// in the view models, tested with fakes; the end-to-end tests of step 07 run this on a device.
final class NativeAppPlatform implements AppPlatform {
  const NativeAppPlatform({this.permissions = const GeolocatorPermissions()});

  /// A small channel of our own to the Android and iOS code in `MainActivity.kt` and
  /// `AppDelegate.swift`: opening a link and the app's language page need no library.
  static const _system = MethodChannel('dev.ahmedabusada.atmos/system');

  final GeolocatorPermissions permissions;

  @override
  Future<PermissionAnswer> requestLocationPermission() async =>
      switch (await permissions.request()) {
        LocationPermissionAnswer.granted => PermissionAnswer.granted,
        LocationPermissionAnswer.denied => PermissionAnswer.denied,
        LocationPermissionAnswer.blocked => PermissionAnswer.blocked,
      };

  @override
  Future<void> openAppSettings() => permissions.openAppSettings();

  @override
  Future<void> openLanguageSettings() => _call('openLanguageSettings');

  @override
  Future<void> openUrl(Uri url) => _call('openUrl', '$url');

  /// A failed call (no browser, an old OS) changes nothing on screen: there is nothing the user
  /// could do about it.
  Future<void> _call(String method, [String? argument]) async {
    try {
      await _system.invokeMethod<bool>(method, argument);
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
