/// Unit the user wants temperatures shown in (F-09).
enum TemperatureUnit { celsius, fahrenheit }

/// Unit the user wants wind speed shown in (F-09).
enum WindSpeedUnit { kilometersPerHour, metersPerSecond, milesPerHour }

/// A temperature, stored in Celsius as the API sends it and converted only for display, so
/// changing the unit never needs a download (US-08).
///
/// An *extension type*: at run time it is just a `double`, but the compiler will not let a
/// [WindSpeed] (or a bare number) be passed where a [Temperature] is expected.
extension type const Temperature(double celsius) {
  double inUnit(TemperatureUnit unit) => switch (unit) {
    TemperatureUnit.celsius => celsius,
    TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
  };
}

/// A wind speed, stored in km/h as the API sends it.
extension type const WindSpeed(double kilometersPerHour) {
  static const _kmhPerMetrePerSecond = 3.6;
  static const _kmhPerMile = 1.609344;

  double inUnit(WindSpeedUnit unit) => switch (unit) {
    WindSpeedUnit.kilometersPerHour => kilometersPerHour,
    WindSpeedUnit.metersPerSecond => kilometersPerHour / _kmhPerMetrePerSecond,
    WindSpeedUnit.milesPerHour => kilometersPerHour / _kmhPerMile,
  };
}
