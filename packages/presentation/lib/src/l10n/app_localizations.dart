import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en'), Locale('tr')];

  /// No description provided for @aboutDataSource.
  ///
  /// In en, this message translates to:
  /// **'Weather data by Open-Meteo.com'**
  String get aboutDataSource;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'License: MIT'**
  String get aboutLicense;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code on GitHub'**
  String get aboutSourceCode;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @citiesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String citiesAdd(String name);

  /// No description provided for @citiesAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in your list'**
  String citiesAlreadySaved(String name);

  /// No description provided for @citiesEmptySaved.
  ///
  /// In en, this message translates to:
  /// **'Search for a city to add it here.'**
  String get citiesEmptySaved;

  /// No description provided for @citiesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No cities found'**
  String get citiesNoResults;

  /// No description provided for @citiesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String citiesRemove(String name);

  /// No description provided for @citiesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String citiesRemoved(String name);

  /// No description provided for @citiesSearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get citiesSearchPrompt;

  /// No description provided for @citiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get citiesTitle;

  /// No description provided for @citiesUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get citiesUndo;

  /// No description provided for @conditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get conditionClear;

  /// No description provided for @conditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get conditionDrizzle;

  /// No description provided for @conditionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get conditionFog;

  /// No description provided for @conditionFreezingDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Freezing drizzle'**
  String get conditionFreezingDrizzle;

  /// No description provided for @conditionFreezingRain.
  ///
  /// In en, this message translates to:
  /// **'Freezing rain'**
  String get conditionFreezingRain;

  /// No description provided for @conditionMainlyClear.
  ///
  /// In en, this message translates to:
  /// **'Mainly clear'**
  String get conditionMainlyClear;

  /// No description provided for @conditionOvercast.
  ///
  /// In en, this message translates to:
  /// **'Overcast'**
  String get conditionOvercast;

  /// No description provided for @conditionPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get conditionPartlyCloudy;

  /// No description provided for @conditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get conditionRain;

  /// No description provided for @conditionRainShowers.
  ///
  /// In en, this message translates to:
  /// **'Rain showers'**
  String get conditionRainShowers;

  /// No description provided for @conditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get conditionSnow;

  /// No description provided for @conditionSnowShowers.
  ///
  /// In en, this message translates to:
  /// **'Snow showers'**
  String get conditionSnowShowers;

  /// No description provided for @conditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get conditionThunderstorm;

  /// No description provided for @conditionThunderstormWithHail.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm with hail'**
  String get conditionThunderstormWithHail;

  /// No description provided for @conditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown conditions'**
  String get conditionUnknown;

  /// No description provided for @errorLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access is off.'**
  String get errorLocationDenied;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find your location. Try again outdoors or search for a city.'**
  String get errorLocationUnavailable;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your connection and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that place.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The weather service has a problem right now. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The weather service is taking too long to answer.'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @homeAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get homeAllowLocation;

  /// No description provided for @homeAttribution.
  ///
  /// In en, this message translates to:
  /// **'Weather data by Open-Meteo.com'**
  String get homeAttribution;

  /// No description provided for @homeCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get homeCurrentLocation;

  /// No description provided for @homeFeelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {value}'**
  String homeFeelsLike(String value);

  /// No description provided for @homeHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity {value}'**
  String homeHumidity(String value);

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the forecast'**
  String get homeLoading;

  /// No description provided for @homeLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Low {low}, high {high}'**
  String homeLowHigh(String high, String low);

  /// No description provided for @homeNext24Hours.
  ///
  /// In en, this message translates to:
  /// **'Next 24 hours'**
  String get homeNext24Hours;

  /// No description provided for @homeNext7Days.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get homeNext7Days;

  /// No description provided for @homeNoLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see the weather where you are, or search for a city.'**
  String get homeNoLocationMessage;

  /// No description provided for @homeNoLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get homeNoLocationTitle;

  /// No description provided for @homeNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get homeNow;

  /// No description provided for @homeOpenCities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get homeOpenCities;

  /// No description provided for @homeOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeOpenSettings;

  /// No description provided for @homePrecipitationChance.
  ///
  /// In en, this message translates to:
  /// **'{value} chance of precipitation'**
  String homePrecipitationChance(String value);

  /// No description provided for @homeSearchCity.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get homeSearchCity;

  /// No description provided for @homeSunriseSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunrise {sunrise} · Sunset {sunset}'**
  String homeSunriseSunset(String sunrise, String sunset);

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeUpdatedDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Updated {count} day ago} other{Updated {count} days ago}}'**
  String homeUpdatedDays(int count);

  /// No description provided for @homeUpdatedHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Updated {count} hour ago} other{Updated {count} hours ago}}'**
  String homeUpdatedHours(int count);

  /// No description provided for @homeUpdatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Updated {count} minute ago} other{Updated {count} minutes ago}}'**
  String homeUpdatedMinutes(int count);

  /// No description provided for @homeWind.
  ///
  /// In en, this message translates to:
  /// **'Wind {value}'**
  String homeWind(String value);

  /// The name of this language, in this language. Not a translation.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLanguageFooter.
  ///
  /// In en, this message translates to:
  /// **'The app language follows your phone\'s settings.'**
  String get settingsLanguageFooter;

  /// No description provided for @settingsLanguageOpen.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get settingsLanguageOpen;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get settingsTemperature;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsUnitCelsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get settingsUnitCelsius;

  /// No description provided for @settingsUnitFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get settingsUnitFahrenheit;

  /// No description provided for @settingsUnitKilometersPerHour.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get settingsUnitKilometersPerHour;

  /// No description provided for @settingsUnitMetersPerSecond.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get settingsUnitMetersPerSecond;

  /// No description provided for @settingsUnitMilesPerHour.
  ///
  /// In en, this message translates to:
  /// **'mph'**
  String get settingsUnitMilesPerHour;

  /// No description provided for @settingsWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind speed'**
  String get settingsWindSpeed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
