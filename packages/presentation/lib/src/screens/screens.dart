import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../cities/cities_state.dart';
import '../cities/cities_view.dart';
import '../home/home_state.dart';
import '../home/home_view.dart';
import '../providers.dart';
import '../settings/about_view.dart';
import '../settings/settings_view.dart';
import '../view_models/cities_view_model.dart';
import '../view_models/home_view_model.dart';
import '../view_models/settings_view_model.dart';

/// The containers: each one watches its view model and gives the view the state and an
/// `onEvent`. Data events go to the view model; navigation events go out as callbacks, so
/// the presentation layer knows no routes (the app owns them, ADR-0010).

class HomeScreen extends ConsumerWidget {
  const HomeScreen({required this.onOpenCities, required this.onOpenSettings, super.key});

  final VoidCallback onOpenCities;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => HomeView(
    state: ref.watch(homeViewModelProvider),
    onEvent: (event) => switch (event) {
      HomeOpenCities() => onOpenCities(),
      HomeOpenSettings() => onOpenSettings(),
      _ => unawaited(ref.read(homeViewModelProvider.notifier).onEvent(event)),
    },
  );
}

class CitiesScreen extends ConsumerWidget {
  const CitiesScreen({required this.onPlaceSelected, super.key});

  /// Called after a place was picked; Home already follows it.
  final VoidCallback onPlaceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Search results come back named in the app's language ("İstanbul", "اسطنبول").
    final languageCode = Localizations.localeOf(context).languageCode;
    return CitiesView(
      state: ref.watch(citiesViewModelProvider),
      onEvent: (event) {
        unawaited(
          ref.read(citiesViewModelProvider.notifier).onEvent(event, languageCode: languageCode),
        );
        if (event is CitiesSelect) onPlaceSelected();
      },
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.onOpenAbout, super.key});

  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsView(
    settings: ref.watch(settingsViewModelProvider),
    onEvent: (event) => switch (event) {
      SettingsOpenAbout() => onOpenAbout(),
      _ => unawaited(ref.read(settingsViewModelProvider.notifier).onEvent(event)),
    },
  );
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({required this.version, super.key});

  static final dataSourceUrl = Uri.https('open-meteo.com', '/');
  static final sourceCodeUrl = Uri.https('github.com', '/AhmedJAbuSada/atmos-flutter');

  final String version;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AboutView(
    version: version,
    onEvent: (event) => unawaited(
      ref.read(appPlatformProvider).openUrl(switch (event) {
        AboutOpenDataSource() => dataSourceUrl,
        AboutOpenSourceCode() => sourceCodeUrl,
      }),
    ),
  );
}
