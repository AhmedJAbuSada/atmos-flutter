import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:test/test.dart';

void main() {
  group('units', () {
    for (final (celsius, fahrenheit) in [(0.0, 32.0), (100.0, 212.0), (-40.0, -40.0)]) {
      test('$celsius °C is $fahrenheit °F', () {
        expect(Temperature(celsius).inUnit(TemperatureUnit.fahrenheit), closeTo(fahrenheit, 1e-9));
      });
    }

    test('celsius is returned unchanged', () {
      expect(const Temperature(14.9).inUnit(TemperatureUnit.celsius), 14.9);
    });

    test('wind speed converts to every unit', () {
      const wind = WindSpeed(36);
      expect(wind.inUnit(WindSpeedUnit.kilometersPerHour), 36);
      expect(wind.inUnit(WindSpeedUnit.metersPerSecond), closeTo(10, 1e-9));
      expect(wind.inUnit(WindSpeedUnit.milesPerHour), closeTo(22.369, 1e-3));
    });
  });

  group('settings', () {
    test('first run uses metric units and follows the system theme', () {
      const settings = UserSettings.defaults;
      expect(settings.temperatureUnit, TemperatureUnit.celsius);
      expect(settings.windSpeedUnit, WindSpeedUnit.kilometersPerHour);
      expect(settings.theme, AppTheme.system);
    });

    test('copyWith changes only the given fields', () {
      final dark = UserSettings.defaults.copyWith(theme: AppTheme.dark);
      expect(dark.theme, AppTheme.dark);
      expect(dark.temperatureUnit, TemperatureUnit.celsius);
      expect(dark, isNot(UserSettings.defaults));
    });

    test('observers receive every change', () async {
      final repository = FakeSettingsRepository();
      final seen = <TemperatureUnit>[];
      repository.observeSettings().listen((settings) => seen.add(settings.temperatureUnit));
      await pumpEventQueue();

      await repository.updateSettings(temperatureUnit: TemperatureUnit.fahrenheit);
      await pumpEventQueue();

      expect(seen, [TemperatureUnit.celsius, TemperatureUnit.fahrenheit]);
    });
  });
}
