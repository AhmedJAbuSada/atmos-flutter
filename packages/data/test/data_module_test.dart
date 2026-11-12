import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'location_test.dart' show FakePlatform;
import 'support/samples.dart';

void main() {
  test('the repositories work end to end with a domain use case', () async {
    final dates = FixedDateProvider();
    final data = DataModule.create(
      store: InMemoryKeyValueStore(),
      location: FakePlatform(LocationPermissionStatus.granted),
      dates: dates,
      httpClient: ReplayingClient([ok(sample('forecast_istanbul.json'))]),
    );
    final getForecast = GetForecast(
      repository: data.weatherRepository,
      freshness: ForecastFreshness(dates),
    );

    final downloaded = await getForecast(istanbul);
    // Fresh, so no second download: the replaying client has no second reply to give.
    final fromCache = await getForecast(istanbul);

    expect(switch (downloaded) {
      Ok(:final value) => value.forecast.current.temperature,
      Err() => null,
    }, const Temperature(14.9));
    expect(fromCache, downloaded);
    expect(await data.locationRepository.currentLocation(), Ok(istanbul));
    expect(await data.cityRepository.savedCities(), isEmpty);
    expect(await data.settingsRepository.observeSettings().first, UserSettings.defaults);
  });
}
