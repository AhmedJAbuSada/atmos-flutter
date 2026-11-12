import 'dart:convert';

import 'package:atmos_domain/atmos_domain.dart';

import '../local/key_value_store.dart';
import '../local/stored_city.dart';
import '../mappers/city_mapper.dart';
import '../remote/error_mapping.dart';
import '../remote/open_meteo_api.dart';

/// Search is remote; the saved list is local, loaded once and kept in a [ValueStore].
final class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._api, this._store);

  static const savedCitiesKey = 'savedCities';

  final OpenMeteoApi _api;
  final KeyValueStore _store;
  final _saved = ValueStore<List<City>>(const []);
  Future<void>? _loading;

  Future<void> _load() => _loading ??= () async {
    _saved.value = citiesFromJson(await readJson(_store, savedCitiesKey));
  }();

  Future<void> _write(List<City> cities) async {
    _saved.value = cities;
    await _store.setString(
      savedCitiesKey,
      jsonEncode([for (final city in cities) cityToJson(city)]),
    );
  }

  @override
  Future<Result<List<City>>> search(String query, String languageCode) async {
    try {
      return Ok(mapCities(await _api.searchCities(query, languageCode)));
    } on Exception catch (error) {
      return Err(toDomainError(error));
    }
  }

  @override
  Future<List<City>> savedCities() async {
    await _load();
    return _saved.value;
  }

  @override
  Stream<List<City>> observeSavedCities() async* {
    await _load();
    yield* _saved.watch();
  }

  @override
  Future<void> save(City city) async {
    await _load();
    if (_saved.value.any((saved) => saved.id == city.id)) return;
    await _write([..._saved.value, city]);
  }

  @override
  Future<void> remove(int cityId) async {
    await _load();
    await _write([
      for (final city in _saved.value)
        if (city.id != cityId) city,
    ]);
  }
}
