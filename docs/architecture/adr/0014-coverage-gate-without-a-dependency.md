# ADR-0014: A coverage gate with no new dependency

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
NF-05 asks for ≥ 80% line coverage of domain and data; like the other apps we hold the
domain to **90%** and the data layer to **85%** (React Native's thresholds), and CI must fail
below them. The project owner allowed a small **dev-only** package for reading lcov reports.
Android uses Kover, iOS `xccov` with a script, React Native Jest's `coverageThreshold`.

## Decision
- `dart test --coverage-path=coverage/lcov.info` (pure-Dart packages) and
  `flutter test --coverage` (Flutter packages) already write lcov reports; both come with the
  SDK and `package:test`.
- The gate is ~30 lines in `tool/source_rules` (`lineCoverage`, with tests) and an executable:
  `dart run atmos_source_rules:coverage_gate <lcov> <minimum> <label>`. It sums `LF`/`LH`,
  prints `error: [coverage] …` below the minimum (so CI annotates it) and exits with 1. An
  empty or missing report fails too.
- `tool/test_all.sh` runs it for `atmos_domain` (90%) and, from step 04, `atmos_data` (85%).
- No lines are excluded. The shared fakes in `atmos_domain/testing.dart` count; the tests use
  them, so they are covered.
- So the allowed dev package is **not needed**; the permission stays unused.

## Alternatives considered
| Option | Why not |
|---|---|
| `package:coverage` directly (`format_coverage`) | Already a transitive dependency of `package:test`; `--coverage-path` gives the same lcov in one flag. |
| A third-party lcov parser | Allowed by the owner, but summing two record types does not need one. |
| A coverage service (Codecov) | An account and a token for a number CI can compute itself. |

## Consequences
- ✅ No new dependency; the gate has its own tests and fails with an annotation.
- ⚠️ Line coverage only, like the other apps; branch coverage (`--branch-coverage`) is
  possible later.
- ⚠️ `--coverage-path` implies `--debug`, so covered test runs are a little slower.
