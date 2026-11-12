# ADR-0006: Errors as values — a sealed `Result` with `DomainError`

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Dart, like TypeScript and Kotlin, does not check exceptions: a function's signature does not
say what it can throw, so callers guess. Android uses `AppResult`, iOS typed throws, React
Native a `Result` union.

## Decision
```dart
sealed class DomainError { const DomainError(); }
final class NoConnection extends DomainError { const NoConnection(); }
final class RequestTimeout extends DomainError { const RequestTimeout(); }
final class ServerError extends DomainError { const ServerError(this.code); final int code; }
final class NotFound extends DomainError { const NotFound(); }
final class LocationPermissionDenied extends DomainError { … }
final class LocationUnavailable extends DomainError { … }
final class Cancelled extends DomainError { const Cancelled(); }
final class UnknownError extends DomainError { … }

sealed class Result<T> { const Result(); }
final class Ok<T> extends Result<T> { const Ok(this.value); final T value; }
final class Err<T> extends Result<T> { const Err(this.error); final DomainError error; }
```
- Fallible functions return `Future<Result<T>>`. Repositories in `atmos_data` catch every
  exception at the boundary and return `Err`.
- A `switch` on a sealed class is **exhaustive**: adding a `DomainError` makes the compiler point
  to every place that must handle it.
- **Cancellation is a value too:** a request that is superseded (a newer search, a closed
  screen) is aborted (`package:http`'s abortable requests) or its result is dropped, it becomes
  `Cancelled`, and the UI **never shows it**.
- Names avoid clashes with common imports (`RequestTimeout`, not `Timeout`, which
  `package:test` already exports).
- `Error`s (programming bugs like a failed `assert`) are not caught; they should crash in
  development.

## Alternatives considered
| Option | Why not |
|---|---|
| `throw` and `try/catch` | Untyped; callers forget the failure path. |
| `fpdart` (`Either`, `TaskEither`) | Good, but a functional-programming vocabulary and a dependency for one small type. |
| Dart records `(T?, DomainError?)` | Four states where there should be two; not exhaustive. |

## Consequences
- ✅ The same model as Android's `AppResult`, iOS's typed throws and RN's `Result`.
- ✅ Pattern matching (`switch (result) { case Ok(:final value): … case Err(:final error): … }`)
  keeps call sites short.
- ⚠️ Every repository method needs its own catch-and-map; one shared mapping function keeps
  that small.
