/// What the sky is doing, independent of any provider or language.
enum WeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  freezingDrizzle,
  rain,
  freezingRain,
  snow,
  rainShowers,
  snowShowers,
  thunderstorm,
  thunderstormWithHail,

  /// A code we do not know. Shown with a neutral icon; it must never crash the app.
  unknown;

  /// The WMO weather interpretation codes (API_CONTRACT §3), as one table.
  static WeatherCondition fromWmoCode(int? code) => switch (code) {
    0 => clear,
    1 => mainlyClear,
    2 => partlyCloudy,
    3 => overcast,
    45 || 48 => fog,
    51 || 53 || 55 => drizzle,
    56 || 57 => freezingDrizzle,
    61 || 63 || 65 => rain,
    66 || 67 => freezingRain,
    71 || 73 || 75 || 77 => snow,
    80 || 81 || 82 => rainShowers,
    85 || 86 => snowShowers,
    95 => thunderstorm,
    96 || 99 => thunderstormWithHail,
    _ => unknown,
  };
}
