import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The three languages; widget tests run every state in each of them.
const languages = ['en', 'tr', 'ar'];

/// Shows [view] the way the app does: our themes, our languages, in [language].
Future<void> pumpView(
  WidgetTester tester,
  Widget view, {
  String language = 'en',
  AtmosColors colors = AtmosColors.light,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      theme: atmosTheme(colors),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child ?? const SizedBox(),
      ),
      home: view,
    ),
  );
  await tester.pump();
}

/// The strings of [language], to look texts up the way the view does.
Future<AppLocalizations> l10nFor(String language) =>
    AppLocalizations.delegate.load(Locale(language));

/// Records every event a view sends.
final class Events<T> {
  final List<T> sent = [];

  void call(T event) => sent.add(event);
}

/// Istanbul at 10:15 on 2026-11-11, with the values of `docs/api/samples/forecast_istanbul.json`
/// (current conditions, the first hours and days). Built from domain types: presentation
/// must not import the data layer, not even in tests.
Forecast istanbulForecast({DateTime? fetchedAt}) {
  DateTime local(int day, int hour, [int minute = 0]) =>
      DateTime.utc(2026, 11, day, hour, minute).subtract(const Duration(hours: 3));
  return Forecast(
    coordinates: Coordinates.validated(41.01, 28.97) ?? (throw StateError('valid')),
    timeZone: 'Europe/Istanbul',
    utcOffset: const Duration(hours: 3),
    current: CurrentWeather(
      time: local(11, 10, 15),
      temperature: const Temperature(14.9),
      feelsLike: const Temperature(11.2),
      humidityPercent: 69,
      windSpeed: const WindSpeed(24.8),
      condition: WeatherCondition.overcast,
      isDay: true,
    ),
    hourly: [
      HourlyForecast(
        time: local(11, 10),
        temperature: const Temperature(14.8),
        condition: WeatherCondition.partlyCloudy,
        precipitationChancePercent: 0,
      ),
      HourlyForecast(
        time: local(11, 11),
        temperature: const Temperature(15.3),
        condition: WeatherCondition.overcast,
        precipitationChancePercent: 0,
      ),
      HourlyForecast(
        time: local(11, 14),
        temperature: const Temperature(16.2),
        condition: WeatherCondition.rain,
        precipitationChancePercent: 20,
      ),
    ],
    daily: [
      DailyForecast(
        date: local(11, 0),
        condition: WeatherCondition.overcast,
        minTemperature: const Temperature(11.4),
        maxTemperature: const Temperature(16.9),
        sunrise: local(11, 7, 46),
        sunset: local(11, 17, 49),
      ),
      DailyForecast(
        date: local(12, 0),
        condition: WeatherCondition.overcast,
        minTemperature: const Temperature(16.5),
        maxTemperature: const Temperature(20.5),
        sunrise: local(12, 7, 48),
        sunset: local(12, 17, 48),
      ),
    ],
    fetchedAt: fetchedAt ?? DateTime.utc(2026, 11, 11, 7, 15),
  );
}
