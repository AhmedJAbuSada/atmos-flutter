# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 02, project structure ✅ done
**Next up:** step 03, domain layer (`step-03-domain-layer`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ⏳ Next | `step-03-domain-layer` |
| 04 Data layer | ⬜ | — |
| 05 Presentation / UI | ⬜ | — |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Next up: step 03 plan
Port the domain from the Android, iOS and React Native repos to pure Dart in
`packages/domain/lib/src/`, tests first, with `package:test` (`dart test`, no Flutter):
1. `common/`: sealed `Result<T>` (`Ok`, `Err`) and sealed `DomainError` with `Cancelled` and
   `RequestTimeout` (ADR-0006); `DateProvider`; a tiny observable value store (a `Stream`).
2. `settings/`: temperature and wind units with the conversions (metric in, any unit out),
   `UserSettings` with defaults.
3. `location/`: `Coordinates` with a factory that returns `null` for impossible values;
   `City` (stable Open-Meteo `id`), places (current location first); repository interfaces;
   search (2-character minimum), save (no duplicates), remove and observe use cases.
4. `weather/`: the WMO code table as a `switch` (unknown codes → `WeatherCondition.unknown`,
   never a crash), forecast entities, `ForecastFreshness` (30 minutes), `GetForecast` with the
   cache-first decision table, and the current-location forecast.
5. Shared fakes in a testing library inside `atmos_domain` (for example
   `lib/testing.dart`), so data and presentation tests reuse them; check that
   `tool/source_rules` still passes for it.
6. Coverage gate ≥ 90% on the domain in CI (decide the tool: `dart test --coverage` +
   `package:coverage` needs an ADR or approval, as a new dev dependency).

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
- The first local `flutter build apk --debug` took about five minutes: Gradle downloaded
  itself and installed Android SDK Platform 36. Delete `build/` folders afterwards (disk space).
- Material comes from `package:material_ui` (ADR-0013). Step 05 must check that
  `flutter_localizations` and Riverpod work with it without deprecation findings.
- A version constraint in one package limits the whole workspace (one resolution): let
  `flutter pub add` choose versions that match the SDK's pins.
