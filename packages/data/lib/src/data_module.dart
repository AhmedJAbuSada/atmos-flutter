import 'package:atmos_domain/atmos_domain.dart';
import 'package:http/http.dart' as http;

import 'local/key_value_store.dart';
import 'location/location_repository.dart';
import 'remote/http_client.dart';
import 'remote/open_meteo_api.dart';
import 'repositories/city_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/weather_repository.dart';

/// The data layer's front door. It hands out **domain interfaces only**: nothing outside
/// `atmos_data` can name a DTO or a concrete repository.
final class DataModule {
  DataModule._(
    this.weatherRepository,
    this.cityRepository,
    this.settingsRepository,
    this.locationRepository,
  );

  /// Builds the data layer. [httpClient] defaults to `package:http` with the 15 s timeout and
  /// the retries of API_CONTRACT §4; tests pass a client that replays the recorded samples.
  /// [userAgent] is the app name and version, with no personal data.
  factory DataModule.create({
    required KeyValueStore store,
    required LocationPlatform location,
    required DateProvider dates,
    HttpClient? httpClient,
    String userAgent = 'Atmos/1.0 (Flutter)',
  }) {
    final client =
        httpClient ?? RetryingHttpClient(PackageHttpClient(http.Client(), userAgent: userAgent));
    final api = OpenMeteoApi(client);
    return DataModule._(
      WeatherRepositoryImpl(api, store, dates),
      CityRepositoryImpl(api, store),
      SettingsRepositoryImpl(store),
      LocationRepositoryImpl(location),
    );
  }

  final WeatherRepository weatherRepository;
  final CityRepository cityRepository;
  final SettingsRepository settingsRepository;
  final LocationRepository locationRepository;
}
