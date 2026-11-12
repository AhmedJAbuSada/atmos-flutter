import '../common/date_provider.dart';
import '../common/domain_error.dart';
import '../common/result.dart';
import '../location/coordinates.dart';
import '../location/repositories.dart';
import 'forecast.dart';

/// Decides whether a forecast is recent enough to show without a download (US-06).
final class ForecastFreshness {
  const ForecastFreshness(this._dates);

  /// Data younger than this is shown as it is, with no download.
  static const maxAge = Duration(minutes: 30);

  final DateProvider _dates;

  Duration age(Forecast forecast) => _dates.now().difference(forecast.fetchedAt);

  bool isFresh(Forecast forecast) => age(forecast) < maxAge;
}

/// What a screen gets: the forecast, plus the reason it is outdated when a refresh failed, so
/// the UI shows "Updated 2 hours ago" instead of an error (F-08).
final class ForecastSnapshot {
  const ForecastSnapshot(this.forecast, {this.refreshError});

  final Forecast forecast;
  final DomainError? refreshError;

  @override
  bool operator ==(Object other) =>
      other is ForecastSnapshot && other.forecast == forecast && other.refreshError == refreshError;

  @override
  int get hashCode => Object.hash(forecast, refreshError);

  @override
  String toString() => 'ForecastSnapshot(fetchedAt: ${forecast.fetchedAt}, $refreshError)';
}

/// Gets the forecast for a place, cache first (US-06, US-07).
///
/// | Cache       | forceRefresh | Network  | Result                                 |
/// |-------------|--------------|----------|----------------------------------------|
/// | fresh       | false        | not used | cached                                 |
/// | fresh       | true         | ok       | new                                    |
/// | stale/none  | any          | ok       | new                                    |
/// | stale/fresh | any          | fails    | cached, marked outdated with the error |
/// | none        | any          | fails    | the error                              |
///
/// A cancelled download is never hidden behind old data: it is returned as `Cancelled`.
final class GetForecast {
  /// A private named parameter: callers write `repository:`, and the field stays private.
  const GetForecast({required this._repository, required this._freshness});

  final WeatherRepository _repository;
  final ForecastFreshness _freshness;

  Future<Result<ForecastSnapshot>> call(
    Coordinates coordinates, {
    bool forceRefresh = false,
  }) async {
    final cached = await _repository.cachedForecast(coordinates);
    if (!forceRefresh && cached != null && _freshness.isFresh(cached)) {
      return Ok(ForecastSnapshot(cached));
    }
    return switch (await _repository.fetchForecast(coordinates)) {
      Ok(:final value) => Ok(ForecastSnapshot(value)),
      Err(error: Cancelled()) => const Err(Cancelled()),
      Err(:final error) when cached != null => Ok(ForecastSnapshot(cached, refreshError: error)),
      Err(:final error) => Err(error),
    };
  }
}

/// The last known forecast, **without** a download: for the Cities list.
final class GetCachedForecast {
  const GetCachedForecast(this._repository);

  final WeatherRepository _repository;

  Future<Forecast?> call(Coordinates coordinates) => _repository.cachedForecast(coordinates);
}

/// The forecast where the user is now (US-01). A location error (permission denied) is returned
/// as it is, so the UI can offer city search instead (F-02).
final class GetCurrentLocationForecast {
  const GetCurrentLocationForecast({required this._locations, required this._getForecast});

  final LocationRepository _locations;
  final GetForecast _getForecast;

  Future<Result<ForecastSnapshot>> call({bool forceRefresh = false}) async {
    switch (await _locations.currentLocation()) {
      case Ok(value: final coordinates):
        return _getForecast(coordinates, forceRefresh: forceRefresh);
      case Err(:final error):
        return Err(error);
    }
  }
}
