# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 07, quality and release ✅ done: **Atmos for Flutter 1.0.0 is finished**
**Next up:** maintenance (below)
**Last updated:** 2026-11-13

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ✅ Done | `step-05-presentation-ui` |
| 06 Integration | ✅ Done | `step-06-integration` |
| 07 Quality & release | ✅ Done | `step-07-quality-release` |

## Decisions
- 2026-11-12, the project owner: the library ADRs are approved as written (ADR-0003, 0007–0011,
  0013); end-to-end tests use `integration_test`; a dev-only lcov package is allowed for the
  coverage gates (not needed: ADR-0014); the Settings "Language" row opens the system page.
- **Waiting for the owner:** ADR-0017 (a small platform channel for links and the Android
  app-language page, instead of `url_launcher`). For review: ADR-0015 (local times from the API's
  offset), ADR-0016 (gen-l10n next to `material_ui`), ADR-0018 (the device journey runs in profile
  mode, so it does not run under R8).

## Maintenance
- **Release:** follow [RELEASE_CHECKLIST.md](process/RELEASE_CHECKLIST.md). The owner creates the
  `v1.0.0` tag and the GitHub Release; signing keys stay outside the repository.
- **Translations:** a native-speaker review of Turkish and Arabic (ARB files and
  `ios/Runner/*.lproj/InfoPlist.strings`); then remove the "AI-written" notes.
- **Manual test on real phones** (both platforms): location allowed and denied, the permission
  dialog, the About links and the language page (ADR-0017), offline, 200% text, dark mode.
- **Flutter upgrades:** change `FLUTTER_VERSION` in CI and the version in the docs together; run
  `flutter gen-l10n` and check whether the template still uses the deprecated delegates (if not,
  remove the analysis exclusion of ADR-0016); run the device job with `[screenshots]` and look at
  the Arabic screens again.
- **Dependencies:** `flutter pub outdated` monthly; an upgrade of `geolocator` or
  `shared_preferences` must pass the Android, iOS and device jobs.
- **Known limitation:** forecast instants after a daylight-saving change inside the 7-day window
  are one hour off (ADR-0015); the `timezone` package would fix it, with the owner's approval.
- **Possible improvements:** pass a cancellation token through the domain so a superseded search
  is aborted, not only ignored; a device journey on iOS; branch coverage.

## Notes for the next session
- Real Open-Meteo responses are in `docs/api/samples/`.
- Flutter **3.50.0** (Dart 3.14.0), pinned in CI (`FLUTTER_VERSION`). In cloud sessions:
  `git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter`, then
  `git -C $HOME/flutter checkout 3.50.0` if stable has moved.
- The Android SDK is at `/opt/android-sdk` (`flutter config --android-sdk /opt/android-sdk`).
  There is no Mac and no KVM in the cloud session: the iOS build and the emulator run only in CI.
- After a `[screenshots]` push, CI adds a "docs: update screenshots" commit to the branch: pull it
  (fast-forward) before the next push.
- The agent's tool may turn `⁦` escapes into raw invisible characters; the analyzer flags
  them (`text_direction_code_point_in_literal`). Write such files with escapes from a script.
