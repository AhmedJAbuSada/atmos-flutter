import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart' show Locale;

const istanbul = Duration(hours: 3);

/// 07:46 in Istanbul (sunrise in the recorded sample).
final sunrise = DateTime.utc(2026, 11, 11, 4, 46);

String plain(String text) => text.replaceAll(RegExp('[\u2066-\u2069]'), '');

void main() {
  setUpAll(initializeDateFormatting);

  test('every value is wrapped in directional isolates (the Android °11 bug)', () {
    final value = WeatherFormatter('ar')
        .temperature(const Temperature(11), TemperatureUnit.celsius);
    expect(value, '\u206611°\u2069');
  });

  group('temperature', () {
    test('whole degrees in either unit', () {
      final format = WeatherFormatter('en');
      expect(plain(format.temperature(const Temperature(14.9), TemperatureUnit.celsius)), '15°');
      expect(plain(format.temperature(const Temperature(14.9), TemperatureUnit.fahrenheit)), '59°');
    });

    test('-0.4 is 0°, never -0°', () {
      expect(
        plain(WeatherFormatter('en').temperature(const Temperature(-0.4), TemperatureUnit.celsius)),
        '0°',
      );
    });
  });

  group('wind speed', () {
    test('km/h and mph are whole, m/s keeps one decimal', () {
      final format = WeatherFormatter('en');
      const wind = WindSpeed(24.8);
      expect(plain(format.windSpeed(wind, WindSpeedUnit.kilometersPerHour)), '25 km/h');
      expect(plain(format.windSpeed(wind, WindSpeedUnit.metersPerSecond)), '6.9 m/s');
      expect(plain(format.windSpeed(wind, WindSpeedUnit.milesPerHour)), '15 mph');
    });

    test('Turkish writes a decimal comma: 6,9 m/s', () {
      expect(
        plain(
          WeatherFormatter('tr').windSpeed(const WindSpeed(24.8), WindSpeedUnit.metersPerSecond),
        ),
        '6,9 m/s',
      );
    });
  });

  group('percentage', () {
    test('69% in English, %69 in Turkish', () {
      expect(plain(WeatherFormatter('en').percentage(69)), '69%');
      expect(plain(WeatherFormatter('tr').percentage(69)), '%69');
    });
  });

  group('time at the place', () {
    test('7:46 AM in English, 07:46 in Turkish, 7:46 ص in Arabic', () {
      String at(String language) =>
          plain(WeatherFormatter(language, utcOffset: istanbul).time(sunrise));
      // CLDR puts a narrow no-break space (U+202F) before "AM": it never wraps onto its own line.
      expect(at('en'), '7:46\u202FAM');
      expect(at('tr'), '07:46');
      expect(at('ar'), '7:46 ص');
    });

    test('is the time in Istanbul, whatever the phone says', () {
      expect(plain(WeatherFormatter('tr').time(sunrise)), '04:46'); // without the place's offset
    });

    test('day names are in the language, at the place', () {
      expect(WeatherFormatter('en', utcOffset: istanbul).dayName(sunrise), 'Wednesday');
      expect(WeatherFormatter('tr', utcOffset: istanbul).dayName(sunrise), 'Çarşamba');
      expect(WeatherFormatter('ar', utcOffset: istanbul).dayName(sunrise), 'الأربعاء');
      // 22:30 UTC on the 10th is already the 11th in Istanbul.
      final lateEvening = DateTime.utc(2026, 11, 10, 22, 30);
      expect(WeatherFormatter('en', utcOffset: istanbul).sameDay(lateEvening, sunrise), isTrue);
      expect(WeatherFormatter('en').sameDay(lateEvening, sunrise), isFalse);
    });
  });

  test('Arabic uses Latin digits everywhere (product decision, ADR-0005)', () {
    final format = WeatherFormatter('ar', utcOffset: istanbul);
    final texts = [
      format.temperature(const Temperature(14.9), TemperatureUnit.celsius),
      format.windSpeed(const WindSpeed(24.8), WindSpeedUnit.metersPerSecond),
      format.percentage(69),
      format.time(sunrise),
    ];
    for (final text in texts) {
      expect(text, isNot(matches(RegExp('[٠-٩۰-۹]'))), reason: text);
      expect(text, matches(RegExp('[0-9]')), reason: text);
    }
  });

  group('updatedAgo', () {
    test('minutes under an hour, hours under a day, then days', () {
      expect(updatedAgo(const Duration(minutes: 59)), (unit: UpdatedAgoUnit.minutes, count: 59));
      expect(updatedAgo(const Duration(minutes: 125)), (unit: UpdatedAgoUnit.hours, count: 2));
      expect(updatedAgo(const Duration(hours: 49)), (unit: UpdatedAgoUnit.days, count: 2));
    });

    test('a clock that went backwards is 0 minutes, not a negative age', () {
      expect(updatedAgo(const Duration(minutes: -5)), (unit: UpdatedAgoUnit.minutes, count: 0));
    });
  });

  test('Arabic picks the right plural form', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(l10n.homeUpdatedHours(2), 'تم التحديث قبل ساعتين');
    expect(l10n.homeUpdatedHours(3), 'تم التحديث قبل 3 ساعات');
    expect(l10n.homeUpdatedHours(11), 'تم التحديث قبل 11 ساعة');
  });
}
