#!/usr/bin/env bash
# Runs the tests of every package in the workspace (ADR-0001, ADR-0011), and the coverage
# gate where a package has one (ADR-0014).
#
# Pure-Dart packages run with `dart test` (no Flutter engine), Flutter packages with
# `flutter test`. A package is pure Dart when its pubspec.yaml does not depend on the
# Flutter SDK. Stops at the first failing package.
set -euo pipefail
cd "$(dirname "$0")/.."

# run <package directory> [minimum line coverage, percent]
run() {
  local package=$1 minimum=${2:-}
  local flutter=false
  grep -q "sdk: flutter" "$package/pubspec.yaml" && flutter=true
  echo "── ${package}${minimum:+ (coverage ≥ ${minimum}%)}"
  (
    cd "$package"
    if $flutter; then
      flutter test ${minimum:+--coverage}
    else
      dart test ${minimum:+--coverage-path=coverage/lcov.info}
    fi
  )
  if [[ -n $minimum ]]; then
    dart run atmos_source_rules:coverage_gate "$package/coverage/lcov.info" "$minimum" "$package"
  fi
}

run packages/domain 90
run tool/source_rules
run packages/data 85
run packages/presentation
run .
