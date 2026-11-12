import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_platform.dart';

/// The injection points of the presentation layer (ADR-0004). Each one is a domain interface;
/// the app's composition root overrides them with the real implementations from `atmos_data`,
/// and tests override them with fakes. Without an override, a provider fails at once with a
/// message that names it, so a missing wire is found on the first run.
Never _notProvided(String name) =>
    throw UnimplementedError('$name is not provided: override it in the root ProviderScope.');

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => _notProvided('weatherRepositoryProvider'),
);
final cityRepositoryProvider = Provider<CityRepository>(
  (ref) => _notProvided('cityRepositoryProvider'),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => _notProvided('settingsRepositoryProvider'),
);
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => _notProvided('locationRepositoryProvider'),
);
final dateProviderProvider = Provider<DateProvider>((ref) => _notProvided('dateProviderProvider'));
final appPlatformProvider = Provider<AppPlatform>((ref) => _notProvided('appPlatformProvider'));

/// The use cases, built from the repositories: no override needed.
final forecastFreshnessProvider = Provider(
  (ref) => ForecastFreshness(ref.watch(dateProviderProvider)),
);
final getForecastProvider = Provider(
  (ref) => GetForecast(
    repository: ref.watch(weatherRepositoryProvider),
    freshness: ref.watch(forecastFreshnessProvider),
  ),
);
final getCurrentLocationForecastProvider = Provider(
  (ref) => GetCurrentLocationForecast(
    locations: ref.watch(locationRepositoryProvider),
    getForecast: ref.watch(getForecastProvider),
  ),
);
final getCachedForecastProvider = Provider(
  (ref) => GetCachedForecast(ref.watch(weatherRepositoryProvider)),
);
final searchCitiesProvider = Provider((ref) => SearchCities(ref.watch(cityRepositoryProvider)));
final saveCityProvider = Provider((ref) => SaveCity(ref.watch(cityRepositoryProvider)));
final removeCityProvider = Provider((ref) => RemoveCity(ref.watch(cityRepositoryProvider)));
final observePlacesProvider = Provider((ref) => ObservePlaces(ref.watch(cityRepositoryProvider)));

/// Which place Home shows. Cities writes it, Home follows it: a small piece of shared UI state,
/// in memory on purpose (the app always opens on the current location).
final selectedPlaceProvider = Provider<ValueStore<Place>>((ref) {
  final store = ValueStore<Place>(const CurrentLocation());
  ref.onDispose(store.close);
  return store;
});
