# ADR-0016: Generated localizations, committed, next to `material_ui`

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
ADR-0005 chose ARB files and Flutter's `gen-l10n`; ADR-0013 took Material from `material_ui`,
because `package:flutter/material.dart` is deprecated in Flutter 3.50. Building step 05 showed
that the two do not fit together completely yet:
- `material_ui` ships its **own** `GlobalMaterialLocalizations` (its README: use
  `GlobalMaterialLocalizations.delegates` from `material_ui`).
- The code `gen-l10n` writes in Flutter 3.50 still lists `flutter_localizations`' old delegates in
  `AppLocalizations.localizationsDelegates`. Analysing that file gives two
  `deprecated_member_use` findings, and CI fails on every finding (ADR-0012).

## Decision
1. **We do not use the generated delegate list.** `atmos_presentation` exports its own:
   `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`, the second from
   `material_ui`.
2. **The one generated file with that list, `lib/src/l10n/app_localizations.dart`, is excluded
   from analysis**, by name, with the reason next to it in `analysis_options.yaml`. The
   per-language files (`app_localizations_en.dart`, `_tr`, `_ar`) are analysed like any other code.
   The excluded file still compiles in every test and build, so a real error in it still fails CI.
3. **The generated files are committed** (`l10n.yaml` writes them into `lib/src/l10n`, formatted
   with the project's width). A CI step runs `flutter gen-l10n` and fails if the result differs from
   what is committed, so the ARB files and the Dart code cannot drift apart.

## Alternatives considered
| Option | Why not |
|---|---|
| `// ignore_for_file:` through gen-l10n's `--header` | AGENTS.md forbids ignore comments; it would also hide *new* findings in the file. |
| Rewriting the generated file with a script | Brittle; breaks the day the template changes. |
| Hand-written localizations with `intl` | Loses the typed accessors and the ICU plural parsing that make gen-l10n worth having. |
| Not generating at build time, only committing | That is the decision, plus the CI check that keeps it honest. |

## Consequences
- ✅ No deprecated delegate is used; Material texts (back button, tooltips) are localized.
- ✅ A missing or renamed key is a compile error; the CI check catches a stale generated file.
- ⚠️ One generated file is not analysed. **Revisit** when a Flutter release updates the gen-l10n
  template: delete the exclusion and the CI check stays green, or it tells us what changed.
