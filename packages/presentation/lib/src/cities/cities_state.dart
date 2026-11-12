import 'package:atmos_domain/atmos_domain.dart';

/// The Cities screen (US-04, US-05): a search field over the saved places.
final class CitiesState {
  const CitiesState({
    this.query = '',
    this.search = const SearchIdle(),
    this.places = const [PlaceItem(CurrentLocation())],
    this.temperatureUnit = TemperatureUnit.celsius,
    this.notice,
  });

  final String query;
  final SearchState search;
  final List<PlaceItem> places;
  final TemperatureUnit temperatureUnit;

  /// A short message under the list; "removed" offers Undo (US-05).
  final CitiesNotice? notice;
}

/// The area under the search field. [SearchIdle] shows the saved places instead.
sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class Searching extends SearchState {
  const Searching();
}

final class SearchResults extends SearchState {
  const SearchResults(this.cities);

  final List<City> cities;
}

/// Nothing matched: a message, not an error (US-04).
final class NoSearchResults extends SearchState {
  const NoSearchResults();
}

final class SearchFailed extends SearchState {
  const SearchFailed(this.error);

  final DomainError error;
}

sealed class CitiesNotice {
  const CitiesNotice(this.city);

  final City city;
}

/// The city was removed; Undo saves it again, for 5 seconds (US-05).
final class CityRemoved extends CitiesNotice {
  const CityRemoved(super.city);
}

final class CityAlreadySaved extends CitiesNotice {
  const CityAlreadySaved(super.city);
}

/// A row in the places list, with its last known weather when there is one.
final class PlaceItem {
  const PlaceItem(this.place, {this.temperature, this.condition});

  final Place place;
  final Temperature? temperature;
  final WeatherCondition? condition;
}

sealed class CitiesEvent {
  const CitiesEvent();
}

final class CitiesQueryChanged extends CitiesEvent {
  const CitiesQueryChanged(this.query);

  final String query;
}

final class CitiesRetrySearch extends CitiesEvent {
  const CitiesRetrySearch();
}

final class CitiesAdd extends CitiesEvent {
  const CitiesAdd(this.city);

  final City city;
}

final class CitiesRemove extends CitiesEvent {
  const CitiesRemove(this.city);

  final City city;
}

final class CitiesSelect extends CitiesEvent {
  const CitiesSelect(this.place);

  final Place place;
}

final class CitiesUndo extends CitiesEvent {
  const CitiesUndo();
}

/// A stable key for lists and tests: `current` or `city-745044`.
String placeKey(Place place) => switch (place) {
  CurrentLocation() => 'current',
  SavedPlace(:final city) => 'city-${city.id}',
};
