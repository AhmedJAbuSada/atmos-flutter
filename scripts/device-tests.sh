#!/usr/bin/env bash
# On the running emulator (CI: android-emulator-runner):
#   1. the release APK smoke test (R8, obfuscated Dart);
#   2. the journey (integration_test, profile mode, real API) once per language, with the app's
#      per-app language set the way a user sets it, keeping the screenshots in
#      docs/screenshots/android-<language>/.
# Everything is in this file because the runner executes its `script` lines with plain `sh`.
set -euo pipefail

APP=dev.ahmedabusada.atmos.flutter
RELEASE_APK=build/app/outputs/flutter-apk/app-release.apk
PROFILE_APK=build/app/outputs/flutter-apk/app-profile.apk
DEVICE=$(adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')
mkdir -p build

# CI emulators are slow right after boot, and the launcher (not our app) often shows "isn't
# responding". Hide that dialog for background apps and let the system settle.
adb shell settings put global anr_show_background 0
adb shell input keyevent KEYCODE_HOME
sleep 20

echo "::group::Release smoke test"
scripts/release-smoke-test.sh "$RELEASE_APK"
adb uninstall "$APP" >/dev/null
echo "::endgroup::"

# On failure, everything goes into lines that start with "error:", because that is what
# annotate-log.py shows on the run's page (run logs need a login; annotations do not).
describe_failure() {
    adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
    adb pull /sdcard/window.xml build/window.xml >/dev/null 2>&1 || true
    # annotate-log.py shows up to 20 distinct "error:" lines: 1 + 6 + 1 + 9 + 3.
    echo "error: journey failed ($1). The test said:"
    grep -E "Not found after|Expected:|Actual:|Exception|Error:|FAILED|failed" "build/drive-$language.log" \
        | grep -v "^error:" | tail -6 | sed 's/^/error:   test | /' || true
    echo "error:   (screen when it failed)"
    python3 scripts/describe-screen.py build/window.xml | head -9 | sed 's/^/error:   screen | /'
    adb logcat -d -t 300 | grep -iE "flutter|AndroidRuntime|FATAL" | tail -3 | sed 's/^/error:   log | /' || true
}

for language in en tr ar; do
    echo "::group::Journey in $language"
    # The journey checks it got the language this script set (ADR-0005).
    flutter build apk --profile --target=integration_test/journey_test.dart \
        --dart-define=EXPECTED_LANGUAGE="$language" > "build/build-$language.log" 2>&1 \
        || { tail -40 "build/build-$language.log"; exit 1; }
    out="docs/screenshots/android-$language"
    mkdir -p "$out"
    run_journey() {
        # A fresh start: no saved cities, no cache, no location permission, this language.
        adb install -r -t "$PROFILE_APK" >/dev/null
        adb shell pm clear "$APP"
        adb shell cmd locale set-app-locales "$APP" --locales "$language"
        adb logcat -c
        SCREENSHOT_DIR="$out" flutter drive -d "$DEVICE" --profile \
            --driver=test_driver/integration_test.dart --target=integration_test/journey_test.dart \
            --use-application-binary="$PROFILE_APK" 2>&1 | tee "build/drive-$language.log"
        return "${PIPESTATUS[0]}"
    }
    # The journey uses the real API over the runner's network. One retry absorbs a slow moment
    # there; the log says so, and two failures in a row still fail the build.
    if ! run_journey; then
        describe_failure "$language, first try" | sed 's/^error:/note:/'
        echo "Retrying the $language journey once (real network)."
        if ! run_journey; then
            describe_failure "$language, second try"
            exit 1
        fi
    fi
    ls "$out"
    echo "::endgroup::"
done
