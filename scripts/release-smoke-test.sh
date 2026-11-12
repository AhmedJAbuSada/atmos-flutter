#!/usr/bin/env bash
# Installs the real release APK (R8, obfuscated Dart), starts it, and checks it is still running
# after 15 seconds with no crash in the log. The journey runs in profile mode (ADR-0018), so this
# is the test that sees what only the release build has: shrunk Java/Kotlin and obfuscated Dart.
#
# usage: release-smoke-test.sh <release apk>
set -euo pipefail

APP=dev.ahmedabusada.atmos.flutter
APK=$1

adb install -r "$APK"
adb shell pm clear "$APP"
adb shell cmd locale set-app-locales "$APP" --locales en
adb logcat -c
adb shell am start -W -n "$APP/.MainActivity"
sleep 15

pid=$(adb shell pidof "$APP" | tr -d '\r' || true)
crash=$(adb logcat -d | grep -E "FATAL EXCEPTION|Process: $APP|E/flutter" | head -20 || true)
adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
adb pull /sdcard/window.xml build/release-window.xml >/dev/null 2>&1 || true

if [ -z "$pid" ] || [ -n "$crash" ]; then
    echo "error: the release build is not running 15 s after start (pid: '${pid}')."
    echo "$crash"
    echo "Screen:"
    python3 scripts/describe-screen.py build/release-window.xml | head -20
    exit 1
fi
echo "Release build still running after 15 s (pid $pid). On screen:"
python3 scripts/describe-screen.py build/release-window.xml | head -10
