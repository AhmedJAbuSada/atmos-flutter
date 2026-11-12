import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:test/test.dart';

const minute = Duration(minutes: 1);

void main() {
  group('WeatherCondition', () {
    const table = {
      0: WeatherCondition.clear,
      1: WeatherCondition.mainlyClear,
      2: WeatherCondition.partlyCloudy,
      3: WeatherCondition.overcast,
      45: WeatherCondition.fog,
      48: WeatherCondition.fog,
      51: WeatherCondition.drizzle,
      53: WeatherCondition.drizzle,
      55: WeatherCondition.drizzle,
      56: WeatherCondition.freezingDrizzle,
      57: WeatherCondition.freezingDrizzle,
      61: WeatherCondition.rain,
      63: WeatherCondition.rain,
      65: WeatherCondition.rain,
      66: WeatherCondition.freezingRain,
      67: WeatherCondition.freezingRain,
      71: WeatherCondition.snow,
      73: WeatherCondition.snow,
      75: WeatherCondition.snow,
      77: WeatherCondition.snow,
      80: WeatherCondition.rainShowers,
      81: WeatherCondition.rainShowers,
      82: WeatherCondition.rainShowers,
      85: WeatherCondition.snowShowers,
      86: WeatherCondition.snowShowers,
      95: WeatherCondition.thunderstorm,
      96: WeatherCondition.thunderstormWithHail,
      99: WeatherCondition.thunderstormWithHail,
    };
    for (final MapEntry(key: code, value: condition) in table.entries) {
      test('WMO code $code is ${condition.name}', () {
        expect(WeatherCondition.fromWmoCode(code), condition);
      });
    }

    for (final code in [4, -1, null]) {
      test('an unknown or missing code ($code) is "unknown", never a crash', () {
        expect(WeatherCondition.fromWmoCode(code), WeatherCondition.unknown);
      });
    }
  });

  group('ForecastFreshness', () {
    final freshness = ForecastFreshness(FixedDateProvider());

    test('data fetched 29 minutes ago is fresh', () {
      expect(freshness.isFresh(forecast(fetchedAt: testNow.subtract(minute * 29))), isTrue);
    });

    test('data fetched exactly 30 minutes ago is stale', () {
      expect(freshness.isFresh(forecast(fetchedAt: testNow.subtract(minute * 30))), isFalse);
    });

    test('age is measured from the fetch time', () {
      expect(freshness.age(forecast(fetchedAt: testNow.subtract(minute * 120))), minute * 120);
    });
  });

  /// One test per row of the table in GetForecast's documentation.
  group('GetForecast', () {
    final fresh = forecast(fetchedAt: testNow.subtract(minute * 5));
    final stale = forecast(fetchedAt: testNow.subtract(minute * 120));
    final downloaded = forecast(fetchedAt: testNow);

    GetForecast setUp(FakeWeatherRepository repository) =>
        GetForecast(repository: repository, freshness: ForecastFreshness(FixedDateProvider()));

    test('given fresh cache, when loading, then returns it without a download', () async {
      final repository = FakeWeatherRepository(cached: fresh);
      expect(await setUp(repository)(istanbul), Ok(ForecastSnapshot(fresh)));
      expect(repository.fetchCount, 0);
    });

    test('given fresh cache, when pulling to refresh, then downloads anyway', () async {
      final repository = FakeWeatherRepository(cached: fresh, fetchResult: Ok(downloaded));
      expect(
        await setUp(repository)(istanbul, forceRefresh: true),
        Ok(ForecastSnapshot(downloaded)),
      );
      expect(repository.fetchCount, 1);
    });

    for (final (label, cached) in [('stale', stale), ('no', null)]) {
      test('given $label cache, when loading, then downloads', () async {
        final repository = FakeWeatherRepository(cached: cached, fetchResult: Ok(downloaded));
        expect(await setUp(repository)(istanbul), Ok(ForecastSnapshot(downloaded)));
        expect(repository.fetchCount, 1);
      });
    }

    test('given stale cache and no connection, then returns the cache marked outdated', () async {
      final repository = FakeWeatherRepository(
        cached: stale,
        fetchResult: const Err(NoConnection()),
      );
      expect(
        await setUp(repository)(istanbul),
        Ok(ForecastSnapshot(stale, refreshError: const NoConnection())),
      );
    });

    test(
      'given fresh cache, a failed pull to refresh keeps the cache, marked with the error',
      () async {
        final repository = FakeWeatherRepository(
          cached: fresh,
          fetchResult: const Err(ServerError(503)),
        );
        expect(
          await setUp(repository)(istanbul, forceRefresh: true),
          Ok(ForecastSnapshot(fresh, refreshError: const ServerError(503))),
        );
      },
    );

    test('given no cache and no connection, then returns the error', () async {
      final repository = FakeWeatherRepository(fetchResult: const Err(NoConnection()));
      expect(await setUp(repository)(istanbul), const Err<ForecastSnapshot>(NoConnection()));
    });

    test('a cancelled download is never hidden behind old data', () async {
      final repository = FakeWeatherRepository(cached: stale, fetchResult: const Err(Cancelled()));
      expect(await setUp(repository)(istanbul), const Err<ForecastSnapshot>(Cancelled()));
    });

    test('the cached forecast is read without a download', () async {
      final repository = FakeWeatherRepository(cached: stale);
      expect(await GetCachedForecast(repository)(istanbul), stale);
      expect(repository.fetchCount, 0);
    });
  });

  group('GetCurrentLocationForecast', () {
    GetForecast getForecast(FakeWeatherRepository weather) =>
        GetForecast(repository: weather, freshness: ForecastFreshness(FixedDateProvider()));

    test('given a location, then returns its forecast', () async {
      final useCase = GetCurrentLocationForecast(
        locations: FakeLocationRepository(),
        getForecast: getForecast(FakeWeatherRepository()),
      );
      expect(await useCase(), Ok(ForecastSnapshot(forecast())));
    });

    test('given permission is denied, then returns that error without fetching weather', () async {
      final weather = FakeWeatherRepository();
      final useCase = GetCurrentLocationForecast(
        locations: FakeLocationRepository(result: const Err(LocationPermissionDenied())),
        getForecast: getForecast(weather),
      );
      expect(await useCase(), const Err<ForecastSnapshot>(LocationPermissionDenied()));
      expect(weather.fetchCount, 0);
    });
  });

  group('Forecast equality', () {
    test('two forecasts with the same values are equal; any difference is not', () {
      expect(forecast(), forecast());
      expect(forecast().hashCode, forecast().hashCode);
      expect(forecast(), isNot(forecast(fetchedAt: testNow.add(minute))));
      final hour = HourlyForecast(
        time: testNow,
        temperature: const Temperature(15),
        condition: WeatherCondition.rain,
        precipitationChancePercent: 20,
      );
      final day = DailyForecast(
        date: testNow,
        condition: WeatherCondition.rain,
        minTemperature: const Temperature(11),
        maxTemperature: const Temperature(17),
        sunrise: testNow,
      );
      final withHour = forecast().withLists(hourly: [hour], daily: [day]);
      expect(withHour, forecast().withLists(hourly: [hour], daily: [day]));
      expect(withHour, isNot(forecast()));
    });
  });
}

extension on Forecast {
  Forecast withLists({required List<HourlyForecast> hourly, required List<DailyForecast> daily}) =>
      Forecast(
        // `this.` is needed: in an extension, the top-level `coordinates()` from testing.dart
        // would win over the implicit `this.coordinates`.
        coordinates: this.coordinates,
        timeZone: timeZone,
        utcOffset: utcOffset,
        current: current,
        hourly: hourly,
        daily: daily,
        fetchedAt: fetchedAt,
      );
}
