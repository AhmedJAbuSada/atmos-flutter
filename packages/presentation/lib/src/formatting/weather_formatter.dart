import 'package:atmos_domain/atmos_domain.dart';
import 'package:intl/intl.dart';

const _leftToRightIsolate = '\u2066';
const _popDirectionalIsolate = '\u2069';

/// Keeps [value] left to right and in one piece, whatever text surrounds it (Unicode UAX #9).
/// Without it an Arabic sentence can turn `11°` into `°11`: the bug the Android screenshots
/// found (ADR-0005).
String isolate(String value) => '$_leftToRightIsolate$value$_popDirectionalIsolate';

/// Turns domain values into text for one language, at one place.
///
/// Why not `'$value°'`? Because the language changes more than the words: Turkish writes `%69`
/// and `6,9 m/s`, and its times as `07:46`. Unit symbols (km/h, m/s, mph) are international and
/// are not translated.
///
/// [languageCode] is only `en`, `tr` or `ar`, never the phone's full locale: `intl`'s `ar` number
/// data uses Latin digits, as the product asks, while `ar_EG` would write `٦٩`. Dates are told
/// not to use native digits, whoever loaded the date data. Tests guard both.
///
/// Times are shown **at the place**: the instant plus the forecast's [utcOffset] (ADR-0015), so
/// Istanbul's sunrise is right on a phone set to London.
final class WeatherFormatter {
  WeatherFormatter(String languageCode, {this.utcOffset = Duration.zero})
    : _whole = NumberFormat.decimalPattern(languageCode)..maximumFractionDigits = 0,
      _oneDecimal = NumberFormat.decimalPattern(languageCode)
        ..maximumFractionDigits = 1
        ..minimumFractionDigits = 1,
      _percent = NumberFormat.percentPattern(languageCode),
      // Latin digits in times too. intl's own `ar` data already uses them, but in the app
      // Flutter's Material localizations load their own date data, where `ar` writes ٧:٢٩. The
      // Arabic screenshots found it (step 07); a test now loads that data first.
      _time = DateFormat.jm(languageCode)..useNativeDigits = false,
      _weekday = DateFormat.EEEE(languageCode)..useNativeDigits = false;

  final Duration utcOffset;
  final NumberFormat _whole;
  final NumberFormat _oneDecimal;
  final NumberFormat _percent;
  final DateFormat _time;
  final DateFormat _weekday;

  /// Rounds first, so -0.4 shows as 0°, never -0°.
  String _integer(double value) => _whole.format(value.round());

  /// `15°`: whole degrees; decimals add noise to a weather glance.
  String temperature(Temperature value, TemperatureUnit unit) =>
      isolate('${_integer(value.inUnit(unit))}°');

  /// `25 km/h`, `6,9 m/s` in Turkish, `15 mph`. Metres per second keep one decimal.
  String windSpeed(WindSpeed value, WindSpeedUnit unit) {
    final number = value.inUnit(unit);
    return isolate(switch (unit) {
      WindSpeedUnit.kilometersPerHour => '${_integer(number)} km/h',
      WindSpeedUnit.metersPerSecond => '${_oneDecimal.format(number)} m/s',
      WindSpeedUnit.milesPerHour => '${_integer(number)} mph',
    });
  }

  /// `69%`, `%69` in Turkish.
  String percentage(int value) => isolate(_percent.format(value / 100));

  /// `7:46 AM`, `07:46` in Turkish, `7:46 ص` in Arabic: each language's own short time.
  String time(DateTime instant) => isolate(_time.format(_atPlace(instant)));

  /// `Thursday`, `Perşembe`, `الخميس`. A word, so no isolate.
  String dayName(DateTime instant) => _weekday.format(_atPlace(instant));

  /// True when both instants fall on the same calendar day at the place.
  bool sameDay(DateTime a, DateTime b) {
    final (x, y) = (_atPlace(a), _atPlace(b));
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  /// The wall clock at the place, as a UTC `DateTime` (its fields are the local time there).
  DateTime _atPlace(DateTime instant) => instant.toUtc().add(utcOffset);
}

/// "Updated 2 hours ago" (F-08): the unit and the count, so the translation picks the plural
/// form. Under an hour counts minutes, under a day hours, then days.
({UpdatedAgoUnit unit, int count}) updatedAgo(Duration age) {
  final minutes = age.inMinutes < 0 ? 0 : age.inMinutes;
  if (minutes < 60) return (unit: UpdatedAgoUnit.minutes, count: minutes);
  final hours = minutes ~/ 60;
  return hours < 24
      ? (unit: UpdatedAgoUnit.hours, count: hours)
      : (unit: UpdatedAgoUnit.days, count: hours ~/ 24);
}

enum UpdatedAgoUnit { minutes, hours, days }
