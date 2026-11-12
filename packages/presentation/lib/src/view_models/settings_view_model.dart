import 'dart:async';

import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../settings/settings_view.dart';

/// Settings' view model (US-08). Every screen observes the same settings repository, so a
/// change here updates them all without being told. The app also watches it for the theme, so
/// it lives as long as the app.
final settingsViewModelProvider = NotifierProvider<SettingsViewModel, UserSettings>(
  SettingsViewModel.new,
);

final class SettingsViewModel extends Notifier<UserSettings> {
  @override
  UserSettings build() {
    final subscription = ref.watch(settingsRepositoryProvider).observeSettings().listen((value) {
      if (ref.mounted) state = value;
    });
    ref.onDispose(() => unawaited(subscription.cancel()));
    return UserSettings.defaults;
  }

  /// The data events. Opening About is navigation and belongs to the screen.
  Future<void> onEvent(SettingsEvent event) {
    final repository = ref.read(settingsRepositoryProvider);
    return switch (event) {
      SettingsTemperatureUnitChanged(:final unit) => _change(
        state.copyWith(temperatureUnit: unit),
        () => repository.updateSettings(temperatureUnit: unit),
      ),
      SettingsWindSpeedUnitChanged(:final unit) => _change(
        state.copyWith(windSpeedUnit: unit),
        () => repository.updateSettings(windSpeedUnit: unit),
      ),
      SettingsThemeChanged(:final theme) => _change(
        state.copyWith(theme: theme),
        () => repository.updateSettings(theme: theme),
      ),
      SettingsOpenLanguageSettings() => ref.read(appPlatformProvider).openLanguageSettings(),
      SettingsOpenAbout() => Future.value(),
    };
  }

  /// The screen answers at once; the repository then confirms it through the stream.
  Future<void> _change(UserSettings next, Future<void> Function() save) {
    state = next;
    return save();
  }
}
