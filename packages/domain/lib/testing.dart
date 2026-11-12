/// In-memory fakes of the domain interfaces and ready-made test values, shared by the tests of
/// every package (the Dart equivalent of Gradle test fixtures, the iOS `AtmosTesting` target and
/// React Native's `src/testing`).
///
/// **Tests only.** `tool/source_rules` fails if production code (any `lib/`) imports this
/// library.
library;

import 'atmos_domain.dart';

/// Valid coordinates, or a failing test.
Coordinates coordinates(double latitude, double longitude) =>
    Coordinates.validated(latitude, longitude) ??
    (throw ArgumentError('Invalid test coordinates: $latitude, $longitude'));

final Coordinates istanbul = coordinates(41.01, 28.97);

City city(int id, [String name = 'City']) => City(
  id: id,
  name: name,
  country: 'Türkiye',
  countryCode: 'TR',
  coordinates: coordinates(39.92, 32.85),
);

final class FakeCityRepository implements CityRepository {
  FakeCityRepository({this.searchResult = const Ok([])});

  Result<List<City>> searchResult;
  final List<({String query, String languageCode})> searches = [];
  final _saved = ValueStore<List<City>>(const []);

  @override
  Future<Result<List<City>>> search(String query, String languageCode) async {
    searches.add((query: query, languageCode: languageCode));
    return searchResult;
  }

  @override
  Future<List<City>> savedCities() async => _saved.value;

  @override
  Stream<List<City>> observeSavedCities() => _saved.watch();

  @override
  Future<void> save(City city) async {
    if (!_saved.value.any((it) => it.id == city.id)) _saved.value = [..._saved.value, city];
  }

  @override
  Future<void> remove(int cityId) async {
    _saved.value = [
      for (final city in _saved.value)
        if (city.id != cityId) city,
    ];
  }
}

final class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({Result<Coordinates>? result}) : result = result ?? Ok(istanbul);

  Result<Coordinates> result;

  @override
  Future<Result<Coordinates>> currentLocation() async => result;
}

final class FakeSettingsRepository implements SettingsRepository {
  final store = ValueStore<UserSettings>(UserSettings.defaults);

  @override
  Stream<UserSettings> observeSettings() => store.watch();

  @override
  Future<void> updateSettings({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    AppTheme? theme,
  }) async {
    store.value = store.value.copyWith(
      temperatureUnit: temperatureUnit,
      windSpeedUnit: windSpeedUnit,
      theme: theme,
    );
  }
}
