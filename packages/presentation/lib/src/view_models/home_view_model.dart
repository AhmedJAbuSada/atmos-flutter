import 'dart:async';

import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_platform.dart';
import '../home/home_state.dart';
import '../providers.dart';

/// Home's view model: the place to show and the settings in, a [HomeState] out (US-01, US-06,
/// US-07). Presentation logic only: *which state to show* and *when to load*. Whether to download
/// (fresh cache, offline fallback) is `GetForecast`'s decision table from step 03.
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

final class HomeViewModel extends Notifier<HomeState> {
  Place _place = const CurrentLocation();
  UserSettings _settings = UserSettings.defaults;
  ({Place place, ForecastSnapshot snapshot})? _loaded;
  bool _refreshing = false;

  /// Every load takes a number. An answer whose number is not the latest is ignored: the user
  /// picked another city, or the screen went away, while it was on its way. Dart cannot cancel a
  /// `Future`, so this is how a late answer is kept off the screen.
  int _generation = 0;

  @override
  HomeState build() {
    final places = ref.watch(selectedPlaceProvider).watch().listen((place) {
      _place = place;
      unawaited(_load(forceRefresh: false));
    });
    final settings = ref.watch(settingsRepositoryProvider).observeSettings().listen((settings) {
      _settings = settings;
      _render(); // °C → °F changes the screen without a download (US-08)
    });
    ref.onDispose(() {
      _generation++; // answers still on their way are ignored
      unawaited(places.cancel());
      unawaited(settings.cancel());
    });
    return const HomeLoading();
  }

  /// The events that change data. Navigation events (Cities, Settings) belong to the screen.
  Future<void> onEvent(HomeEvent event) => switch (event) {
    HomeRefresh() => _refresh(),
    HomeRetry() => _load(forceRefresh: false),
    HomeRequestLocation() => _requestLocation(),
    HomeOpenCities() || HomeOpenSettings() => Future.value(),
  };

  bool get _showsPlace => _loaded?.place == _place;

  void _render() {
    final loaded = _loaded;
    if (loaded == null || !_showsPlace || !ref.mounted) return;
    final snapshot = loaded.snapshot;
    state = HomeContent(
      placeName: switch (_place) {
        SavedPlace(:final city) => city.name,
        CurrentLocation() => null,
      },
      forecast: snapshot.forecast,
      settings: _settings,
      // Old data says how old it is only when a refresh failed (F-08).
      outdatedBy: snapshot.refreshError == null
          ? null
          : ref.read(forecastFreshnessProvider).age(snapshot.forecast),
      refreshing: _refreshing,
    );
  }

  Future<void> _load({required bool forceRefresh}) async {
    final token = ++_generation;
    final target = _place;
    if (!_showsPlace) state = const HomeLoading();
    final result = switch (target) {
      CurrentLocation() =>
        await ref.read(getCurrentLocationForecastProvider).call(forceRefresh: forceRefresh),
      SavedPlace(:final city) =>
        await ref.read(getForecastProvider).call(city.coordinates, forceRefresh: forceRefresh),
    };
    if (token != _generation || !ref.mounted) return; // replaced by a newer load
    switch (result) {
      case Ok(value: final snapshot):
        _loaded = (place: target, snapshot: snapshot);
        _render();
      case Err(error: Cancelled()):
        return; // never shown (ADR-0006)
      case Err(error: LocationPermissionDenied()):
        state = const HomeNeedsLocation();
      case Err(:final error):
        // A failed load keeps what is on screen; only an empty screen shows the error.
        if (!_showsPlace) state = HomeFailed(error);
    }
  }

  Future<void> _refresh() async {
    _refreshing = true;
    _render();
    try {
      await _load(forceRefresh: true);
    } finally {
      _refreshing = false;
      _render();
    }
  }

  /// "Allow location": the explanation was on screen; now the system dialog (US-01).
  Future<void> _requestLocation() async {
    final platform = ref.read(appPlatformProvider);
    switch (await platform.requestLocationPermission()) {
      case PermissionAnswer.granted:
        await _load(forceRefresh: false);
      case PermissionAnswer.blocked:
        await platform.openAppSettings(); // the system will not show the dialog again
      case PermissionAnswer.denied:
        return; // the explanation and "Search for a city" stay on screen (F-02)
    }
  }
}
