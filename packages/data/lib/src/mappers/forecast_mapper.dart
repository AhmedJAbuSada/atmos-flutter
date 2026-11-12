import 'package:atmos_domain/atmos_domain.dart';

import '../remote/dtos.dart';
import '../remote/error_mapping.dart';
import 'local_time.dart';

/// DTO → domain.
///
/// Keeps the **requested** coordinates (the API snaps them to its grid, and the cache key must
/// match what we asked for). Throws [InvalidResponseException] only when the current conditions
/// are missing; a broken hour or day is skipped instead of failing the whole screen.
Forecast mapForecast(ForecastDto dto, Coordinates requested, DateTime fetchedAt) {
  final offset = Duration(seconds: dto.utcOffsetSeconds ?? 0);
  final current = switch (dto.current) {
    final current? => _mapCurrent(current, offset),
    null => null,
  };
  if (current == null) throw const InvalidResponseException('missing current conditions');
  final timeZone = dto.timezone?.trim() ?? '';
  return Forecast(
    coordinates: requested,
    timeZone: timeZone.isEmpty ? 'UTC' : timeZone,
    utcOffset: offset,
    current: current,
    hourly: switch (dto.hourly) {
      final hourly? => _mapHourly(hourly, offset),
      null => const [],
    },
    daily: switch (dto.daily) {
      final daily? => _mapDaily(daily, offset),
      null => const [],
    },
    fetchedAt: fetchedAt,
  );
}

CurrentWeather? _mapCurrent(CurrentDto dto, Duration offset) {
  final time = parseLocalTime(dto.time, offset);
  final (temperature, wind) = (dto.temperature2m, dto.windSpeed10m);
  if (time == null || temperature == null || wind == null) return null;
  return CurrentWeather(
    time: time,
    temperature: Temperature(temperature),
    feelsLike: Temperature(dto.apparentTemperature ?? temperature),
    humidityPercent: dto.relativeHumidity2m ?? 0,
    windSpeed: WindSpeed(wind),
    condition: WeatherCondition.fromWmoCode(dto.weatherCode),
    isDay: dto.isDay != 0,
  );
}

/// The item at [index], or `null` when the list is missing or shorter (parallel arrays of
/// different lengths must not crash: API_CONTRACT §1).
T? _at<T>(List<T?>? list, int index) => list != null && index < list.length ? list[index] : null;

/// Zips the parallel arrays. An index missing from any required array is dropped.
List<HourlyForecast> _mapHourly(HourlyDto dto, Duration offset) => [
  for (final (i, text) in (dto.time ?? const <String?>[]).indexed)
    if ((parseLocalTime(text, offset), _at(dto.temperature2m, i), _at(dto.weatherCode, i)) case (
      final time?,
      final temperature?,
      final code?,
    ))
      HourlyForecast(
        time: time,
        temperature: Temperature(temperature),
        condition: WeatherCondition.fromWmoCode(code),
        precipitationChancePercent: _at(dto.precipitationProbability, i),
      ),
];

List<DailyForecast> _mapDaily(DailyDto dto, Duration offset) => [
  for (final (i, text) in (dto.time ?? const <String?>[]).indexed)
    if ((
          parseLocalTime(text, offset),
          _at(dto.temperature2mMin, i),
          _at(dto.temperature2mMax, i),
          _at(dto.weatherCode, i),
        )
        case (final date?, final min?, final max?, final code?))
      DailyForecast(
        date: date,
        condition: WeatherCondition.fromWmoCode(code),
        minTemperature: Temperature(min),
        maxTemperature: Temperature(max),
        sunrise: parseLocalTime(_at(dto.sunrise, i), offset),
        sunset: parseLocalTime(_at(dto.sunset, i), offset),
      ),
];
