import 'dart:async';

import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Records what the screens asked the phone to do, and answers the permission dialog.
final class FakeAppPlatform implements AppPlatform {
  PermissionAnswer answer = PermissionAnswer.granted;

  /// Called when the dialog is answered, so a test can grant the permission in the fakes too.
  void Function(PermissionAnswer answer)? onAnswer;
  final List<String> calls = [];

  @override
  Future<PermissionAnswer> requestLocationPermission() async {
    calls.add('requestLocationPermission');
    onAnswer?.call(answer);
    return answer;
  }

  @override
  Future<void> openAppSettings() async => calls.add('openAppSettings');

  @override
  Future<void> openLanguageSettings() async => calls.add('openLanguageSettings');

  @override
  Future<void> openUrl(Uri url) async => calls.add('openUrl $url');
}

/// A weather repository whose downloads finish only when the test says so, to test late answers.
final class ControlledWeatherRepository implements WeatherRepository {
  final Map<Coordinates, Forecast> cache = {};
  final List<(Coordinates, Completer<Result<Forecast>>)> pending = [];

  @override
  Future<Forecast?> cachedForecast(Coordinates coordinates) async => cache[coordinates];

  @override
  Future<Result<Forecast>> fetchForecast(Coordinates coordinates) {
    final completer = Completer<Result<Forecast>>();
    pending.add((coordinates, completer));
    return completer.future;
  }

  /// Answers the download for [coordinates] with [result].
  void answer(Coordinates coordinates, Result<Forecast> result) {
    final index = pending.indexWhere((p) => p.$1 == coordinates);
    final (_, completer) = pending.removeAt(index);
    if (result case Ok(:final value)) cache[coordinates] = value;
    completer.complete(result);
  }
}

/// Saved cities as in [FakeCityRepository], but each search waits until the test answers it.
final class ControlledCityRepository implements CityRepository {
  final _saved = FakeCityRepository();
  final List<(String query, Completer<Result<List<City>>> answer)> searches = [];

  @override
  Future<Result<List<City>>> search(String query, String languageCode) {
    final completer = Completer<Result<List<City>>>();
    searches.add((query, completer));
    return completer.future;
  }

  @override
  Future<List<City>> savedCities() => _saved.savedCities();

  @override
  Stream<List<City>> observeSavedCities() => _saved.observeSavedCities();

  @override
  Future<void> save(City city) => _saved.save(city);

  @override
  Future<void> remove(int cityId) => _saved.remove(cityId);
}

/// A location repository that answers at once with [result], or, when [pending] is set, when
/// the test completes it (once).
final class ControlledLocationRepository implements LocationRepository {
  ControlledLocationRepository(this.result);

  Result<Coordinates> result;
  Completer<Result<Coordinates>>? pending;

  @override
  Future<Result<Coordinates>> currentLocation() {
    final waiting = pending;
    pending = null;
    return waiting?.future ?? Future.value(result);
  }
}

/// Everything the presentation layer needs, as fakes, ready to override the providers.
final class TestDependencies {
  TestDependencies({
    WeatherRepository? weather,
    Result<Coordinates>? location,
    CityRepository? cities,
  }) : weather = weather ?? FakeWeatherRepository(),
       location = ControlledLocationRepository(location ?? Ok(istanbul)),
       cities = cities ?? FakeCityRepository();

  final WeatherRepository weather;
  final ControlledLocationRepository location;
  final CityRepository cities;
  final settings = FakeSettingsRepository();
  final dates = FixedDateProvider();
  final platform = FakeAppPlatform();

  List<Override> get overrides => [
    weatherRepositoryProvider.overrideWithValue(weather),
    cityRepositoryProvider.overrideWithValue(cities),
    settingsRepositoryProvider.overrideWithValue(settings),
    locationRepositoryProvider.overrideWithValue(location),
    dateProviderProvider.overrideWithValue(dates),
    appPlatformProvider.overrideWithValue(platform),
  ];

  ProviderContainer container() => ProviderContainer.test(overrides: overrides);
}

/// Lets streams, microtasks and fake answers run.
Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
