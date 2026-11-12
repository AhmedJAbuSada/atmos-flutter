import 'dart:async';
import 'dart:convert';

import 'package:atmos_data/src/remote/error_mapping.dart';
import 'package:atmos_data/src/remote/http_client.dart';
import 'package:atmos_data/src/remote/open_meteo_api.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/samples.dart';

final url = Uri.https('x.test', '/');

void main() {
  group('RetryingHttpClient (API_CONTRACT §4)', () {
    ({ReplayingClient client, List<Duration> delays, Future<HttpResponse> Function() get}) run(
      List<Reply> replies,
    ) {
      final client = ReplayingClient(replies);
      final delays = <Duration>[];
      final retrying = RetryingHttpClient(client, sleep: (delay) async => delays.add(delay));
      return (client: client, delays: delays, get: () => retrying.get(url));
    }

    test('retries a network error with back-off, 1 s then 2 s', () async {
      final (:client, :delays, :get) = run([networkError(), networkError(), ok('{}')]);
      expect(await get(), const HttpResponse(200, '{}'));
      expect(client.urls, hasLength(3));
      expect(delays, const [Duration(seconds: 1), Duration(seconds: 2)]);
    });

    test('retries a timeout', () async {
      final (:client, delays: _, :get) = run([Failure(RequestTimeoutException(url)), ok('{}')]);
      expect((await get()).statusCode, 200);
      expect(client.urls, hasLength(2));
    });

    test('retries HTTP 5xx, then gives back the last answer', () async {
      final (:client, delays: _, :get) = run([status(503), status(502), status(500)]);
      expect((await get()).statusCode, 500);
      expect(client.urls, hasLength(3));
    });

    test('does not retry HTTP 4xx: our request is wrong', () async {
      final (:client, delays: _, :get) = run([status(400, sample('forecast_error.json'))]);
      expect((await get()).statusCode, 400);
      expect(client.urls, hasLength(1));
    });

    test('does not retry a cancellation: the user left', () async {
      final (:client, delays: _, :get) = run([Failure(RequestCancelledException(url))]);
      await expectLater(get(), throwsA(isA<RequestCancelledException>()));
      expect(client.urls, hasLength(1));
    });

    test('given the network stays down, then fails after two retries', () async {
      final (:client, delays: _, :get) = run([networkError(), networkError(), networkError()]);
      await expectLater(get(), throwsA(isA<http.ClientException>()));
      expect(client.urls, hasLength(3));
    });

    test('does not retry anything else', () async {
      final (:client, delays: _, :get) = run([const Failure(FormatException('odd'))]);
      await expectLater(get(), throwsA(isA<FormatException>()));
      expect(client.urls, hasLength(1));
    });
  });

  group('PackageHttpClient', () {
    test('returns status and body and sends the User-Agent', () async {
      late http.Request seen;
      final client = PackageHttpClient(
        MockClient((request) async {
          seen = request;
          return http.Response('hello', 200);
        }),
        userAgent: 'Atmos-Test/1.0',
      );
      expect(await client.get(url), const HttpResponse(200, 'hello'));
      expect(seen.method, 'GET');
      expect(seen.headers['User-Agent'], 'Atmos-Test/1.0');
    });

    test('decodes the body as UTF-8 even without a charset', () async {
      final client = PackageHttpClient(
        MockClient(
          (_) async => http.Response.bytes(utf8.encode(sample('geocoding_istanbul_ar.json')), 200),
        ),
        userAgent: 'Atmos-Test/1.0',
      );
      expect((await client.get(url)).body, contains('اسطنبول'));
    });

    /// A server that never answers, but stops like package:http's IOClient when aborted.
    MockClient hanging() => MockClient.streaming((request, _) async {
      if (request case http.Abortable(:final abortTrigger?)) await abortTrigger;
      throw http.RequestAbortedException(request.url);
    });

    test('given no answer in time, then fails with RequestTimeoutException', () async {
      final client = PackageHttpClient(
        hanging(),
        userAgent: 'Atmos-Test/1.0',
        timeout: const Duration(milliseconds: 10),
      );
      await expectLater(client.get(url), throwsA(isA<RequestTimeoutException>()));
    });

    test('given the caller cancels, then fails with RequestCancelledException', () async {
      final cancel = Completer<void>();
      final request = PackageHttpClient(
        hanging(),
        userAgent: 'Atmos-Test/1.0',
      ).get(url, cancel: cancel.future);
      cancel.complete();
      await expectLater(request, throwsA(isA<RequestCancelledException>()));
    });

    test('a network failure is passed on as it is', () async {
      final client = PackageHttpClient(
        MockClient((_) => throw http.ClientException('Failed host lookup')),
        userAgent: 'Atmos-Test/1.0',
      );
      await expectLater(client.get(url), throwsA(isA<http.ClientException>()));
    });

    test('the default timeout is the contract\'s 15 seconds', () {
      expect(PackageHttpClient.defaultTimeout, const Duration(seconds: 15));
    });
  });

  group('toDomainError: the only translation table', () {
    final table = <(Exception, DomainError)>[
      (http.ClientException('Failed host lookup'), const NoConnection()),
      (RequestTimeoutException(url), const RequestTimeout()),
      (RequestCancelledException(url), const Cancelled()),
      (const HttpStatusException(404), const NotFound()),
      (const HttpStatusException(400), const ServerError(400)),
      (const HttpStatusException(503), const ServerError(503)),
      (const FormatException('Unexpected character'), const UnknownError()),
      (const InvalidResponseException('x'), const UnknownError()),
    ];
    for (final (exception, expected) in table) {
      test('$exception becomes $expected', () {
        expect(toDomainError(exception), expected);
      });
    }
  });

  group('OpenMeteoApi', () {
    test('asks for exactly the forecast fields the app shows', () async {
      final client = ReplayingClient([ok(sample('forecast_istanbul.json'))]);
      final (:dto, :raw) = await OpenMeteoApi(client).forecast(istanbul);
      final asked = client.urls.single;
      expect('${asked.origin}${asked.path}', 'https://api.open-meteo.com/v1/forecast');
      expect(asked.queryParameters, {
        'latitude': '41.01',
        'longitude': '28.97',
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code,precipitation_probability',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
        'timezone': 'auto',
        'forecast_days': '7',
        'forecast_hours': '24',
      });
      expect(dto.timezone, 'Europe/Istanbul');
      expect(raw, sample('forecast_istanbul.json'));
    });

    test('searches in the app language and encodes the query', () async {
      final client = ReplayingClient([ok(sample('geocoding_istanbul_tr.json'))]);
      final results = await OpenMeteoApi(client).searchCities('İstanbul', 'tr');
      final asked = client.urls.single;
      expect(asked.host, 'geocoding-api.open-meteo.com');
      expect(asked.queryParameters, {
        'name': 'İstanbul',
        'count': '10',
        'language': 'tr',
        'format': 'json',
      });
      expect(asked.query, contains('name=%C4%B0stanbul'));
      expect(results.first.id, 745044);
    });

    test('a search without a results key is an empty list', () async {
      final client = ReplayingClient([ok(sample('geocoding_empty.json'))]);
      expect(await OpenMeteoApi(client).searchCities('zzzz', 'en'), isEmpty);
    });

    test('given HTTP 400 (the recorded error), then throws HttpStatusException', () async {
      final client = ReplayingClient([status(400, sample('forecast_error.json'))]);
      await expectLater(
        OpenMeteoApi(client).forecast(istanbul),
        throwsA(const HttpStatusException(400)),
      );
    });

    test('given a body that is not JSON, then throws FormatException', () async {
      final client = ReplayingClient([ok('<html>Bad gateway</html>')]);
      await expectLater(OpenMeteoApi(client).forecast(istanbul), throwsA(isA<FormatException>()));
    });
  });
}
