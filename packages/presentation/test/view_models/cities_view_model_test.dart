import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// `testWidgets` runs in fake time: `tester.pump(duration)` moves the clock, so the 300 ms
/// debounce and the 5 s Undo are tested without waiting.
typedef Cities = ({ProviderContainer container, CitiesViewModel viewModel});

Future<Cities> start(WidgetTester tester, TestDependencies dependencies) async {
  final container = dependencies.container();
  addTearDown(container.dispose);
  container.listen(citiesViewModelProvider, (_, _) {});
  await tester.pump();
  return (container: container, viewModel: container.read(citiesViewModelProvider.notifier));
}

void main() {
  final ankara = city(323786, 'Ankara');
  final istanbulCity = city(745044, 'İstanbul');

  Future<void> type(Cities cities, String query) =>
      cities.viewModel.onEvent(CitiesQueryChanged(query), languageCode: 'tr');

  testWidgets('fewer than 2 characters searches nothing (US-04)', (tester) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await type(cities, ' a ');
    await tester.pump(const Duration(seconds: 1));
    expect((dependencies.cities as FakeCityRepository).searches, isEmpty);
    expect(cities.container.read(citiesViewModelProvider).search, isA<SearchIdle>());
  });

  testWidgets('waits 300 ms after the last keystroke, then searches once, in the app language', (
    tester,
  ) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await type(cities, 'an');
    await tester.pump(const Duration(milliseconds: 200));
    await type(cities, 'ank');
    await tester.pump(const Duration(milliseconds: 299));
    final searches = (dependencies.cities as FakeCityRepository).searches;
    expect(searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(searches, [(query: 'ank', languageCode: 'tr')]);
  });

  testWidgets('results, no results and a failure with retry (US-04)', (tester) async {
    final repository = FakeCityRepository(searchResult: Ok([ankara]));
    final cities = await start(tester, TestDependencies(cities: repository));
    SearchState search() => cities.container.read(citiesViewModelProvider).search;

    await type(cities, 'ank');
    await tester.pump(CitiesViewModel.debounce);
    expect(search(), isA<SearchResults>().having((s) => s.cities, 'cities', [ankara]));

    repository.searchResult = const Ok([]);
    await type(cities, 'zzz');
    await tester.pump(CitiesViewModel.debounce);
    expect(search(), isA<NoSearchResults>());

    repository.searchResult = const Err(NoConnection());
    await type(cities, 'ank');
    await tester.pump(CitiesViewModel.debounce);
    expect(search(), isA<SearchFailed>());

    repository.searchResult = Ok([ankara]);
    await cities.viewModel.onEvent(const CitiesRetrySearch(), languageCode: 'tr');
    await tester.pump(CitiesViewModel.debounce);
    expect(search(), isA<SearchResults>());
  });

  testWidgets('an older search that answers last is ignored', (tester) async {
    final repository = ControlledCityRepository();
    final cities = await start(tester, TestDependencies(cities: repository));

    await type(cities, 'ist');
    await tester.pump(CitiesViewModel.debounce); // the first search starts
    await type(cities, 'ank');
    await tester.pump(CitiesViewModel.debounce); // the second search starts
    repository.searches[1].$2.complete(Ok([ankara]));
    await tester.pump();
    repository.searches[0].$2.complete(Ok([istanbulCity])); // late
    await tester.pump();

    expect(
      cities.container.read(citiesViewModelProvider).search,
      isA<SearchResults>().having((s) => s.cities, 'cities', [ankara]),
    );
  });

  testWidgets('Add saves the city and goes back to the list; adding it again says so (US-05)', (
    tester,
  ) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await type(cities, 'ank');
    await cities.viewModel.onEvent(CitiesAdd(ankara), languageCode: 'tr');
    await tester.pump();

    final state = cities.container.read(citiesViewModelProvider);
    expect(state.query, '');
    expect(
      [for (final item in state.places) item.place],
      [const CurrentLocation(), SavedPlace(ankara)],
    );

    await cities.viewModel.onEvent(CitiesAdd(ankara), languageCode: 'tr');
    expect(cities.container.read(citiesViewModelProvider).notice, isA<CityAlreadySaved>());
  });

  testWidgets('Remove offers Undo for 5 seconds; Undo saves the city again (US-05)', (
    tester,
  ) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await dependencies.cities.save(ankara);
    await dependencies.cities.save(istanbulCity);
    await tester.pump();

    await cities.viewModel.onEvent(CitiesRemove(ankara), languageCode: 'tr');
    await tester.pump(const Duration(seconds: 4));
    expect(cities.container.read(citiesViewModelProvider).notice, isA<CityRemoved>());
    await cities.viewModel.onEvent(const CitiesUndo(), languageCode: 'tr');
    await tester.pump();
    expect(await dependencies.cities.savedCities(), [istanbulCity, ankara]);
    expect(cities.container.read(citiesViewModelProvider).notice, isNull);

    await cities.viewModel.onEvent(CitiesRemove(ankara), languageCode: 'tr');
    await tester.pump(CitiesViewModel.noticeDuration);
    expect(cities.container.read(citiesViewModelProvider).notice, isNull); // too late for Undo
  });

  testWidgets('removing the city Home shows sends Home back to the current location', (
    tester,
  ) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await dependencies.cities.save(ankara);
    await cities.viewModel.onEvent(CitiesSelect(SavedPlace(ankara)), languageCode: 'tr');
    expect(cities.container.read(selectedPlaceProvider).value, SavedPlace(ankara));

    await cities.viewModel.onEvent(CitiesRemove(ankara), languageCode: 'tr');

    expect(cities.container.read(selectedPlaceProvider).value, const CurrentLocation());
    await tester.pump(CitiesViewModel.noticeDuration);
  });

  testWidgets('saved places show their last known weather, from the cache only', (tester) async {
    final weather = FakeWeatherRepository(cached: forecast());
    final dependencies = TestDependencies(weather: weather);
    await dependencies.cities.save(ankara);
    final cities = await start(tester, dependencies);
    await tester.pump();

    final saved = cities.container.read(citiesViewModelProvider).places.last;
    expect(saved.temperature, const Temperature(14.9));
    expect(saved.condition, WeatherCondition.overcast);
    expect(weather.fetchCount, 0);
  });

  testWidgets('the temperature unit follows the settings', (tester) async {
    final dependencies = TestDependencies();
    final cities = await start(tester, dependencies);
    await dependencies.settings.updateSettings(temperatureUnit: TemperatureUnit.fahrenheit);
    await tester.pump();
    expect(
      cities.container.read(citiesViewModelProvider).temperatureUnit,
      TemperatureUnit.fahrenheit,
    );
  });

  testWidgets('leaving the screen stops a waiting search', (tester) async {
    final dependencies = TestDependencies();
    final container = dependencies.container();
    final subscription = container.listen(citiesViewModelProvider, (_, _) {});
    await tester.pump();
    await container
        .read(citiesViewModelProvider.notifier)
        .onEvent(const CitiesQueryChanged('ank'), languageCode: 'tr');
    subscription.close(); // the screen goes away: autoDispose
    await tester.pump(const Duration(seconds: 1));
    expect((dependencies.cities as FakeCityRepository).searches, isEmpty);
    container.dispose();
  });
}
