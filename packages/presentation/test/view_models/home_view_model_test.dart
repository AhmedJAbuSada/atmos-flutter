import 'dart:async';

import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// Starts Home's view model and keeps it alive, as the screen does.
Future<(ProviderContainer, HomeViewModel)> start(TestDependencies dependencies) async {
  final container = dependencies.container();
  container.listen(homeViewModelProvider, (_, _) {});
  await settle();
  return (container, container.read(homeViewModelProvider.notifier));
}

void main() {
  final ankara = city(323786, 'Ankara');

  test('given a location, then shows its forecast', () async {
    final (container, _) = await start(TestDependencies());
    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>()
          .having((s) => s.placeName, 'placeName', isNull)
          .having((s) => s.forecast, 'forecast', forecast()),
    );
  });

  test('starts with the skeleton while the first load runs', () {
    final container = TestDependencies().container();
    expect(container.read(homeViewModelProvider), isA<HomeLoading>());
  });

  group('the permission flow (US-01, F-02)', () {
    test('given no permission, then asks where the user is, without an error', () async {
      final dependencies = TestDependencies(location: const Err(LocationPermissionDenied()));
      final (container, _) = await start(dependencies);
      expect(container.read(homeViewModelProvider), isA<HomeNeedsLocation>());
      expect(dependencies.platform.calls, isEmpty); // the explanation comes first
    });

    test('"Allow location", granted, then loads the forecast', () async {
      final dependencies = TestDependencies(location: const Err(LocationPermissionDenied()));
      dependencies.platform.onAnswer = (_) => dependencies.location.result = Ok(istanbul);
      final (container, viewModel) = await start(dependencies);

      await viewModel.onEvent(const HomeRequestLocation());

      expect(dependencies.platform.calls, ['requestLocationPermission']);
      expect(container.read(homeViewModelProvider), isA<HomeContent>());
    });

    test('"Allow location", blocked, then opens the app settings', () async {
      final dependencies = TestDependencies(location: const Err(LocationPermissionDenied()));
      dependencies.platform.answer = PermissionAnswer.blocked;
      final (container, viewModel) = await start(dependencies);

      await viewModel.onEvent(const HomeRequestLocation());

      expect(dependencies.platform.calls, ['requestLocationPermission', 'openAppSettings']);
      expect(container.read(homeViewModelProvider), isA<HomeNeedsLocation>());
    });

    test('"Allow location", denied, then the explanation stays', () async {
      final dependencies = TestDependencies(location: const Err(LocationPermissionDenied()));
      dependencies.platform.answer = PermissionAnswer.denied;
      final (container, viewModel) = await start(dependencies);

      await viewModel.onEvent(const HomeRequestLocation());

      expect(dependencies.platform.calls, ['requestLocationPermission']);
      expect(container.read(homeViewModelProvider), isA<HomeNeedsLocation>());
    });
  });

  test('given no cache and no connection, then fails; retry recovers (US-07)', () async {
    final weather = FakeWeatherRepository(fetchResult: const Err(NoConnection()));
    final (container, viewModel) = await start(TestDependencies(weather: weather));
    expect(container.read(homeViewModelProvider), isA<HomeFailed>());

    weather.fetchResult = Ok(forecast());
    await viewModel.onEvent(const HomeRetry());

    expect(container.read(homeViewModelProvider), isA<HomeContent>());
  });

  test('a failed refresh keeps the forecast and says how old it is (F-08)', () async {
    final old = forecast(fetchedAt: testNow.subtract(const Duration(hours: 2)));
    final weather = FakeWeatherRepository(cached: old, fetchResult: const Err(NoConnection()));
    final (container, _) = await start(TestDependencies(weather: weather));
    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having((s) => s.outdatedBy, 'outdatedBy', const Duration(hours: 2)),
    );
  });

  test('pull to refresh downloads even a fresh forecast, and says it is refreshing', () async {
    final weather = ControlledWeatherRepository();
    final (container, viewModel) = await start(TestDependencies(weather: weather));
    weather.answer(istanbul, Ok(forecast()));
    await settle();

    final refreshing = viewModel.onEvent(const HomeRefresh());
    await settle();
    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having((s) => s.refreshing, 'refreshing', isTrue),
    );
    weather.answer(istanbul, Ok(forecast()));
    await refreshing;
    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having((s) => s.refreshing, 'refreshing', isFalse),
    );
  });

  test('a settings change re-renders without a download (US-08)', () async {
    final weather = FakeWeatherRepository();
    final dependencies = TestDependencies(weather: weather);
    final (container, _) = await start(dependencies);

    await dependencies.settings.updateSettings(temperatureUnit: TemperatureUnit.fahrenheit);
    await settle();

    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having(
        (s) => s.settings.temperatureUnit,
        'unit',
        TemperatureUnit.fahrenheit,
      ),
    );
    expect(weather.fetchCount, 1);
  });

  test('a selected city shows its name and its forecast', () async {
    final dependencies = TestDependencies();
    final (container, _) = await start(dependencies);
    container.read(selectedPlaceProvider).value = SavedPlace(ankara);
    await settle();
    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having((s) => s.placeName, 'placeName', 'Ankara'),
    );
  });

  test('a late answer for the previous place is ignored', () async {
    final weather = ControlledWeatherRepository();
    final dependencies = TestDependencies(weather: weather);
    final (container, _) = await start(dependencies); // asks for Istanbul (current location)

    container.read(selectedPlaceProvider).value = SavedPlace(ankara);
    await settle();
    weather.answer(ankara.coordinates, Ok(forecast(place: ankara.coordinates)));
    await settle();
    // Now Istanbul's download, started first, answers last.
    weather.answer(istanbul, Ok(forecast()));
    await settle();

    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>()
          .having((s) => s.placeName, 'placeName', 'Ankara')
          .having((s) => s.forecast.coordinates, 'coordinates', ankara.coordinates),
    );
  });

  test('a late "permission denied" for the current location does not hide the city', () async {
    final weather = ControlledWeatherRepository();
    final location = Completer<Result<Coordinates>>();
    final dependencies = TestDependencies(weather: weather)
      ..location.pending = location; // the current location answers when the test says so
    final (container, _) = await start(dependencies);

    container.read(selectedPlaceProvider).value = SavedPlace(ankara);
    await settle();
    weather.answer(ankara.coordinates, Ok(forecast(place: ankara.coordinates)));
    await settle();
    location.complete(const Err(LocationPermissionDenied())); // late, for the old place
    await settle();

    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having((s) => s.placeName, 'placeName', 'Ankara'),
    );
  });

  test('after a late answer, a settings change still updates the city on screen', () async {
    final weather = ControlledWeatherRepository();
    final dependencies = TestDependencies(weather: weather);
    final (container, _) = await start(dependencies);

    container.read(selectedPlaceProvider).value = SavedPlace(ankara);
    await settle();
    weather.answer(ankara.coordinates, Ok(forecast(place: ankara.coordinates)));
    await settle();
    weather.answer(istanbul, Ok(forecast())); // late, for the old place
    await settle();
    await dependencies.settings.updateSettings(temperatureUnit: TemperatureUnit.fahrenheit);
    await settle();

    expect(
      container.read(homeViewModelProvider),
      isA<HomeContent>().having(
        (s) => s.settings.temperatureUnit,
        'unit',
        TemperatureUnit.fahrenheit,
      ),
    );
  });

  test('an answer after the screen is gone changes nothing and does not throw', () async {
    final weather = ControlledWeatherRepository();
    final (container, _) = await start(TestDependencies(weather: weather));
    container.dispose();
    weather.answer(istanbul, Ok(forecast()));
    await settle();
  });

  test('a cancelled load is never shown', () async {
    final weather = FakeWeatherRepository(fetchResult: const Err(Cancelled()));
    final (container, _) = await start(TestDependencies(weather: weather));
    expect(container.read(homeViewModelProvider), isA<HomeLoading>());
  });
}
