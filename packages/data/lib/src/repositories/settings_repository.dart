import 'dart:convert';

import 'package:atmos_domain/atmos_domain.dart';

import '../local/key_value_store.dart';
import '../remote/json_reading.dart';

/// The settings, stored as the **names** of the enum values (`"fahrenheit"`), and sanitized on
/// every read: a value from an older version, or a typo, falls back to the default for that
/// field instead of breaking the app.
final class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  static const settingsKey = 'settings';

  final KeyValueStore _store;
  final _settings = ValueStore<UserSettings>(UserSettings.defaults);
  Future<void>? _loading;

  Future<void> _load() => _loading ??= () async {
    _settings.value = _sanitize(readObject(await readJson(_store, settingsKey)));
  }();

  @override
  Stream<UserSettings> observeSettings() async* {
    await _load();
    yield* _settings.watch();
  }

  @override
  Future<void> updateSettings({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    AppTheme? theme,
  }) async {
    await _load();
    final next = _settings.value.copyWith(
      temperatureUnit: temperatureUnit,
      windSpeedUnit: windSpeedUnit,
      theme: theme,
    );
    _settings.value = next;
    await _store.setString(
      settingsKey,
      jsonEncode({
        'temperatureUnit': next.temperatureUnit.name,
        'windSpeedUnit': next.windSpeedUnit.name,
        'theme': next.theme.name,
      }),
    );
  }
}

/// Allowed values only; anything else is the default for that field.
UserSettings _sanitize(Map<String, Object?>? stored) {
  const defaults = UserSettings.defaults;
  T pick<T extends Enum>(List<T> values, String key, T fallback) =>
      values.asNameMap()[readString(stored?[key])] ?? fallback;
  return UserSettings(
    temperatureUnit: pick(TemperatureUnit.values, 'temperatureUnit', defaults.temperatureUnit),
    windSpeedUnit: pick(WindSpeedUnit.values, 'windSpeedUnit', defaults.windSpeedUnit),
    theme: pick(AppTheme.values, 'theme', defaults.theme),
  );
}
