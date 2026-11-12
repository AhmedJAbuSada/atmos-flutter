import 'dart:convert';

import 'package:atmos_data/src/mappers/city_mapper.dart';
import 'package:atmos_data/src/mappers/forecast_mapper.dart';
import 'package:atmos_data/src/remote/dtos.dart';
import 'package:atmos_data/src/remote/error_mapping.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/samples.dart';

/// A local time in Istanbul (UTC+3 all year) as a UTC instant.
DateTime inIstanbul(int day, int hour, [int minute = 0]) =>
    DateTime.utc(2026, 11, day, hour, minute).subtract(const Duration(hours: 3));

void main() {
  group('mapForecast', () {
    Forecast recorded() => mapForecast(
      ForecastDto.fromJson(jsonDecode(sample('forecast_istanbul.json'))),
      istanbul,
      testNow,
    );

    test('maps the current conditions of the recorded Istanbul response', () {
      final forecast = recorded();
      expect(
        forecast.current,
        CurrentWeather(
          time: inIstanbul(11, 10, 15),
          temperature: const Temperature(14.9),
          feelsLike: const Temperature(11.2),
          humidityPercent: 69,
          windSpeed: const WindSpeed(24.8),
          condition: WeatherCondition.overcast,
          isDay: true,
        ),
      );
      expect(forecast.timeZone, 'Europe/Istanbul');
      expect(forecast.utcOffset, const Duration(hours: 3));
      expect(forecast.fetchedAt, testNow);
    });

    test('zips the parallel hourly arrays into 24 hours', () {
      final hourly = recorded().hourly;
      expect(hourly, hasLength(24));
      expect(
        hourly.first,
        HourlyForecast(
          time: inIstanbul(11, 10),
          temperature: const Temperature(14.8),
          condition: WeatherCondition.partlyCloudy,
          precipitationChancePercent: 0,
        ),
      );
    });

    test('maps 7 days with sunrise and sunset', () {
      final daily = recorded().daily;
      expect(daily, hasLength(7));
      expect(
        daily.first,
        DailyForecast(
          date: inIstanbul(11, 0),
          condition: WeatherCondition.overcast,
          minTemperature: const Temperature(11.4),
          maxTemperature: const Temperature(16.9),
          sunrise: inIstanbul(11, 7, 46),
          sunset: inIstanbul(11, 17, 49),
        ),
      );
    });

    test('keeps the requested coordinates, not the snapped ones from the response', () {
      expect(recorded().coordinates, istanbul); // the response says 41.02444, 28.940546
    });

    test('given no current conditions, then the response is invalid', () {
      expect(
        () => mapForecast(const ForecastDto(), istanbul, testNow),
        throwsA(isA<InvalidResponseException>()),
      );
    });

    test(
      'given arrays of different lengths, then maps only complete hours instead of crashing',
      () {
        final dto = ForecastDto.fromJson({
          'timezone': 'UTC',
          'current': {'time': '2026-11-11T10:15', 'temperature_2m': 15, 'wind_speed_10m': 10},
          'hourly': {
            'time': ['2026-11-11T10:00', '2026-11-11T11:00', '2026-11-11T12:00'],
            'temperature_2m': [14.8, null],
            'weather_code': [2],
          },
        });
        final forecast = mapForecast(dto, istanbul, testNow);
        expect(forecast.hourly, hasLength(1));
        expect(forecast.hourly.single.precipitationChancePercent, isNull);
        expect(forecast.current.feelsLike, const Temperature(15)); // falls back to the temperature
        expect(forecast.current.humidityPercent, 0);
        expect(forecast.daily, isEmpty);
      },
    );

    test('given values of the wrong type, then they count as missing, never a crash', () {
      final dto = ForecastDto.fromJson({
        'utc_offset_seconds': '10800',
        'current': {'time': '2026-11-11T10:15', 'temperature_2m': '15', 'wind_speed_10m': 10},
      });
      expect(() => mapForecast(dto, istanbul, testNow), throwsA(isA<InvalidResponseException>()));
      expect(ForecastDto.fromJson('not an object').current, isNull);
      expect(ForecastDto.fromJson([1, 2]).hourly, isNull);
    });

    test('a missing zone falls back to UTC with no offset', () {
      final forecast = mapForecast(
        ForecastDto.fromJson({
          'current': {
            'time': '2026-11-11T10:15',
            'temperature_2m': 15,
            'wind_speed_10m': 10,
            'is_day': 0,
          },
        }),
        istanbul,
        testNow,
      );
      expect(forecast.timeZone, 'UTC');
      expect(forecast.utcOffset, Duration.zero);
      expect(forecast.current.time, DateTime.utc(2026, 11, 11, 10, 15));
      expect(forecast.current.isDay, isFalse);
      expect(forecast.current.condition, WeatherCondition.unknown);
    });
  });

  group('mapCities', () {
    List<City> cities(String name) =>
        mapCities(GeocodingDto.fromJson(jsonDecode(sample(name))).results);

    test('maps the recorded Turkish search with Turkish names', () {
      final first = cities('geocoding_istanbul_tr.json').first;
      expect(first.id, 745044);
      expect(first.name, 'İstanbul');
      expect(first.region, 'İstanbul');
      expect(first.country, 'Türkiye Cumhuriyeti');
      expect(first.countryCode, 'TR');
    });

    test('maps the recorded Arabic search with Arabic names', () {
      expect(cities('geocoding_istanbul_ar.json').first.name, 'اسطنبول');
    });

    test('the same city has the same id in every language', () {
      final ids = {
        for (final language in ['en', 'tr', 'ar'])
          cities('geocoding_istanbul_$language.json').first.id,
      };
      expect(ids, {745044});
    });

    test('a response with no results key is an empty list', () {
      // The real API omits "results" when nothing matches.
      expect(cities('geocoding_empty.json'), isEmpty);
    });

    test('drops results that cannot be shown or saved', () {
      const base = CityDto(
        id: 1,
        name: 'Ankara',
        latitude: 39.9,
        longitude: 32.8,
        country: ' ',
        admin1: '',
      );
      expect(mapCity(base)?.name, 'Ankara');
      expect(mapCity(base)?.country, isNull); // a blank country is dropped
      expect(mapCity(base)?.region, isNull);
      CityDto without({bool id = false, bool name = false, bool latitude = false}) => CityDto(
        id: id ? null : 1,
        name: name ? ' ' : 'Ankara',
        latitude: latitude ? 999 : 39.9,
        longitude: 32.8,
      );
      expect(mapCity(without(id: true)), isNull);
      expect(mapCity(without(name: true)), isNull);
      expect(mapCity(without(latitude: true)), isNull);
    });
  });
}
