/// Test helpers for the data layer. Responses come from the **recorded** files in
/// `docs/api/samples` (AGENTS.md: never invent API responses), read byte for byte and replayed
/// by a fake [HttpClient], so no test touches the network.
library;

import 'dart:io';

import 'package:atmos_data/src/remote/http_client.dart';
import 'package:http/http.dart' as http;

/// The recorded response, exactly as the server sent it. Tests run in `packages/data`.
String sample(String name) => File('../../docs/api/samples/$name').readAsStringSync();

/// One answer of a [ReplayingClient]: a response, or an exception to throw.
sealed class Reply {
  const Reply();
}

final class Answer extends Reply {
  const Answer(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

final class Failure extends Reply {
  const Failure(this.exception);

  final Exception exception;
}

Reply ok(String body) => Answer(200, body);

Reply status(int code, [String body = '{}']) => Answer(code, body);

/// What package:http throws when there is no network at all.
Reply networkError() => Failure(http.ClientException('Failed host lookup'));

/// Answers each request with the next reply and remembers every URL it was asked for.
final class ReplayingClient implements HttpClient {
  ReplayingClient([List<Reply> replies = const []]) : _replies = [...replies];

  final List<Reply> _replies;
  final List<Uri> urls = [];

  @override
  Future<HttpResponse> get(Uri url, {Future<void>? cancel}) async {
    urls.add(url);
    if (_replies.isEmpty) throw StateError('No reply left for $url');
    return switch (_replies.removeAt(0)) {
      Answer(:final statusCode, :final body) => HttpResponse(statusCode, body),
      Failure(:final exception) => throw exception,
    };
  }
}
