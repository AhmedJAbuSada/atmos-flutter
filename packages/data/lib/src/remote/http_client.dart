import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// The smallest thing the data layer needs from the network: GET a URL, get a status and text.
abstract interface class HttpClient {
  /// Completing [cancel] aborts the request with [RequestCancelledException].
  Future<HttpResponse> get(Uri url, {Future<void>? cancel});
}

/// A status code and the body, decoded as UTF-8.
final class HttpResponse {
  const HttpResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is HttpResponse && other.statusCode == statusCode && other.body == body;

  @override
  int get hashCode => Object.hash(statusCode, body);

  @override
  String toString() => 'HttpResponse($statusCode, ${body.length} characters)';
}

/// The request took longer than the contract allows (API_CONTRACT §4).
final class RequestTimeoutException implements Exception {
  const RequestTimeoutException(this.url);

  final Uri url;

  @override
  String toString() => 'RequestTimeoutException: $url';
}

/// The caller cancelled the request (a newer one replaced it, or the screen went away).
final class RequestCancelledException implements Exception {
  const RequestCancelledException(this.url);

  final Uri url;

  @override
  String toString() => 'RequestCancelledException: $url';
}

/// The server answered with a status outside 200–299.
final class HttpStatusException implements Exception {
  const HttpStatusException(this.statusCode);

  final int statusCode;

  @override
  bool operator ==(Object other) => other is HttpStatusException && other.statusCode == statusCode;

  @override
  int get hashCode => statusCode.hashCode;

  @override
  String toString() => 'HttpStatusException: HTTP $statusCode';
}

/// The real client, on `package:http` (ADR-0007), with the rules of API_CONTRACT §4: a
/// 15-second timeout and a User-Agent without personal data.
///
/// The timeout and the caller's [HttpClient.get] `cancel` both use `package:http`'s
/// abortable requests, so an abandoned request really stops instead of finishing unseen.
final class PackageHttpClient implements HttpClient {
  PackageHttpClient(this._inner, {required this._userAgent, this.timeout = defaultTimeout});

  static const defaultTimeout = Duration(seconds: 15);

  final http.Client _inner;
  final String _userAgent;
  final Duration timeout;

  @override
  Future<HttpResponse> get(Uri url, {Future<void>? cancel}) async {
    var timedOut = false;
    final abort = Completer<void>();
    final timer = Timer(timeout, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    unawaited(
      cancel?.whenComplete(() {
        if (!abort.isCompleted) abort.complete();
      }),
    );
    final request = http.AbortableRequest('GET', url, abortTrigger: abort.future)
      ..headers['User-Agent'] = _userAgent;
    try {
      final response = await _inner.send(request);
      // JSON is UTF-8 (RFC 8259). Decode it explicitly: http.Response would fall back to
      // Latin-1 when the Content-Type has no charset, and break "İstanbul" and "اسطنبول".
      final body = utf8.decode(await response.stream.toBytes());
      return HttpResponse(response.statusCode, body);
    } on http.RequestAbortedException {
      if (timedOut) throw RequestTimeoutException(url);
      throw RequestCancelledException(url);
    } finally {
      timer.cancel();
    }
  }
}

/// Retries network errors, timeouts and HTTP 5xx with exponential back-off: [baseDelay], then
/// twice that (1 s, 2 s). HTTP 4xx is **not** retried (our request is wrong), and neither is a
/// cancellation (the user left). Anything else is passed on at once.
final class RetryingHttpClient implements HttpClient {
  RetryingHttpClient(
    this._inner, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(seconds: 1),
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? Future<void>.delayed;

  final HttpClient _inner;
  final int maxRetries;
  final Duration baseDelay;
  final Future<void> Function(Duration) _sleep;

  @override
  Future<HttpResponse> get(Uri url, {Future<void>? cancel}) async {
    for (var attempt = 0; ; attempt++) {
      final lastAttempt = attempt >= maxRetries;
      try {
        final response = await _inner.get(url, cancel: cancel);
        if (response.statusCode < 500 || lastAttempt) return response;
      } on RequestCancelledException {
        rethrow;
      } on RequestTimeoutException {
        if (lastAttempt) rethrow;
      } on http.ClientException {
        if (lastAttempt) rethrow;
      }
      await _sleep(baseDelay * (1 << attempt));
    }
  }
}
