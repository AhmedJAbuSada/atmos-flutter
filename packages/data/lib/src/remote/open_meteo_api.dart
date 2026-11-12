import 'dart:convert';

import 'package:atmos_domain/atmos_domain.dart';

import 'dtos.dart';
import 'http_client.dart';

/// The two Open-Meteo endpoints (API_CONTRACT §1, §2): builds the URLs, sends them, parses the
/// JSON. Throws the [HttpClient]'s exceptions, [HttpStatusException] for a non-2xx answer and
/// [FormatException] for a body that is not JSON; the repositories map them (`toDomainError`).
final class OpenMeteoApi {
  const OpenMeteoApi(this._client);

  static const currentFields =
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m';
  static const hourlyFields = 'temperature_2m,weather_code,precipitation_probability';
  static const dailyFields = 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset';

  static final _forecastUrl = Uri.https('api.open-meteo.com', '/v1/forecast');
  static final _geocodingUrl = Uri.https('geocoding-api.open-meteo.com', '/v1/search');

  final HttpClient _client;

  /// The decoded forecast **and the raw text**, which the cache stores as it is.
  Future<({ForecastDto dto, String raw})> forecast(
    Coordinates coordinates, {
    Future<void>? cancel,
  }) async {
    final url = _forecastUrl.replace(
      queryParameters: {
        // Dart's double.toString ignores the phone's language: always "41.01", never "41,01".
        'latitude': '${coordinates.latitude}',
        'longitude': '${coordinates.longitude}',
        'current': currentFields,
        'hourly': hourlyFields,
        'daily': dailyFields,
        'timezone': 'auto',
        'forecast_days': '7',
        'forecast_hours': '24',
      },
    );
    final raw = await _getBody(url, cancel);
    return (dto: ForecastDto.fromJson(jsonDecode(raw)), raw: raw);
  }

  /// Cities matching [name], with names in [languageCode] (F-05).
  Future<List<CityDto>> searchCities(
    String name,
    String languageCode, {
    Future<void>? cancel,
  }) async {
    final url = _geocodingUrl.replace(
      queryParameters: {'name': name, 'count': '10', 'language': languageCode, 'format': 'json'},
    );
    return GeocodingDto.fromJson(jsonDecode(await _getBody(url, cancel))).results;
  }

  Future<String> _getBody(Uri url, Future<void>? cancel) async {
    final response = await _client.get(url, cancel: cancel);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpStatusException(response.statusCode);
    }
    return response.body;
  }
}
