import 'dart:convert';

import 'package:atmos_domain/atmos_domain.dart';

import '../local/cache_key.dart';
import '../local/key_value_store.dart';
import '../mappers/forecast_mapper.dart';
import '../remote/dtos.dart';
import '../remote/error_mapping.dart';
import '../remote/json_reading.dart';
import '../remote/open_meteo_api.dart';

/// Downloads forecasts and keeps the last one per place.
///
/// The cache stores the response **as received**, plus the fetch time. It is mapped again on
/// every read, so a fix in the mapper also fixes old data (the same choice as the other apps).
final class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl(this._api, this._store, this._dates);

  final OpenMeteoApi _api;
  final KeyValueStore _store;
  final DateProvider _dates;

  @override
  Future<Forecast?> cachedForecast(Coordinates coordinates) async {
    final entry = readObject(await readJson(_store, cacheKey(coordinates)));
    final raw = readString(entry?['raw']);
    final fetchedAt = readInt(entry?['fetchedAt']);
    if (raw == null || fetchedAt == null) return null;
    try {
      return mapForecast(
        ForecastDto.fromJson(jsonDecode(raw)),
        coordinates,
        DateTime.fromMillisecondsSinceEpoch(fetchedAt, isUtc: true),
      );
    } on Exception {
      return null; // an unreadable cache is "no cache", never a crash
    }
  }

  @override
  Future<Result<Forecast>> fetchForecast(Coordinates coordinates) async {
    try {
      final (:dto, :raw) = await _api.forecast(coordinates);
      final fetchedAt = _dates.now();
      final forecast = mapForecast(dto, coordinates, fetchedAt);
      await _store.setString(
        cacheKey(coordinates),
        jsonEncode({'raw': raw, 'fetchedAt': fetchedAt.millisecondsSinceEpoch}),
      );
      return Ok(forecast);
    } on Exception catch (error) {
      return Err(toDomainError(error));
    }
  }
}
