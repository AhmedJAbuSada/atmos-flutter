import 'dart:io' show Platform;

import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'native_platform.dart';

/// The app's version, sent in the User-Agent and shown on About. Kept in step with `version:`
/// in pubspec.yaml.
const appVersion = '1.0.0';

/// The composition root (ADR-0004): the one place that creates the real implementations from
/// `atmos_data` and hands them to the presentation layer, as overrides for the root
/// `ProviderScope`. Every input has a real default; tests pass in-memory or fake ones instead.
final class AppDependencies {
  AppDependencies({
    KeyValueStore? store,
    LocationPlatform? location,
    this.dates = const SystemDateProvider(),
    HttpClient? httpClient,
    this.platform = const NativeAppPlatform(),
  }) : data = DataModule.create(
         store: store ?? SharedPreferencesStore(),
         location: location ?? const GeolocatorLocationPlatform(),
         dates: dates,
         httpClient: httpClient,
         userAgent: userAgent,
       );

  /// API_CONTRACT §4: the app and its version, the toolkit and the OS; no personal data.
  static final String userAgent = 'Atmos/$appVersion (Flutter; ${Platform.operatingSystem})';

  final DateProvider dates;
  final DataModule data;
  final AppPlatform platform;

  /// The whole object graph, for `ProviderScope(overrides: …)`.
  List<Override> get overrides => [
    weatherRepositoryProvider.overrideWithValue(data.weatherRepository),
    cityRepositoryProvider.overrideWithValue(data.cityRepository),
    settingsRepositoryProvider.overrideWithValue(data.settingsRepository),
    locationRepositoryProvider.overrideWithValue(data.locationRepository),
    dateProviderProvider.overrideWithValue(dates),
    appPlatformProvider.overrideWithValue(platform),
  ];
}
