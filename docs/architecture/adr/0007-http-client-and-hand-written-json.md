# ADR-0007: Networking — `package:http` and hand-written JSON parsing

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Two GET endpoints (forecast, geocoding), JSON responses, the client rules of the
[API contract](../../api/API_CONTRACT.md): timeouts, two retries with back-off for network
errors and 5xx only, a User-Agent. Android uses Retrofit + kotlinx.serialization, iOS
`URLSession` + `Codable`, React Native `fetch`.

## Decision
- [`package:http`](https://pub.dev/packages/http), maintained by the Dart team, behind a small
  `OpenMeteoApi` class in `atmos_data`. The `Client` is injected, so tests use `MockClient`
  from `package:http/testing.dart` (part of the same package) to replay the recorded samples.
- Timeouts, retries and back-off are written by hand in one small function, the same rules as
  the other apps. Aborting uses the package's abortable requests (ADR-0006).
- **JSON by hand:** `jsonDecode` + Dart 3 pattern matching into DTO classes with nullable
  fields. With `strict-casts`, every cast from `dynamic` is visible in the code.

## Alternatives considered
| Option | Why not |
|---|---|
| `dio` | Popular, with interceptors and cancel tokens we would barely use; a larger API to learn and keep up to date. |
| `json_serializable` / `freezed` | Less typing, but `build_runner` and generated files hide the parsing the tutorial wants to show; two DTOs do not need it. |
| `dart:io` `HttpClient` directly | No web support (not a goal) but, worse, no `MockClient`; tests would need a local server. |

## Consequences
- ✅ One small, official dependency; tests replay real responses with no network.
- ✅ The "missing `results` key" and "parallel arrays" cases are explicit code with tests.
- ⚠️ Hand-written parsing must be tested field by field; the samples make that cheap.
