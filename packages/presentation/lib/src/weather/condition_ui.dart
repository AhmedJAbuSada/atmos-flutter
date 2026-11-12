import 'package:atmos_domain/atmos_domain.dart';

import '../l10n/app_localizations.dart';

/// How a condition looks. The domain knows *what* the weather is; only the presentation layer
/// knows how to draw and say it. Emoji are colour glyphs on both platforms, need no icon font
/// and are never mirrored in right-to-left layouts: a sun is still a sun.
String conditionIcon(WeatherCondition condition, {bool isDay = true}) => switch (condition) {
  // At night a clear sky shows a moon, not a sun (US-01).
  WeatherCondition.clear || WeatherCondition.mainlyClear when !isDay => '🌙',
  WeatherCondition.partlyCloudy when !isDay => '☁️',
  WeatherCondition.clear => '☀️',
  WeatherCondition.mainlyClear => '🌤️',
  WeatherCondition.partlyCloudy => '⛅',
  WeatherCondition.overcast => '☁️',
  WeatherCondition.fog => '🌫️',
  WeatherCondition.drizzle => '🌦️',
  WeatherCondition.freezingDrizzle || WeatherCondition.freezingRain => '🌨️',
  WeatherCondition.snowShowers => '🌨️',
  WeatherCondition.rain || WeatherCondition.rainShowers => '🌧️',
  WeatherCondition.snow => '❄️',
  WeatherCondition.thunderstorm || WeatherCondition.thunderstormWithHail => '⛈️',
  WeatherCondition.unknown => '❔',
};

/// The translated name. An exhaustive switch: a new condition without a text does not compile.
String conditionLabel(WeatherCondition condition, AppLocalizations l10n) => switch (condition) {
  WeatherCondition.clear => l10n.conditionClear,
  WeatherCondition.mainlyClear => l10n.conditionMainlyClear,
  WeatherCondition.partlyCloudy => l10n.conditionPartlyCloudy,
  WeatherCondition.overcast => l10n.conditionOvercast,
  WeatherCondition.fog => l10n.conditionFog,
  WeatherCondition.drizzle => l10n.conditionDrizzle,
  WeatherCondition.freezingDrizzle => l10n.conditionFreezingDrizzle,
  WeatherCondition.rain => l10n.conditionRain,
  WeatherCondition.freezingRain => l10n.conditionFreezingRain,
  WeatherCondition.snow => l10n.conditionSnow,
  WeatherCondition.rainShowers => l10n.conditionRainShowers,
  WeatherCondition.snowShowers => l10n.conditionSnowShowers,
  WeatherCondition.thunderstorm => l10n.conditionThunderstorm,
  WeatherCondition.thunderstormWithHail => l10n.conditionThunderstormWithHail,
  WeatherCondition.unknown => l10n.conditionUnknown,
};
