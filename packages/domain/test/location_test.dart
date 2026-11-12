import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Coordinates', () {
    test('accepts the edges of the valid range', () {
      expect(Coordinates.validated(90, 180), isNotNull);
      expect(Coordinates.validated(-90, -180), isNotNull);
    });

    for (final (latitude, longitude) in [(999.0, 28.0), (41.0, -181.0), (double.nan, 0.0)]) {
      test('refuses impossible values ($latitude, $longitude)', () {
        // The API answers 400 for latitude 999 (docs/api/samples/forecast_error.json).
        expect(Coordinates.validated(latitude, longitude), isNull);
      });
    }
  });

  /// The acceptance criteria of US-04 that belong to the domain.
  group('SearchCities', () {
    for (final query in ['i', '  i  ', '']) {
      test('given fewer than 2 characters ("$query"), then no search is made', () async {
        final repository = FakeCityRepository();
        expect(await SearchCities(repository)(query, 'tr'), const Ok<List<City>>([]));
        expect(repository.searches, isEmpty);
      });
    }

    test('given a valid query, then searches the trimmed text in the requested language', () async {
      final repository = FakeCityRepository();
      await SearchCities(repository)('  ista ', 'tr');
      expect(repository.searches, [(query: 'ista', languageCode: 'tr')]);
    });

    test('given the network fails, then returns the error', () async {
      final repository = FakeCityRepository(searchResult: const Err(NoConnection()));
      expect(await SearchCities(repository)('ista', 'en'), const Err<List<City>>(NoConnection()));
    });
  });

  /// The acceptance criteria of US-05 (favourite cities).
  group('city use cases', () {
    final ankara = city(1, 'Ankara');
    final london = city(2, 'London');

    Future<List<Place>> places(FakeCityRepository repository) => ObservePlaces(repository)().first;

    test('given no saved cities, then the list holds only the current location', () async {
      expect(await places(FakeCityRepository()), [const CurrentLocation()]);
    });

    test('saved cities follow the current location, in the order they were added', () async {
      final repository = FakeCityRepository();
      await SaveCity(repository)(ankara);
      await SaveCity(repository)(london);
      expect(await places(repository), [
        const CurrentLocation(),
        SavedPlace(ankara),
        SavedPlace(london),
      ]);
    });

    test('saving a city twice changes nothing the second time', () async {
      final repository = FakeCityRepository();
      final save = SaveCity(repository);
      expect(await save(ankara), SaveCityResult.saved);
      expect(await save(ankara), SaveCityResult.alreadySaved);
      expect(await repository.savedCities(), [ankara]);
    });

    test('removing a city, then saving it again (undo), restores it', () async {
      final repository = FakeCityRepository();
      await SaveCity(repository)(ankara);
      await RemoveCity(repository)(ankara.id);
      expect(await repository.savedCities(), isEmpty);
      await SaveCity(repository)(ankara);
      expect(await repository.savedCities(), [ankara]);
    });

    test('the places list follows every change', () async {
      final repository = FakeCityRepository();
      final lengths = <int>[];
      ObservePlaces(repository)().listen((list) => lengths.add(list.length));
      await pumpEventQueue();
      await SaveCity(repository)(ankara);
      await RemoveCity(repository)(ankara.id);
      await pumpEventQueue();
      expect(lengths, [1, 2, 1]);
    });

    test('places compare by the identity of the city', () {
      expect(const CurrentLocation().isSamePlaceAs(const CurrentLocation()), isTrue);
      expect(SavedPlace(ankara).isSamePlaceAs(SavedPlace(city(1, 'Renamed'))), isTrue);
      expect(SavedPlace(ankara).isSamePlaceAs(const CurrentLocation()), isFalse);
      expect(SavedPlace(ankara), isNot(SavedPlace(city(1, 'Renamed'))));
    });
  });
}
