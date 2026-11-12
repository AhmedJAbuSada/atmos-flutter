import 'units.dart';

/// The app theme the user picked (F-09).
enum AppTheme { system, light, dark }

/// What the user can change in Settings (F-09). There is **no language** here: the app
/// language belongs to the operating system's per-app setting (ADR-0005), so there is only one
/// source of truth.
final class UserSettings {
  const UserSettings({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windSpeedUnit = WindSpeedUnit.kilometersPerHour,
    this.theme = AppTheme.system,
  });

  /// First run: metric units, and the theme follows the system.
  static const defaults = UserSettings();

  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;
  final AppTheme theme;

  UserSettings copyWith({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    AppTheme? theme,
  }) => UserSettings(
    temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
    theme: theme ?? this.theme,
  );

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      other.temperatureUnit == temperatureUnit &&
      other.windSpeedUnit == windSpeedUnit &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(temperatureUnit, windSpeedUnit, theme);

  @override
  String toString() => 'UserSettings($temperatureUnit, $windSpeedUnit, $theme)';
}

/// Stores the settings. Implemented with shared_preferences in `atmos_data` (step 04).
abstract interface class SettingsRepository {
  /// The current settings at once, then after every change (US-08).
  Stream<UserSettings> observeSettings();

  /// Changes the given fields and keeps the others.
  Future<void> updateSettings({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    AppTheme? theme,
  });
}
