#!/usr/bin/env bash
# Runs the tests of every package in the workspace (ADR-0001, ADR-0011).
#
# Pure-Dart packages run with `dart test` (no Flutter engine), Flutter packages with
# `flutter test`. A package is pure Dart when its pubspec.yaml does not depend on the
# Flutter SDK. Stops at the first failing package.
set -euo pipefail
cd "$(dirname "$0")/.."

for package in packages/domain tool/source_rules packages/data packages/presentation .; do
  if grep -q "sdk: flutter" "$package/pubspec.yaml"; then
    runner=(flutter test)
  else
    runner=(dart test)
  fi
  echo "── ${package}: ${runner[*]}"
  (cd "$package" && "${runner[@]}")
done
