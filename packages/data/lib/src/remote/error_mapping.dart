import 'package:atmos_domain/atmos_domain.dart';
import 'package:http/http.dart' as http;

import 'http_client.dart';

/// The server answered, but without something we cannot do without.
final class InvalidResponseException implements Exception {
  const InvalidResponseException(this.reason);

  final String reason;

  @override
  String toString() => 'InvalidResponseException: $reason';
}

/// Translates a failure from the network, HTTP or JSON into a [DomainError]. The **only**
/// place that knows these exception types (ADR-0006). A cancellation is never reported as
/// "offline".
DomainError toDomainError(Exception error) => switch (error) {
  RequestCancelledException() => const Cancelled(),
  RequestTimeoutException() => const RequestTimeout(),
  HttpStatusException(statusCode: 404) => const NotFound(),
  HttpStatusException(:final statusCode) => ServerError(statusCode),
  // package:http wraps socket and DNS failures in a ClientException.
  http.ClientException() => const NoConnection(),
  // FormatException (not JSON), InvalidResponseException, anything else.
  _ => const UnknownError(),
};
