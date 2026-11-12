# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 05, presentation / UI ✅ done
**Next up:** step 06, integration (`step-06-integration`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ✅ Done | `step-05-presentation-ui` |
| 06 Integration | ⏳ Next | `step-06-integration` |
| 07 Quality & release | ⬜ | — |

## Decisions
- 2026-11-12, the project owner: the library ADRs are approved as written (ADR-0003, 0007–0011,
  0013); end-to-end tests use `integration_test`; a dev-only lcov package is allowed for the
  coverage gates (not needed: ADR-0014); the Settings "Language" row opens the system page.
- For review (agent): ADR-0015 (local times from the API's offset) and ADR-0016 (gen-l10n output
  committed, one generated file excluded from analysis because Flutter 3.50's template still
  uses deprecated delegates).

## Next up: step 06 plan
Port React Native's step 06 to Flutter:
1. Add `flutter_riverpod` 3 to `atmos_presentation` (ADR-0003).
2. View models as `Notifier`s, one per screen, each exposing its sealed state and `onEvent`:
   - Home: load the selected place (current location or a saved city), refresh, retry, the
     permission flow; the latest load wins (a late answer is ignored).
   - Cities: 300 ms debounced search with the 2-character minimum, a late answer guard, add,
     remove with a 5 s Undo, select.
   - Settings: observe and update; open the system settings for the language.
   **Mutation-check** each guard: remove it, see its test fail, put it back.
3. Permission flow: an explanation first, then the request, and the app settings when the
   permission is permanently denied (geolocator, ADR-0009); the data layer still never asks.
4. Typed `Navigator` routes (ADR-0010); the selected place shared between Home and Cities.
5. The composition root as `ProviderScope` overrides; journey widget tests run the real app
   with fakes (no network).
6. The location permission entries: `ACCESS_COARSE_LOCATION` (Android) and a translated
   `NSLocationWhenInUseUsageDescription` (iOS).
7. Opening a web link (About) has no approved library yet: decide before building
   (`url_launcher` needs an ADR and the owner's approval; a small platform channel needs none).

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
- After editing an ARB file, run `flutter gen-l10n` in `packages/presentation` and commit the
  generated files; CI checks them (ADR-0016).
- The agent's tool may turn `⁦` escapes into raw invisible characters; the analyzer flags
  them (`text_direction_code_point_in_literal`). Write such files with escapes from a script.
- A version constraint in one package limits the whole workspace (one resolution): let
  `flutter pub add` choose versions that match the SDK's pins.
- `GeolocatorLocationPlatform` and `SharedPreferencesStore` are untested glue until the journey
  tests of step 07. The app has not been run on a device yet.
