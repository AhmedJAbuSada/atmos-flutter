// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutDataSource => 'Weather data by Open-Meteo.com';

  @override
  String get aboutLicense => 'License: MIT';

  @override
  String get aboutSourceCode => 'Source code on GitHub';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get actionBack => 'Back';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get actionRetry => 'Try again';

  @override
  String citiesAdd(String name) {
    return 'Add $name';
  }

  @override
  String citiesAlreadySaved(String name) {
    return '$name is already in your list';
  }

  @override
  String get citiesEmptySaved => 'Search for a city to add it here.';

  @override
  String get citiesNoResults => 'No cities found';

  @override
  String citiesRemove(String name) {
    return 'Remove $name';
  }

  @override
  String citiesRemoved(String name) {
    return '$name removed';
  }

  @override
  String get citiesSearchPrompt => 'Search city';

  @override
  String get citiesTitle => 'Cities';

  @override
  String get citiesUndo => 'Undo';

  @override
  String get conditionClear => 'Clear';

  @override
  String get conditionDrizzle => 'Drizzle';

  @override
  String get conditionFog => 'Fog';

  @override
  String get conditionFreezingDrizzle => 'Freezing drizzle';

  @override
  String get conditionFreezingRain => 'Freezing rain';

  @override
  String get conditionMainlyClear => 'Mainly clear';

  @override
  String get conditionOvercast => 'Overcast';

  @override
  String get conditionPartlyCloudy => 'Partly cloudy';

  @override
  String get conditionRain => 'Rain';

  @override
  String get conditionRainShowers => 'Rain showers';

  @override
  String get conditionSnow => 'Snow';

  @override
  String get conditionSnowShowers => 'Snow showers';

  @override
  String get conditionThunderstorm => 'Thunderstorm';

  @override
  String get conditionThunderstormWithHail => 'Thunderstorm with hail';

  @override
  String get conditionUnknown => 'Unknown conditions';

  @override
  String get errorLocationDenied => 'Location access is off.';

  @override
  String get errorLocationUnavailable =>
      'We couldn\'t find your location. Try again outdoors or search for a city.';

  @override
  String get errorNoConnection => 'You\'re offline. Check your connection and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that place.';

  @override
  String get errorServer => 'The weather service has a problem right now. Please try again later.';

  @override
  String get errorTimeout => 'The weather service is taking too long to answer.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get homeAllowLocation => 'Allow location';

  @override
  String get homeAttribution => 'Weather data by Open-Meteo.com';

  @override
  String get homeCurrentLocation => 'Current location';

  @override
  String homeFeelsLike(String value) {
    return 'Feels like $value';
  }

  @override
  String homeHumidity(String value) {
    return 'Humidity $value';
  }

  @override
  String get homeLoading => 'Loading the forecast';

  @override
  String homeLowHigh(String high, String low) {
    return 'Low $low, high $high';
  }

  @override
  String get homeNext24Hours => 'Next 24 hours';

  @override
  String get homeNext7Days => 'Next 7 days';

  @override
  String get homeNoLocationMessage =>
      'Allow location access to see the weather where you are, or search for a city.';

  @override
  String get homeNoLocationTitle => 'Where are you?';

  @override
  String get homeNow => 'Now';

  @override
  String get homeOpenCities => 'Cities';

  @override
  String get homeOpenSettings => 'Settings';

  @override
  String homePrecipitationChance(String value) {
    return '$value chance of precipitation';
  }

  @override
  String get homeSearchCity => 'Search for a city';

  @override
  String homeSunriseSunset(String sunrise, String sunset) {
    return 'Sunrise $sunrise · Sunset $sunset';
  }

  @override
  String get homeToday => 'Today';

  @override
  String homeUpdatedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count days ago',
      one: 'Updated $count day ago',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count hours ago',
      one: 'Updated $count hour ago',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count minutes ago',
      one: 'Updated $count minute ago',
    );
    return '$_temp0';
  }

  @override
  String homeWind(String value) {
    return 'Wind $value';
  }

  @override
  String get languageName => 'English';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLanguageFooter => 'The app language follows your phone\'s settings.';

  @override
  String get settingsLanguageOpen => 'Change language';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUnitCelsius => '°C';

  @override
  String get settingsUnitFahrenheit => '°F';

  @override
  String get settingsUnitKilometersPerHour => 'km/h';

  @override
  String get settingsUnitMetersPerSecond => 'm/s';

  @override
  String get settingsUnitMilesPerHour => 'mph';

  @override
  String get settingsWindSpeed => 'Wind speed';
}
