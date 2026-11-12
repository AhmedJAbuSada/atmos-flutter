import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  test('follows the stored settings and saves each change (US-08)', () async {
    final dependencies = TestDependencies();
    final container = dependencies.container();
    container.listen(settingsViewModelProvider, (_, _) {});
    final viewModel = container.read(settingsViewModelProvider.notifier);

    await viewModel.onEvent(const SettingsTemperatureUnitChanged(TemperatureUnit.fahrenheit));
    await viewModel.onEvent(const SettingsWindSpeedUnitChanged(WindSpeedUnit.milesPerHour));
    await viewModel.onEvent(const SettingsThemeChanged(AppTheme.dark));
    await settle();

    const expected = UserSettings(
      temperatureUnit: TemperatureUnit.fahrenheit,
      windSpeedUnit: WindSpeedUnit.milesPerHour,
      theme: AppTheme.dark,
    );
    expect(container.read(settingsViewModelProvider), expected);
    expect(dependencies.settings.store.value, expected);
  });

  test('a change made elsewhere reaches the screen', () async {
    final dependencies = TestDependencies();
    final container = dependencies.container();
    container.listen(settingsViewModelProvider, (_, _) {});
    await dependencies.settings.updateSettings(theme: AppTheme.light);
    await settle();
    expect(container.read(settingsViewModelProvider).theme, AppTheme.light);
  });

  test('the language row opens the system page; there is no picker (ADR-0005)', () async {
    final dependencies = TestDependencies();
    final container = dependencies.container();
    await container
        .read(settingsViewModelProvider.notifier)
        .onEvent(const SettingsOpenLanguageSettings());
    expect(dependencies.platform.calls, ['openLanguageSettings']);
  });
}
