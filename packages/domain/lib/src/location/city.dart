import 'coordinates.dart';

/// A city from the geocoding search (F-05) or the saved list (F-06). [id] comes from the
/// geocoding service and is the same in every language, so it identifies a saved city (no
/// duplicates, US-05).
final class City {
  const City({
    required this.id,
    required this.name,
    required this.coordinates,
    this.region,
    this.country,
    this.countryCode,
  });

  final int id;
  final String name;
  final String? region;
  final String? country;
  final String? countryCode;
  final Coordinates coordinates;

  @override
  bool operator ==(Object other) =>
      other is City &&
      other.id == id &&
      other.name == name &&
      other.region == region &&
      other.country == country &&
      other.countryCode == countryCode &&
      other.coordinates == coordinates;

  @override
  int get hashCode => Object.hash(id, name, region, country, countryCode, coordinates);

  @override
  String toString() => 'City($id, $name)';
}

/// An entry in the places list: the current location first, then the saved cities (US-05).
sealed class Place {
  const Place();

  /// The same place, even if a saved city's name changed (another language, for example).
  bool isSamePlaceAs(Place other) => switch ((this, other)) {
    (CurrentLocation(), CurrentLocation()) => true,
    (SavedPlace(:final city), SavedPlace(city: final otherCity)) => city.id == otherCity.id,
    _ => false,
  };
}

/// Wherever the device is. Always first in the list, and it cannot be removed.
final class CurrentLocation extends Place {
  const CurrentLocation();

  @override
  bool operator ==(Object other) => other is CurrentLocation;

  @override
  int get hashCode => (CurrentLocation).hashCode;
}

/// A city the user saved.
final class SavedPlace extends Place {
  const SavedPlace(this.city);

  final City city;

  @override
  bool operator ==(Object other) => other is SavedPlace && other.city == city;

  @override
  int get hashCode => city.hashCode;
}
