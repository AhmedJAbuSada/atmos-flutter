import 'dart:convert';

import 'package:atmos_data/src/local/cache_key.dart';
import 'package:atmos_data/src/local/key_value_store.dart';
import 'package:atmos_data/src/remote/open_meteo_api.dart';
import 'package:atmos_data/src/repositories/city_repository.dart';
import 'package:atmos_data/src/repositories/settings_repository.dart';
import 'package:atmos_data/src/repositories/weather_repository.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/samples.dart';

void main() {
  group('cacheKey', () {
    test('rounds to two decimals and always uses a dot', () {
      expect(cacheKey(coordinates(41.0138, 28.9497)), 'forecast:41.01,28.95');
      expect(cacheKey(coordinates(-33.8688, -151.2093)), 'forecast:-33.87,-151.21');
    });
  });

  group('readJson', () {
    test('missing or unreadable data is null, never a crash', () async {
      final store = InMemoryKeyValueStore({'bad': 'not json', 'good': '[1]'});
      expect(await readJson(store, 'missing'), isNull);
      expect(await readJson(store, 'bad'), isNull);
      expect(await readJson(store, 'good'), [1]);
    });
  });

  group('WeatherRepository', () {
    ({InMemoryKeyValueStore store, WeatherRepositoryImpl repository}) setUp([
      List<Reply> replies = const [],
    ]) {
      final store = InMemoryKeyValueStore();
      final repository = WeatherRepositoryImpl(
        OpenMeteoApi(ReplayingClient(replies)),
        store,
        FixedDateProvider(),
      );
      return (store: store, repository: repository);
    }

    test('a downloaded forecast is mapped and saved as the raw response', () async {
      final (:store, :repository) = setUp([ok(sample('forecast_istanbul.json'))]);
      final result = await repository.fetchForecast(istanbul);
      expect(switch (result) {
        Ok(:final value) => value.current.temperature,
        Err() => null,
      }, const Temperature(14.9));
      expect(jsonDecode(store.entries[cacheKey(istanbul)] ?? '{}'), {
        'raw': sample('forecast_istanbul.json'),
        'fetchedAt': testNow.millisecondsSinceEpoch,
      });
    });

    test('the cache gives back the same forecast with its fetch time', () async {
      final (store: _, :repository) = setUp([ok(sample('forecast_istanbul.json'))]);
      final fetched = await repository.fetchForecast(istanbul);
      final cached = await repository.cachedForecast(istanbul);
      expect(fetched, Ok<Forecast>(cached ?? forecast()));
      expect(cached?.fetchedAt, testNow);
    });

    test('nothing cached is null', () async {
      expect(await setUp().repository.cachedForecast(istanbul), isNull);
    });

    test('an unreadable cache is "no cache", never a crash', () async {
      final (:store, :repository) = setUp();
      for (final broken in [
        'not json',
        '[]',
        jsonEncode({'raw': '{}', 'fetchedAt': testNow.millisecondsSinceEpoch}),
        jsonEncode({'raw': 'not json', 'fetchedAt': 0}),
        jsonEncode({'raw': sample('forecast_istanbul.json')}),
      ]) {
        store.entries[cacheKey(istanbul)] = broken;
        expect(await repository.cachedForecast(istanbul), isNull, reason: broken);
      }
    });

    test('given no network, then fails with NoConnection and keeps the old cache', () async {
      // The real client retries; this one replays the failure without waiting.
      final (:store, :repository) = setUp([networkError()]);
      store.entries[cacheKey(istanbul)] = 'old';
      expect(await repository.fetchForecast(istanbul), const Err<Forecast>(NoConnection()));
      expect(store.entries[cacheKey(istanbul)], 'old');
    });

    test('given HTTP 400 (the recorded error), then fails with a server error', () async {
      final (store: _, :repository) = setUp([status(400, sample('forecast_error.json'))]);
      expect(await repository.fetchForecast(istanbul), const Err<Forecast>(ServerError(400)));
    });

    test('given an answer without current conditions, then fails with UnknownError', () async {
      final (:store, :repository) = setUp([ok(sample('geocoding_empty.json'))]);
      expect(await repository.fetchForecast(istanbul), const Err<Forecast>(UnknownError()));
      expect(store.entries, isEmpty);
    });
  });

  group('CityRepository', () {
    final ankara = city(323786, 'Ankara');
    final izmir = city(311046, 'İzmir');

    test('search maps the recorded results in the requested language', () async {
      final client = ReplayingClient([ok(sample('geocoding_istanbul_ar.json'))]);
      final repository = CityRepositoryImpl(OpenMeteoApi(client), InMemoryKeyValueStore());
      final result = await repository.search('istanbul', 'ar');
      expect(switch (result) {
        Ok(:final value) => value.first.name,
        Err() => null,
      }, 'اسطنبول');
      expect(client.urls.single.queryParameters['language'], 'ar');
    });

    test('given no network, then search fails with NoConnection', () async {
      final repository = CityRepositoryImpl(
        OpenMeteoApi(ReplayingClient([networkError()])),
        InMemoryKeyValueStore(),
      );
      expect(await repository.search('istanbul', 'en'), const Err<List<City>>(NoConnection()));
    });

    test('saved cities survive a restart, oldest first, without duplicates', () async {
      final store = InMemoryKeyValueStore();
      final api = OpenMeteoApi(ReplayingClient());
      final first = CityRepositoryImpl(api, store);
      await first.save(ankara);
      await first.save(izmir);
      await first.save(ankara);
      final afterRestart = CityRepositoryImpl(api, store);
      expect(await afterRestart.savedCities(), [ankara, izmir]);
    });

    test('remove deletes one city and observers hear every change', () async {
      final store = InMemoryKeyValueStore();
      final api = OpenMeteoApi(ReplayingClient());
      final writer = CityRepositoryImpl(api, store);
      await writer.save(ankara);
      await writer.save(izmir);

      final repository = CityRepositoryImpl(api, store);
      final heard = <List<int>>[];
      final subscription = repository.observeSavedCities().listen(
        (cities) => heard.add([for (final city in cities) city.id]),
      );
      await pumpEventQueue();
      await repository.remove(ankara.id);
      await pumpEventQueue();
      await subscription.cancel();
      await repository.remove(izmir.id);
      await pumpEventQueue();

      expect(heard, [
        [ankara.id, izmir.id],
        [izmir.id],
      ]);
    });

    test('unreadable saved cities are an empty list, and a broken entry is dropped', () async {
      final notAList = CityRepositoryImpl(
        OpenMeteoApi(ReplayingClient()),
        InMemoryKeyValueStore({CityRepositoryImpl.savedCitiesKey: '{"not": "a list"}'}),
      );
      expect(await notAList.savedCities(), isEmpty);

      final oneBroken = CityRepositoryImpl(
        OpenMeteoApi(ReplayingClient()),
        InMemoryKeyValueStore({
          CityRepositoryImpl.savedCitiesKey: jsonEncode([
            {'id': 1, 'name': 'Ankara', 'latitude': 39.92, 'longitude': 32.85},
            {'id': 2, 'name': 'Nowhere', 'latitude': 999, 'longitude': 0},
            'not a city',
          ]),
        }),
      );
      expect([for (final city in await oneBroken.savedCities()) city.name], ['Ankara']);
    });
  });

  group('SettingsRepository', () {
    test('starts with the defaults and saves a change', () async {
      final store = InMemoryKeyValueStore();
      final repository = SettingsRepositoryImpl(store);
      final heard = <UserSettings>[];
      repository.observeSettings().listen(heard.add);
      await pumpEventQueue();

      await repository.updateSettings(temperatureUnit: TemperatureUnit.fahrenheit);
      await pumpEventQueue();

      expect(heard, [
        UserSettings.defaults,
        UserSettings.defaults.copyWith(temperatureUnit: TemperatureUnit.fahrenheit),
      ]);
      expect(jsonDecode(store.entries[SettingsRepositoryImpl.settingsKey] ?? '{}'), {
        'temperatureUnit': 'fahrenheit',
        'windSpeedUnit': 'kilometersPerHour',
        'theme': 'system',
      });
    });

    test('reads the stored settings after a restart', () async {
      final store = InMemoryKeyValueStore({
        SettingsRepositoryImpl.settingsKey: jsonEncode({
          'theme': 'dark',
          'windSpeedUnit': 'milesPerHour',
        }),
      });
      expect(
        await SettingsRepositoryImpl(store).observeSettings().first,
        const UserSettings(windSpeedUnit: WindSpeedUnit.milesPerHour, theme: AppTheme.dark),
      );
    });

    test('given unknown stored values, then those fields fall back to the defaults', () async {
      final store = InMemoryKeyValueStore({
        SettingsRepositoryImpl.settingsKey: jsonEncode({
          'temperatureUnit': 'kelvin',
          'theme': 'dark',
          'windSpeedUnit': 3,
        }),
      });
      expect(
        await SettingsRepositoryImpl(store).observeSettings().first,
        UserSettings.defaults.copyWith(theme: AppTheme.dark),
      );
    });

    test('given unreadable stored settings, then the defaults', () async {
      final store = InMemoryKeyValueStore({SettingsRepositoryImpl.settingsKey: 'not json'});
      expect(await SettingsRepositoryImpl(store).observeSettings().first, UserSettings.defaults);
    });
  });
}
