# ADR-0018: The device journey runs in profile mode; the release build gets a smoke test

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
ADR-0011 chose `integration_test` for the end-to-end journey. Step 07 must decide *how* it runs.
The other apps test their release build: Android and React Native install the R8-shrunk APK and
drive it from outside (Compose test runner, Maestro). An `integration_test` journey is different:
the test is **compiled into the app**, and `flutter drive` talks to it through the Dart VM service.

What the Flutter 3.50 tool allows on an Android emulator (read in its source):
- `debug` (JIT), `profile` and `release` all run on an x86_64 emulator.
- **`release` has no VM service**, so `flutter drive` cannot run an `integration_test` there.
- `profile` is AOT-compiled Dart, like release, with a VM service. But Flutter's Gradle plugin
  builds the `profile` Android build type from `debug`: **no R8, no resource shrinking**. Only
  `release` gets R8 (`isMinifyEnabled`), and `--obfuscate` is a release option.

## Decision
1. **The journey runs in profile mode**: `flutter build apk --profile --target=integration_test/…`,
   then `flutter drive --profile --use-application-binary=…`, once per language, on a Pixel 7-sized
   API 35 emulator, against the **real API**. It proves the AOT-compiled app, the real plugins
   (storage, location permission check), the real network and the per-app language.
2. **The release build gets a smoke test**: the exact APK the `android` job builds (R8, resource
   shrinking, obfuscated Dart with `--split-debug-info`) is installed and started, and must still
   be running 15 seconds later with no crash in the log. That is what only the release build can
   break: R8 removing a class a plugin reaches by reflection, or obfuscation breaking a name.
3. `flutter_driver` (SDK) is a dev dependency: `flutter drive` needs it to run `integration_test`.
4. The language is set the way a user sets it: `adb shell cmd locale set-app-locales … --locales ar`.
   The journey is built with `--dart-define=EXPECTED_LANGUAGE=ar` and **fails** if the app shows
   another language, so the OS path is tested, not bypassed (ADR-0005).

## Alternatives considered
| Option | Why not |
|---|---|
| Run the journey on the release APK with Maestro | The React Native choice, and it would test R8 too; but ADR-0011 chose `integration_test` (approved by the owner), and a second end-to-end tool would need its own approval. |
| `flutter test integration_test` | Builds a **debug** (JIT) app: further from what users get than profile. |
| Turn R8 on for the profile build type | Possible in `build.gradle.kts`, but then profile builds differ from Flutter's defaults everywhere, for every developer. |
| Set the language inside the test (`localesTestValue`) | Simpler and faster, but it bypasses the per-app language of the OS, which is the behaviour we promise. |

## Consequences
- ✅ The journey runs the app's real code paths, compiled ahead of time, in three languages.
- ✅ The shipped artefact is at least proven to start and stay up.
- ⚠️ The journey does not run under R8. A crash that only R8 causes **after** the first screen (for
  example in search) would pass the journey and the smoke test; the release checklist's manual
  test on a phone covers it.
- ⚠️ Three profile builds in the emulator job make it the slowest job (tens of minutes).
