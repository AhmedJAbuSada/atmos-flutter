import 'domain_error.dart';

/// The result of an operation that can fail, with a typed error instead of an exception
/// (ADR-0006). Callers handle both cases with an exhaustive `switch`:
///
/// ```dart
/// switch (await getForecast(coordinates)) {
///   case Ok(:final value): show(value);
///   case Err(:final error): showError(error);
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Success, with the [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// Failure, with the [error].
final class Err<T> extends Result<T> {
  const Err(this.error);

  final DomainError error;

  @override
  bool operator ==(Object other) => other is Err<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Err($error)';
}
