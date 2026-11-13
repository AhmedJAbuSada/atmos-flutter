# Release checklist (Flutter)

## Before
- [ ] `main` is green: generated localizations, format, analyze, source rules, every package's
      tests with the coverage gates, the Android release build (R8, obfuscated Dart), the release
      smoke test and the journey on the emulator in en, tr and ar, and the iOS Release build.
- [ ] The version is `version: X.Y.Z+N` in `pubspec.yaml` (`N` + 1 for every store upload) and
      `appVersion` in `lib/app/composition.dart` says the same `X.Y.Z`.
- [ ] `CHANGELOG.md` updated.
- [ ] Screenshots recorded (`[screenshots]` in a commit message) and **looked at** in all three
      languages: layout mirrored in Arabic, `11°` never `°11`, Latin digits, Turkish `%69` and
      `07:46`, long Turkish texts wrapping.
- [ ] Translations reviewed by a native speaker (until then the README and the ARB files say they
      are AI-written), including the iOS permission text in `ios/Runner/*.lproj/InfoPlist.strings`.
- [ ] Privacy: `ios/Runner/PrivacyInfo.xcprivacy` still matches what the app does (coarse location
      sent to Open-Meteo for the forecast, nothing else); the Play Console data-safety form says
      the same.

## Build and upload
Keystores, `key.properties`, `local.properties`, signing certificates and provisioning profiles are
**never** in the repository (`.gitignore` excludes them). CI's release APK is signed with the
template's debug key, only to install it on the emulator; it must never be uploaded.

**Android**, with the team's upload key outside the repo (a `key.properties` next to the project,
or CI secrets, read by a `release` signing config that a maintainer adds):
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
# build/app/outputs/bundle/release/app-release.aab
```
Keep `build/symbols/` with the release (outside the repo): it turns obfuscated stack traces back
into names (`flutter symbolize`). Upload the `.aab` to the Play Console, internal testing first.

**iOS**, on a Mac with the team's Apple Developer account:
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```
Upload with Xcode's Organizer or Transporter; TestFlight first.

- [ ] Manual smoke test on a real phone of each platform: location allowed, location denied
      (then allowed from the explanation), search, offline (airplane mode), Arabic, Turkish,
      largest text size, dark mode, the About links and the language page.

## After
- [ ] GitHub Release `vX.Y.Z` from `main` (the owner creates the tag).
- [ ] Watch crash reports for a day before releasing to everyone.
