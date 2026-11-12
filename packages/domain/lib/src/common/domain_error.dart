/// Everything that can go wrong, in the language of the business, not of the libraries
/// (ADR-0006). The data layer maps network, HTTP and parsing failures to these values; the UI
/// maps each one to a translated message.
///
/// A `switch` over a [DomainError] has no `default`, so adding a case here is a compile error
/// in every place that must handle it.
sealed class DomainError {
  const DomainError();

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '$runtimeType';
}

/// The device has no network connection.
final class NoConnection extends DomainError {
  const NoConnection();
}

/// The server did not answer in time. Not `Timeout`: `package:test` already has one.
final class RequestTimeout extends DomainError {
  const RequestTimeout();
}

/// The server answered with an HTTP error status.
final class ServerError extends DomainError {
  const ServerError(this.statusCode);

  final int statusCode;

  @override
  bool operator ==(Object other) => other is ServerError && other.statusCode == statusCode;

  @override
  int get hashCode => statusCode.hashCode;

  @override
  String toString() => 'ServerError($statusCode)';
}

/// The server has nothing at that address (HTTP 404).
final class NotFound extends DomainError {
  const NotFound();
}

/// The user has not allowed the app to read the location.
final class LocationPermissionDenied extends DomainError {
  const LocationPermissionDenied();
}

/// The location is switched off, missing on this device, or did not arrive in time.
final class LocationUnavailable extends DomainError {
  const LocationUnavailable();
}

/// The work was cancelled (a newer request replaced it, or the screen went away).
/// **Never shown to the user.**
final class Cancelled extends DomainError {
  const Cancelled();
}

/// Anything else: an unreadable response, an unexpected failure.
final class UnknownError extends DomainError {
  const UnknownError();
}
