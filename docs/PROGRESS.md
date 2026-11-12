# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 04, data layer ✅ done
**Next up:** step 05, presentation / UI (`step-05-presentation-ui`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ⏳ Next | `step-05-presentation-ui` |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Decisions
- 2026-11-12, the project owner: the library ADRs are approved as written (ADR-0003, 0007–0011,
  0013); end-to-end tests use `integration_test`; a dev-only lcov package is allowed for the
  coverage gates (not needed: ADR-0014); the Settings "Language" row opens the system page.
- ADR-0015 (agent, for review): local times use the API's `utc_offset_seconds`, no time-zone
  database; the daylight-saving limitation is written down and pinned by a test.

## Next up: step 05 plan
Port the React Native step 05 (props-only views) to `packages/presentation`, with no view
models yet (those are step 06):
1. Add `flutter_localizations` (SDK) and `intl`; `gen-l10n` with `app_en.arb`, `app_tr.arb`,
   `app_ar.arb`, each marked "AI-written, not reviewed by a native speaker"; a test that every
   key exists in all three. **First** check that `flutter_localizations` works with
   `material_ui` (ADR-0013) without deprecation findings in our code.
2. A formatter: temperatures, wind, percentages, hours and day names with `intl`, every value
   inside directional isolates (U+2066…U+2069), Arabic with Latin digits (a test asserts only
   `0–9`), Turkish `12,5`. The locale-aware casing helper, added to the source rules'
   allow-list (the one reviewed exception).
3. Light and dark design tokens with a WCAG AA contrast test; condition icons (moon at night).
4. Views that take `state` + `onEvent` only, a widget test per state: Home (loading skeleton,
   content, offline banner, error with retry, "search for a city"), Cities (search, saved,
   swipe to remove with Undo), Settings (units, theme, the Language row), About.
5. Error messages per `DomainError` (never one for `Cancelled`).
6. The app shows the new views with sample data in the OS language; remove the placeholder.

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
- A version constraint in one package limits the whole workspace (one resolution): let
  `flutter pub add` choose versions that match the SDK's pins.
- The domain's interfaces take no cancellation token (as in React Native); the HTTP client
  supports `cancel`, unused so far. Step 06 decides how a superseded search is cancelled.
- **Step 06 must add** the location permission entries: `ACCESS_COARSE_LOCATION` in the Android
  manifest and `NSLocationWhenInUseUsageDescription` (translated) in the iOS `Info.plist`.
  `GeolocatorLocationPlatform` and `SharedPreferencesStore` are untested glue until the journey
  tests of step 07.
- The first local `flutter build apk` after adding plugins failed once with an unexplained
  Gradle error and passed on the next run (see the step-04 guide).
