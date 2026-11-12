# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 06, integration ✅ done
**Next up:** step 07, quality and release (`step-07-quality-release`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ✅ Done | `step-05-presentation-ui` |
| 06 Integration | ✅ Done | `step-06-integration` |
| 07 Quality & release | ⏳ Next | `step-07-quality-release` |

## Decisions
- 2026-11-12, the project owner: the library ADRs are approved as written (ADR-0003, 0007–0011,
  0013); end-to-end tests use `integration_test`; a dev-only lcov package is allowed for the
  coverage gates (not needed: ADR-0014); the Settings "Language" row opens the system page.
- **Waiting for the owner:** ADR-0017 (a small platform channel for links and the Android
  app-language page, instead of `url_launcher`, which has no approval). Also for review:
  ADR-0015 (local times from the API's offset) and ADR-0016 (gen-l10n next to `material_ui`).

## Next up: step 07 plan
1. `integration_test` (SDK, ADR-0011) on an Android emulator in CI, against the real API: the main
   journey (location already granted, search, add, pick, settings), in English and Arabic.
2. First device runs: look at every screen in Arabic and Turkish, light and dark, at 200% text;
   fix what the screenshots show (the Android app found the `°11` bug this way).
3. Screenshots recorded by CI and committed for the README.
4. Release builds: Android App Bundle and an iOS archive without signing in CI; signing stays
   with the owner (no keystore or certificate in the repository).
5. A release checklist and a localization review checklist (the translations are AI-written).
6. Tag `v1.0.0` is pushed by the owner (the agent's proxy cannot push tags).

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
- **The app has never run on a device or an emulator.** Everything below the views was tested
  with fakes; `GeolocatorLocationPlatform`, `GeolocatorPermissions`, `SharedPreferencesStore` and
  the system channel (`MainActivity.kt`, `AppDelegate.swift`) are untested glue until step 07.
- After editing an ARB file, run `flutter gen-l10n` in `packages/presentation` and commit the
  generated files; CI checks them (ADR-0016).
- The agent's tool may turn `⁦` escapes into raw invisible characters; the analyzer flags
  them (`text_direction_code_point_in_literal`). Write such files with escapes from a script.
- A version constraint in one package limits the whole workspace (one resolution): let
  `flutter pub add` choose versions that match the SDK's pins.
