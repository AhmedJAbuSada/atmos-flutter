import '../common/list_equality.dart';
import '../common/result.dart';
import '../location/coordinates.dart';
import '../settings/units.dart';
import 'weather_condition.dart';

/// The full forecast for one place (F-01, F-03, F-04).
///
/// Every time is a UTC instant. [timeZone] is the place's IANA name (`Europe/Istanbul`), for
/// display; [utcOffset] is how far the place's clocks were ahead of UTC when the forecast was
/// made, so the UI shows Istanbul time even on a phone set to London (ADR-0015). [fetchedAt]
/// drives freshness (F-07) and "Updated 2 hours ago" (F-08).
final class Forecast {
  const Forecast({
    required this.coordinates,
    required this.timeZone,
    required this.utcOffset,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  final Coordinates coordinates;
  final String timeZone;
  final Duration utcOffset;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  @override
  bool operator ==(Object other) =>
      other is Forecast &&
      other.coordinates == coordinates &&
      other.timeZone == timeZone &&
      other.utcOffset == utcOffset &&
      other.current == current &&
      listEquals(other.hourly, hourly) &&
      listEquals(other.daily, daily) &&
      other.fetchedAt == fetchedAt;

  @override
  int get hashCode => Object.hash(
    coordinates,
    timeZone,
    utcOffset,
    current,
    Object.hashAll(hourly),
    Object.hashAll(daily),
    fetchedAt,
  );
}

/// The conditions right now (F-01).
final class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidityPercent,
    required this.windSpeed,
    required this.condition,
    required this.isDay,
  });

  final DateTime time;
  final Temperature temperature;
  final Temperature feelsLike;
  final int humidityPercent;
  final WindSpeed windSpeed;
  final WeatherCondition condition;

  /// Night shows a moon, not a sun, for a clear sky (US-01).
  final bool isDay;

  @override
  bool operator ==(Object other) =>
      other is CurrentWeather &&
      other.time == time &&
      other.temperature == temperature &&
      other.feelsLike == feelsLike &&
      other.humidityPercent == humidityPercent &&
      other.windSpeed == windSpeed &&
      other.condition == condition &&
      other.isDay == isDay;

  @override
  int get hashCode =>
      Object.hash(time, temperature, feelsLike, humidityPercent, windSpeed, condition, isDay);
}

/// One hour of the next 24 (F-03).
final class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    this.precipitationChancePercent,
  });

  final DateTime time;
  final Temperature temperature;
  final WeatherCondition condition;

  /// `null` when the API has no value; the UI hides 0% too (US-02).
  final int? precipitationChancePercent;

  @override
  bool operator ==(Object other) =>
      other is HourlyForecast &&
      other.time == time &&
      other.temperature == temperature &&
      other.condition == condition &&
      other.precipitationChancePercent == precipitationChancePercent;

  @override
  int get hashCode => Object.hash(time, temperature, condition, precipitationChancePercent);
}

/// One day of the next 7 (F-04).
final class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.minTemperature,
    required this.maxTemperature,
    this.sunrise,
    this.sunset,
  });

  /// The start of the day at the place.
  final DateTime date;
  final WeatherCondition condition;
  final Temperature minTemperature;
  final Temperature maxTemperature;

  /// `null` when unknown, or on days without one (polar day and night).
  final DateTime? sunrise;
  final DateTime? sunset;

  @override
  bool operator ==(Object other) =>
      other is DailyForecast &&
      other.date == date &&
      other.condition == condition &&
      other.minTemperature == minTemperature &&
      other.maxTemperature == maxTemperature &&
      other.sunrise == sunrise &&
      other.sunset == sunset;

  @override
  int get hashCode => Object.hash(date, condition, minTemperature, maxTemperature, sunrise, sunset);
}

/// Source of forecasts. The repository only stores and downloads; *when* to download is a
/// business rule, in `GetForecast`.
abstract interface class WeatherRepository {
  /// The last saved forecast for [coordinates], or `null`.
  Future<Forecast?> cachedForecast(Coordinates coordinates);

  /// Downloads a new forecast and saves it to the cache.
  Future<Result<Forecast>> fetchForecast(Coordinates coordinates);
}
