# Step 07 — Quality and release: proof that it works, on a device (Flutter)

**Branch:** `step-07-quality-release` · **Previous:** [step 06](06-integration.md)

Steps 03 to 06 are proven by 352 tests that run in the Dart VM and Flutter's test engine in
about half a minute. This step proves the **built app** works: on an Android emulator, the real
release APK (R8, obfuscated Dart) must start and stay up, and the main journey runs against the
real API in English, Turkish and Arabic. CI records screenshots, and a person looks at them. They
found two bugs that 352 tests had missed. The step also gets the app ready to ship: version, system
texts in three languages, the privacy manifest, a changelog and a release checklist. The same step
exists for
[Android](https://github.com/AhmedJAbuSada/atmos-android/blob/step-07-quality-release/docs/steps/07-quality-release.md),
[iOS](https://github.com/AhmedJAbuSada/atmos-ios/blob/step-07-quality-release/docs/steps/07-quality-release.md)
and [React Native](https://github.com/AhmedJAbuSada/atmos-react-native/blob/step-07-quality-release/docs/steps/07-quality-release.md).

## What this step adds

```
integration_test/journey_test.dart  ← the device journey, by key, the same in every language
test_driver/integration_test.dart   ← runs on the CI machine; writes the screenshots
scripts/device-tests.sh             ← release smoke test, then the journey per language
scripts/release-smoke-test.sh       ← the release APK must still run 15 s after start
scripts/describe-screen.py          ← on failure: what was on the screen, as annotation text
.github/workflows/ci.yml            ← android: release APK (R8, obfuscated) → device: emulator
                                       → screenshots; ios: Release build
docs/screenshots/android-{en,tr,ar}/ ← recorded by CI with "[screenshots]" in a commit message
ios/Runner/PrivacyInfo.xcprivacy    ← declares the coarse location sent to Open-Meteo
CHANGELOG.md, docs/process/RELEASE_CHECKLIST.md ← version 1.0.0
docs/architecture/adr/0018-…        ← why the journey runs in profile mode
```

## The test pyramid, finished (counted, not estimated)

| Level | What | Where | How many | Time |
|---|---|---|---|---|
| Unit | domain 83, data 76, view models 29, formatting, translations, theme and languages 51 | `dart test`, `flutter test` | 239 | seconds |
| Tooling | the source rules and the coverage gate | `dart test` | 18 | a second |
| Widget | every screen state, in en, tr and ar, dark mode, 200% text | `flutter test` | 81 | seconds |
| App with fakes | the real `AtmosApp`, routes, view models: 7 journeys + 7 language and wiring tests | `flutter test` | 14 | seconds |
| On a device | the release APK starts and stays up; the journey, real API, per-app language | emulator, CI | 1 smoke test + 1 journey × 3 languages | ~13 min |

352 automated tests run on every push, plus the emulator job. Many fast tests, few slow ones: the
slow ones only prove what the test engine cannot (the native build, R8, the plugins on a real OS,
the network, the per-app language, right to left on a real screen).

## Key ideas

### 1. The journey runs in profile mode; the release build gets a smoke test (ADR-0018)
Android and React Native drive their **release** APK from outside. An `integration_test` journey is
compiled into the app, and `flutter drive` reaches it through the Dart VM service, which a release
build does not have. So, read in Flutter 3.50's own source:
- the journey runs in **profile** mode: Dart compiled ahead of time like release, but Flutter's
  profile Android build type starts from `debug`, so **no R8 and no resource shrinking**;
- the **release** APK that the `android` job builds (R8, shrinking, `--obfuscate
  --split-debug-info`) is installed and started on the same emulator, and must still be running
  after 15 seconds with no crash in the log.

The honest gap: a crash that only R8 causes *after* the first screen would pass both. The release
checklist's manual test on a phone is there for it.

### 2. The journey is written by key, so it is the same in every language
```dart
await tester.tap(find.byKey(const Key('message.secondaryAction')));   // "Search for a city"
await tester.enterText(find.byKey(const Key('cities.search')), 'Ankara');
await waitFor(tester, find.byKey(const Key('cities.add.323786')), seconds: 60);
```
It starts **without location**, like the Android, iOS and React Native journeys: an emulator has no
Wi-Fi or cell, so it has no coarse location. Home explains, the user searches, adds Ankara (id
323786), opens it, and switches to °F. The location path is covered by the journeys with fakes.

### 3. The language is set the way a user sets it
Before each run, the script sets the app's per-app language:
`adb shell cmd locale set-app-locales dev.ahmedabusada.atmos.flutter --locales ar`. The journey is
built with `--dart-define=EXPECTED_LANGUAGE=ar` and fails if the app shows another language. The
OS path is tested, not bypassed (ADR-0005).

### 4. Real network, real budget
Open-Meteo is real here. The app itself may take ~48 s for a search (15 s timeout, two retries), so
the journey waits up to 60 s, and a language whose journey fails is run once more, with a line in
the log. Two failures in a row still fail the build.

### 5. A failing device test must say why
CI run logs need a login; annotations do not. So on failure the script prints, as `error:` lines
that `annotate-log.py` turns into annotations: the test's own message, the screen from
`uiautomator dump` (Flutter's semantics labels appear there), and the last app log lines. Run 2
below was understood from its annotation alone.

### 6. Screenshots are tests a person reads, and they found two bugs
With `[screenshots]` in a commit message, the device job commits the 15 images back to the branch
(pushes made with `GITHUB_TOKEN` start no new run, so this cannot loop). They were read in order of
risk, Arabic first:

| What we looked for | Found |
|---|---|
| Arabic mirrored: back arrow, top bar, hourly list, day bars, segments | ✅ correct |
| `13°` never `°13` in Arabic sentences | ✅ correct (the formatter's isolates) |
| **Latin digits in Arabic** | ❌ every **time** was `٧:٢٩ ص`: fixed |
| **Unit labels in Arabic Settings** | ❌ the segments read **`C°`** and **`F°`**: fixed |
| Turkish `%76`, `07:29`, `Rüzgâr 8 km/h`, long texts wrapping | ✅ correct |

Both bugs had passed every test. The times: Flutter's Material localizations load their **own** date
data, in which `ar` writes Arabic-Indic digits; the formatter test had loaded `intl`'s data first,
where `ar` uses Latin digits. `DateFormat` now gets `useNativeDigits = false`, and a test in a file
of its own (no `intl` initialization, like the app) fails without the fix. The units: `°C` is a
left-to-right value inside right-to-left text, exactly the Android app's `°11` bug, now on labels.
They are isolated like every other value.

### 7. Ready to ship, not shipped
- Version **1.0.0+1** in `pubspec.yaml` (Android `versionName`/`versionCode` and iOS
  `CFBundleShortVersionString`/`CFBundleVersion` come from it); `CHANGELOG.md`.
- The iOS location text in English, Turkish and Arabic (`InfoPlist.strings`, step 06), the same
  words as the native iOS app.
- `PrivacyInfo.xcprivacy`: coarse location, sent to Open-Meteo for app functionality, not linked to
  the user, no tracking. Flutter's template has **no** app privacy manifest; the plugins declare
  their own API use (UserDefaults) in theirs.
- iOS builds in **Release** in CI; Android ships the obfuscated release build, and its symbols are
  kept as a CI artifact (never in the repository).
- [RELEASE_CHECKLIST.md](../process/RELEASE_CHECKLIST.md): signing keys never live in the repo;
  CI's release APK is signed with the template's debug key only to install it on the emulator.

## Run it yourself

```bash
git switch step-07-quality-release
flutter pub get
tool/test_all.sh                                   # 352 tests, coverage gates
flutter build apk --release --obfuscate --split-debug-info=build/symbols
# with an Android 13+ emulator running:
./scripts/device-tests.sh
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Read Flutter 3.50's tool, Gradle plugin and binding sources to choose the test mode | Approved `integration_test` in step 01 (ADR-0011) |
| Wrote the journey, the device scripts and the CI jobs | Reviews ADR-0018's gap (no R8 in the journey) |
| Read each failure from the CI annotations and fixed the cause | — |
| Reviewed the 15 screenshots, Arabic first, and fixed the two bugs they showed | Reviews them again before a release |

**What went wrong, and what we learned**

1. **Two red emulator runs before green**, each with a lesson:
   - **Run 1 (`b9e9fe7`): a failure that hid its reason.** The annotation said only "the en
     journey failed twice". `annotate-log.py` shows just the lines that contain `error:`, and the
     script printed the screen dump without that prefix, then ended with an `error:` line. Now the
     test's message, the screen and the log are all `error:` lines, within the script's 20-line
     budget. **Lesson:** design the failure output for the only place you can read it.
     (In the same run the iOS job was cancelled by GitHub: "not acquired by Runner", a macOS
     capacity problem, not our code; it passed on the next run.)
   - **Run 2 (`f6fd15d`): typing into nothing.** The new annotation showed the Cities screen with an
     **empty** search field after `enterText("Ankara")`. On a device,
     `IntegrationTestWidgetsFlutterBinding` sets `registerTestTextInput` to `false` (a phone has a
     real keyboard), so `enterText` typed into a test input no field listened to. The widget-level
     journeys had passed because the normal test binding registers it. The journey now calls
     `tester.testTextInput.register()`. **Lesson:** the same test API can behave differently in
     another binding; read the binding, not only the method.
   - **Run 3 (`d74fc41`): green**, and the bot committed the first screenshots.
2. **The screenshots found two bugs the tests could not see** (idea 6). The digits bug had a test
   that passed *because of how the test was set up*: a first version of the new regression test
   passed with and without the fix too, until it moved into a file without `intl`'s initialization.
   **Lesson:** look at the screen; and a regression test you have not seen fail is not one yet.
3. **What the emulator taught us without failing**, from React Native's five red runs: start without
   location (no coarse location on an emulator), a Pixel 7 profile (320 × 640 screenshots are too
   small), hide "Pixel Launcher isn't responding" before starting, give the real API 60 s, and put
   the whole device script in one bash file because the runner executes `script` lines with `sh`.
   Learning from the previous port saved those runs here.
4. **What is not covered on a device:** the journey does not run under R8 (ADR-0018); the iOS app
   runs no device journey here (it builds in Release in CI); the current-location path, the system
   channel's links and the language page run only against fakes. The release checklist's manual
   test on real phones covers them.
5. **Translations are AI-written** and not reviewed by a native speaker.

## Checklist: is step 07 done?
- [x] The release APK (R8, obfuscated) starts and stays up on an emulator, in CI
- [x] The journey runs on the emulator in en, tr and ar against the real API (profile mode, ADR-0018)
- [x] Screenshots recorded by CI and reviewed; the two bugs they showed are fixed
- [x] iOS builds in Release; system texts in three languages; privacy manifest declares coarse location
- [x] Version 1.0.0, changelog, release checklist
- [x] README shows the finished app; `PROGRESS.md` updated
