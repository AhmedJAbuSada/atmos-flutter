/// In-memory fakes of the domain interfaces and ready-made test values, shared by the tests of
/// every package (the Dart equivalent of Gradle test fixtures, the iOS `AtmosTesting` target and
/// React Native's `src/testing`).
///
/// **Tests only.** `tool/source_rules` fails if production code (any `lib/`) imports this
/// library.
library;

import 'atmos_domain.dart';

final class FakeSettingsRepository implements SettingsRepository {
  final store = ValueStore<UserSettings>(UserSettings.defaults);

  @override
  Stream<UserSettings> observeSettings() => store.watch();

  @override
  Future<void> updateSettings({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    AppTheme? theme,
  }) async {
    store.value = store.value.copyWith(
      temperatureUnit: temperatureUnit,
      windSpeedUnit: windSpeedUnit,
      theme: theme,
    );
  }
}
