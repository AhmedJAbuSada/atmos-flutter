import 'json_reading.dart';

/// The Open-Meteo responses **exactly as the JSON looks** (API_CONTRACT §1, §2), with the API's
/// own field names in the comments. DTOs never leave `atmos_data`.
///
/// Every field is nullable: the API is outside our control, and a missing or surprising field
/// must not crash the app. Parsing is written by hand (ADR-0007); the mappers decide what is
/// truly required.
final class ForecastDto {
  const ForecastDto({this.timezone, this.utcOffsetSeconds, this.current, this.hourly, this.daily});

  /// Reads the decoded JSON. Anything that is not an object gives an empty DTO.
  factory ForecastDto.fromJson(Object? json) {
    final map = readObject(json) ?? const {};
    return ForecastDto(
      timezone: readString(map['timezone']),
      utcOffsetSeconds: readInt(map['utc_offset_seconds']),
      current: switch (readObject(map['current'])) {
        final current? => CurrentDto.fromJson(current),
        null => null,
      },
      hourly: switch (readObject(map['hourly'])) {
        final hourly? => HourlyDto.fromJson(hourly),
        null => null,
      },
      daily: switch (readObject(map['daily'])) {
        final daily? => DailyDto.fromJson(daily),
        null => null,
      },
    );
  }

  /// `timezone`, an IANA name such as `Europe/Istanbul`.
  final String? timezone;

  /// `utc_offset_seconds`, the place's offset at the time of the request (ADR-0015).
  final int? utcOffsetSeconds;
  final CurrentDto? current;
  final HourlyDto? hourly;
  final DailyDto? daily;
}

final class CurrentDto {
  const CurrentDto({
    this.time,
    this.temperature2m,
    this.apparentTemperature,
    this.relativeHumidity2m,
    this.windSpeed10m,
    this.weatherCode,
    this.isDay,
  });

  factory CurrentDto.fromJson(Map<String, Object?> json) => CurrentDto(
    time: readString(json['time']),
    temperature2m: readDouble(json['temperature_2m']),
    apparentTemperature: readDouble(json['apparent_temperature']),
    relativeHumidity2m: readInt(json['relative_humidity_2m']),
    windSpeed10m: readDouble(json['wind_speed_10m']),
    weatherCode: readInt(json['weather_code']),
    isDay: readInt(json['is_day']),
  );

  /// `time`: local time at the place, without an offset (`2026-11-11T10:15`).
  final String? time;
  final double? temperature2m;
  final double? apparentTemperature;
  final int? relativeHumidity2m;
  final double? windSpeed10m;
  final int? weatherCode;

  /// `is_day`: `1` or `0`, not a boolean.
  final int? isDay;
}

/// Parallel arrays: index `i` of every list belongs to `time[i]`.
final class HourlyDto {
  const HourlyDto({this.time, this.temperature2m, this.weatherCode, this.precipitationProbability});

  factory HourlyDto.fromJson(Map<String, Object?> json) => HourlyDto(
    time: readList(json['time'], readString),
    temperature2m: readList(json['temperature_2m'], readDouble),
    weatherCode: readList(json['weather_code'], readInt),
    precipitationProbability: readList(json['precipitation_probability'], readInt),
  );

  final List<String?>? time;
  final List<double?>? temperature2m;
  final List<int?>? weatherCode;
  final List<int?>? precipitationProbability;
}

/// Parallel arrays: index `i` of every list belongs to `time[i]`.
final class DailyDto {
  const DailyDto({
    this.time,
    this.weatherCode,
    this.temperature2mMax,
    this.temperature2mMin,
    this.sunrise,
    this.sunset,
  });

  factory DailyDto.fromJson(Map<String, Object?> json) => DailyDto(
    time: readList(json['time'], readString),
    weatherCode: readList(json['weather_code'], readInt),
    temperature2mMax: readList(json['temperature_2m_max'], readDouble),
    temperature2mMin: readList(json['temperature_2m_min'], readDouble),
    sunrise: readList(json['sunrise'], readString),
    sunset: readList(json['sunset'], readString),
  );

  final List<String?>? time;
  final List<int?>? weatherCode;
  final List<double?>? temperature2mMax;
  final List<double?>? temperature2mMin;
  final List<String?>? sunrise;
  final List<String?>? sunset;
}

/// The geocoding search. When nothing matches, the API **omits `results` entirely** instead of
/// sending `[]` (`docs/api/samples/geocoding_empty.json`), so [results] defaults to empty.
final class GeocodingDto {
  const GeocodingDto(this.results);

  factory GeocodingDto.fromJson(Object? json) {
    final list = readList(readObject(json)?['results'], readObject) ?? const [];
    return GeocodingDto([
      for (final item in list)
        if (item != null) CityDto.fromJson(item),
    ]);
  }

  final List<CityDto> results;
}

final class CityDto {
  const CityDto({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.countryCode,
    this.country,
    this.admin1,
  });

  factory CityDto.fromJson(Map<String, Object?> json) => CityDto(
    id: readInt(json['id']),
    name: readString(json['name']),
    latitude: readDouble(json['latitude']),
    longitude: readDouble(json['longitude']),
    countryCode: readString(json['country_code']),
    country: readString(json['country']),
    admin1: readString(json['admin1']),
  );

  final int? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? countryCode;
  final String? country;

  /// `admin1`: the region (province, state). Missing for some small places.
  final String? admin1;
}
