# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 01, planning ✅ done
**Next up:** step 02, project structure (`step-02-project-structure`)
**Last updated:** 2026-11-12

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ⏳ Next | `step-02-project-structure` |
| 03 Domain layer | ⬜ | — |
| 04 Data layer | ⬜ | — |
| 05 Presentation / UI | ⬜ | — |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Next up: step 02 plan
1. `flutter create --platforms android,ios` with Flutter 3.50.0 (stable) into the repository
   root; package `atmos`, application id and bundle id `dev.ahmedabusada.atmos.flutter`,
   minimum Android 8.0 (API 26) and iOS 17.
2. A pub workspace: `packages/domain` (pure Dart), `packages/data`, `packages/presentation`,
   the app at the root as the composition root, and a placeholder screen.
3. Strict `analysis_options.yaml` (strict casts, inference, raw types; `flutter_lints` plus an
   explicit list; `depend_on_referenced_packages` as an error).
4. `tool/source_rules`: layer imports, locale-safe casing, `start`/`end`, with tests. Prove
   every guard by breaking it once and capturing the error.
5. CI: format, analyze, source rules and tests on Linux; Android debug build; iOS build on
   macOS without code signing; failing steps annotated with `scripts/annotate-log.py`.

## Process rule
After a step is merged into `main`, add the "📍 You are on Step N" section to the top of that
step branch's README, then push the branch.

## Notes for the next session
- Real Open-Meteo responses are in `docs/api/samples/`.
- Flutter 3.50.0 (Dart 3.14.0) can be cloned to `$HOME/flutter` in cloud sessions:
  `git clone https://github.com/flutter/flutter.git -b stable --depth 1`.
- The Android SDK is at `/opt/android-sdk` in cloud sessions; there is no Mac, so the iOS build
  is proven only in CI.
