import '../common/result.dart';
import 'city.dart';
import 'repositories.dart';

/// Searches cities by name (US-04). The query is trimmed, and fewer than [minQueryLength]
/// characters returns nothing **without** a network call. Waiting until the user stops typing
/// (300 ms) is a UI concern, in the view model.
final class SearchCities {
  const SearchCities(this._repository);

  static const minQueryLength = 2;

  final CityRepository _repository;

  Future<Result<List<City>>> call(String query, String languageCode) async {
    final text = query.trim();
    if (text.length < minQueryLength) return const Ok([]);
    return _repository.search(text, languageCode);
  }
}

/// What happened when the user tapped "Add".
enum SaveCityResult { saved, alreadySaved }

/// Saves a city to the favourites. Saving the same city twice does nothing (US-05).
final class SaveCity {
  const SaveCity(this._repository);

  final CityRepository _repository;

  Future<SaveCityResult> call(City city) async {
    final saved = await _repository.savedCities();
    if (saved.any((it) => it.id == city.id)) return SaveCityResult.alreadySaved;
    await _repository.save(city);
    return SaveCityResult.saved;
  }
}

/// Removes a saved city. Saving it again is the "Undo" (US-05).
final class RemoveCity {
  const RemoveCity(this._repository);

  final CityRepository _repository;

  Future<void> call(int cityId) => _repository.remove(cityId);
}

/// The places list: the current location first, then the saved cities (US-05).
final class ObservePlaces {
  const ObservePlaces(this._repository);

  final CityRepository _repository;

  Stream<List<Place>> call() => _repository.observeSavedCities().map(
    (cities) => [const CurrentLocation(), for (final city in cities) SavedPlace(city)],
  );
}
