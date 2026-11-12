import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:test/test.dart';

/// Entities are values: two with the same fields are equal and have the same hash code, so
/// they work in sets, as map keys and in `expect`. One test per type, with equal pairs built
/// separately (not the same instance).
void main() {
  void expectValue(Object Function() make, Object different) {
    final a = make();
    final b = make();
    expect(identical(a, b), isFalse, reason: 'build two instances');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect({a, b}, hasLength(1));
    expect(a, isNot(different));
  }

  test('errors', () {
    expectValue(() => ServerError(int.parse('503')), const ServerError(500));
    expectValue(NotFound.new, const LocationUnavailable());
    expectValue(UnknownError.new, const Cancelled());
  });

  test('results', () {
    expectValue(() => Ok(city(1)), Ok(city(2)));
    expectValue(() => Err<City>(ServerError(int.parse('400'))), const Err<City>(NoConnection()));
  });

  test('cities and places', () {
    expectValue(() => city(1, 'Ankara'), city(1, 'Renamed'));
    expectValue(() => SavedPlace(city(1)), const CurrentLocation());
    expectValue(CurrentLocation.new, SavedPlace(city(1)));
  });

  test('settings', () {
    expectValue(() => UserSettings.defaults.copyWith(theme: AppTheme.dark), UserSettings.defaults);
  });

  test('forecast parts and snapshots', () {
    expectValue(
      () => HourlyForecast(
        time: testNow,
        temperature: const Temperature(15),
        condition: WeatherCondition.rain,
      ),
      HourlyForecast(
        time: testNow,
        temperature: const Temperature(16),
        condition: WeatherCondition.rain,
      ),
    );
    expectValue(
      () => DailyForecast(
        date: testNow,
        condition: WeatherCondition.snow,
        minTemperature: const Temperature(-2),
        maxTemperature: const Temperature(1),
      ),
      DailyForecast(
        date: testNow,
        condition: WeatherCondition.snow,
        minTemperature: const Temperature(-3),
        maxTemperature: const Temperature(1),
      ),
    );
    expectValue(
      () => ForecastSnapshot(forecast(), refreshError: const NoConnection()),
      ForecastSnapshot(forecast()),
    );
  });

  test('failure messages name the values', () {
    expect('${const Ok(1)}', 'Ok(1)');
    expect('${const Err<int>(ServerError(503))}', 'Err(ServerError(503))');
    expect('${const Err<int>(NoConnection())}', 'Err(NoConnection)');
    expect('$istanbul', 'Coordinates(41.01, 28.97)');
    expect('${city(7, 'Rize')}', 'City(7, Rize)');
    expect('${UserSettings.defaults}', contains('TemperatureUnit.celsius'));
    expect('${ForecastSnapshot(forecast())}', contains('2026-11-11 07:15'));
  });

  test('a temperature and a wind speed are distinct types around a double', () {
    const wind = WindSpeed(10);
    expect(wind.kilometersPerHour, 10);
    expect(const Temperature(10).celsius, 10);
  });
}
