# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 03, domain layer ✅ done
**Next up:** step 04, data layer (`step-04-data-layer`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ⏳ Next | `step-04-data-layer` |
| 05 Presentation / UI | ⬜ | — |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Decisions
- 2026-11-12, the project owner: the library ADRs are approved as written (ADR-0003, 0007–0011,
  0013); end-to-end tests use `integration_test`; a dev-only lcov package is allowed for the
  coverage gates (not needed: ADR-0014); the Settings "Language" row opens the system page.
- ADR-0015 (agent, for review): local times use the API's `utc_offset_seconds`, no time-zone
  database; the daylight-saving limitation is written down.

## Next up: step 04 plan
Port `src/data` and `__tests__/data` from the React Native repo to `packages/data`:
1. Add `http`, `shared_preferences` and `geolocator` (approved ADRs) with `flutter pub add`.
2. `remote/`: an `HttpClient` interface; the real one on `package:http` with abortable
   requests, a 15 s timeout, the User-Agent and an explicit UTF-8 decode; a retry decorator
   (network errors and 5xx, never 4xx or cancellation; 1 s then 2 s; injected sleep); DTOs
   with every field nullable and hand-written parsing; `OpenMeteoApi`; one `toDomainError`.
3. `mappers/`: local times with the response's offset (ADR-0015); forecast (requested
   coordinates kept, broken hours and days skipped, missing current = invalid); cities.
4. `local/`: `KeyValueStore` (in memory for tests, `SharedPreferencesAsync` for real); cache key
   with two decimals; corrupt data = no data.
5. Repositories: weather (raw response + fetch time), cities (saved, observed, no duplicates),
   settings (sanitized), location (checks, never requests, the permission).
6. A `DataModule` returning domain interfaces only. Data coverage gate 85%.

## Process rule
After a step is merged into `main`, add the "📍 You are on Step N" section to the top of that
step branch's README, then push the branch.

## Notes for the next session
- Real Open-Meteo responses are in `docs/api/samples/`.
- Flutter **3.50.0** (Dart 3.14.0), pinned in CI (`FLUTTER_VERSION`). In cloud sessions:
  `git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter`, then
  `git -C $HOME/flutter checkout 3.50.0` if stable has moved.
- The Android SDK is at `/opt/android-sdk` (`flutter config --android-sdk /opt/android-sdk`).
  There is no Mac: the iOS build is proven only in CI.
- Material comes from `package:material_ui` (ADR-0013). Step 05 must check that
  `flutter_localizations` and Riverpod work with it without deprecation findings.
- A version constraint in one package limits the whole workspace (one resolution): let
  `flutter pub add` choose versions that match the SDK's pins.
- The domain's interfaces take no cancellation token (as in React Native); `Cancelled` comes
  from the HTTP layer. Step 06 decides how a view model cancels a superseded request.
