import 'dart:async';

import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cities/cities_state.dart';
import '../providers.dart';

/// Cities' view model (US-04, US-05). Lives while the screen is open (`autoDispose`): leaving
/// the screen stops its timers and ignores answers still on their way.
final citiesViewModelProvider = NotifierProvider.autoDispose<CitiesViewModel, CitiesState>(
  CitiesViewModel.new,
);

final class CitiesViewModel extends Notifier<CitiesState> {
  /// Waits this long after the last keystroke before searching (US-04).
  static const debounce = Duration(milliseconds: 300);

  /// How long "Ankara removed · Undo" stays (US-05).
  static const noticeDuration = Duration(seconds: 5);

  Timer? _searchTimer;
  Timer? _noticeTimer;

  /// A search answer is used only if no newer query was typed meanwhile.
  int _searchGeneration = 0;
  int _placesGeneration = 0;

  @override
  CitiesState build() {
    final places = ref
        .watch(observePlacesProvider)
        .call()
        .listen((places) => unawaited(_showPlaces(places)));
    final settings = ref.watch(settingsRepositoryProvider).observeSettings().listen((settings) {
      if (ref.mounted) state = _copy(temperatureUnit: settings.temperatureUnit);
    });
    ref.onDispose(() {
      _searchTimer?.cancel();
      _noticeTimer?.cancel();
      _searchGeneration++;
      _placesGeneration++;
      unawaited(places.cancel());
      unawaited(settings.cancel());
    });
    return const CitiesState();
  }

  /// [languageCode] is the app's language, so results come back named in it ("İstanbul",
  /// "اسطنبول"). The screen passes it with every event.
  Future<void> onEvent(CitiesEvent event, {required String languageCode}) => switch (event) {
    CitiesQueryChanged(:final query) => Future.sync(() => _queryChanged(query, languageCode)),
    CitiesRetrySearch() => Future.sync(() => _queryChanged(state.query, languageCode)),
    CitiesAdd(:final city) => _add(city, languageCode),
    CitiesRemove(:final city) => _remove(city),
    CitiesUndo() => _undo(),
    CitiesSelect(:final place) => Future.sync(() => ref.read(selectedPlaceProvider).value = place),
  };

  void _queryChanged(String query, String languageCode) {
    state = _copy(query: query);
    _searchTimer?.cancel();
    final token = ++_searchGeneration;
    final text = query.trim();
    if (text.length < SearchCities.minQueryLength) {
      state = _copy(search: const SearchIdle());
      return;
    }
    // Each keystroke restarts the wait, so typing "istanbul" sends one request, not eight.
    _searchTimer = Timer(debounce, () => unawaited(_search(text, languageCode, token)));
  }

  Future<void> _search(String text, String languageCode, int token) async {
    state = _copy(search: const Searching());
    final result = await ref.read(searchCitiesProvider).call(text, languageCode);
    if (token != _searchGeneration || !ref.mounted) return; // a newer query is on its way
    state = _copy(
      search: switch (result) {
        Ok(value: final cities) when cities.isEmpty => const NoSearchResults(),
        Ok(value: final cities) => SearchResults(cities),
        // A cancelled search was replaced: keep showing progress for the newer one.
        Err(error: Cancelled()) => state.search,
        Err(:final error) => SearchFailed(error),
      },
    );
  }

  Future<void> _add(City city, String languageCode) async {
    switch (await ref.read(saveCityProvider).call(city)) {
      case SaveCityResult.saved:
        if (ref.mounted) _queryChanged('', languageCode); // back to the list, with the new city
      case SaveCityResult.alreadySaved:
        _show(CityAlreadySaved(city));
    }
  }

  Future<void> _remove(City city) async {
    await ref.read(removeCityProvider).call(city.id);
    // If the removed city is on Home, Home goes back to the current location.
    final selected = ref.read(selectedPlaceProvider);
    if (selected.value case SavedPlace(city: City(id: final id)) when id == city.id) {
      selected.value = const CurrentLocation();
    }
    _show(CityRemoved(city));
  }

  /// Saving the city again restores it (US-05).
  Future<void> _undo() async {
    final notice = state.notice;
    if (notice is! CityRemoved) return;
    _noticeTimer?.cancel();
    state = _copy(clearNotice: true);
    await ref.read(saveCityProvider).call(notice.city);
  }

  void _show(CitiesNotice notice) {
    if (!ref.mounted) return;
    state = _copy(notice: notice);
    _noticeTimer?.cancel();
    _noticeTimer = Timer(noticeDuration, () {
      if (ref.mounted && identical(state.notice, notice)) state = _copy(clearNotice: true);
    });
  }

  /// Each place with its last known weather, from the cache only: no download per row.
  Future<void> _showPlaces(List<Place> places) async {
    final token = ++_placesGeneration;
    final getCached = ref.read(getCachedForecastProvider);
    final items = [
      for (final place in places)
        switch (place) {
          CurrentLocation() => PlaceItem(place),
          SavedPlace(:final city) => switch (await getCached(city.coordinates)) {
            final cached? => PlaceItem(
              place,
              temperature: cached.current.temperature,
              condition: cached.current.condition,
            ),
            null => PlaceItem(place),
          },
        },
    ];
    if (token == _placesGeneration && ref.mounted) state = _copy(places: items);
  }

  CitiesState _copy({
    String? query,
    SearchState? search,
    List<PlaceItem>? places,
    TemperatureUnit? temperatureUnit,
    CitiesNotice? notice,
    bool clearNotice = false,
  }) => CitiesState(
    query: query ?? state.query,
    search: search ?? state.search,
    places: places ?? state.places,
    temperatureUnit: temperatureUnit ?? state.temperatureUnit,
    notice: clearNotice ? null : (notice ?? state.notice),
  );
}
