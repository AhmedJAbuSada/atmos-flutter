import '../common/result.dart';
import 'city.dart';
import 'coordinates.dart';

/// The device location. Implemented with geolocator in `atmos_data` (step 04).
abstract interface class LocationRepository {
  /// The current position, or `LocationPermissionDenied` / `LocationUnavailable`.
  /// **Never asks** for the permission: that is a UI decision, after an explanation (US-01).
  Future<Result<Coordinates>> currentLocation();
}

/// City search (remote) and the saved cities (local).
abstract interface class CityRepository {
  /// Searches by name; [languageCode] selects the language of the returned names (F-05).
  Future<Result<List<City>>> search(String query, String languageCode);

  /// The saved cities, oldest first.
  Future<List<City>> savedCities();

  /// The saved cities at once, then after every change.
  Stream<List<City>> observeSavedCities();

  /// Saves [city]; a city that is already saved keeps its position.
  Future<void> save(City city);

  Future<void> remove(int cityId);
}
