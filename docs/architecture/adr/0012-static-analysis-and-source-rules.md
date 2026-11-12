# ADR-0012: Static analysis — strict analyzer, `flutter_lints`, and a custom source check

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Rules a machine can check should be checked by a machine. Some of ours have no built-in lint:
- Dart's `toUpperCase()`/`toLowerCase()` take **no locale** (ADR-0005), so the Turkish `i` rule
  must ban the calls themselves.
- `left`/`right` in layouts (`EdgeInsets.only(left: …)`, `Alignment.centerLeft`,
  `TextAlign.right`) do not mirror in Arabic.
- The workspace resolves `dart:ui` inside the domain (ADR-0001).

Android uses ktlint, Android Lint and a custom Gradle casing task; iOS SwiftLint custom rules;
React Native ESLint rules.

## Decision
1. **Analyzer:** `strict-casts`, `strict-inference`, `strict-raw-types`;
   `package:flutter_lints/flutter.yaml` plus an explicit list of extra rules in the root
   `analysis_options.yaml`, which every package shares. `depend_on_referenced_packages` is an
   error. CI runs `dart analyze --fatal-infos`, so any finding fails the build.
2. **Formatting:** `dart format`; CI fails if a file is not formatted.
3. **`tool/source_rules`:** a small pure-Dart package in the workspace, with its own tests. It
   scans the Dart sources and fails with `file:line:col: error: [rule] message` for:
   - `layer-imports`: the allowed imports per layer (ADR-0001);
   - `locale-casing`: any `toUpperCase(` / `toLowerCase(`;
   - `start-end`: `left`/`right` named arguments, `Alignment.*Left|Right`,
     `TextAlign.left|right`, `EdgeInsets.fromLTRB`.

   There are **no ignore comments**. The one locale-aware casing helper (ADR-0005) will be the
   only allow-listed file, named in the check's source, so adding an exception is a reviewed
   change.

## Alternatives considered
| Option | Why not |
|---|---|
| `very_good_analysis` | A strong rule set, but opinionated and third-party; `flutter_lints` plus a short, explained list is easier to read and to change. |
| `custom_lint` | Rules in the IDE as you type, but a dependency and a plugin runtime for three text-level rules. |
| The analyzer plugin API (`analysis_server_plugin`) | The official future for custom rules, still young; worth a new ADR when it is boring. |
| `grep` in a CI step | No tests, no clear messages, and it breaks on the first refactor. |

## Consequences
- ✅ The casing, direction and layer rules fail CI with a message that names the rule.
- ✅ The checker has tests, including the violations it must catch.
- ⚠️ The check reads source text, not the syntax tree: a rule word inside a string literal
  would be a false positive. Rare in practice; fix the code or improve the rule, never skip it.
- ⚠️ The check runs in CI and in a terminal, not in the IDE.
