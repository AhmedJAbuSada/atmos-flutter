# ADR-0013: Material widgets from the `material_ui` package

- **Status:** Accepted (adds to ADR-0003, which chose Material 3 but not where it comes from)
- **Date:** 2026-11-12
- **Approved:** by the project owner on 2026-11-12, as written (status note added in step 03)

## Context
Step 02 generated the project with Flutter 3.50.0. Its template no longer imports
`package:flutter/material.dart`: that library is **deprecated** ("Use
package:material_ui/material_ui.dart instead. This feature was deprecated after
v3.47.0-0.0.pre."). Material now ships as [`material_ui`](https://pub.dev/packages/material_ui),
published by flutter.dev, and the template adds it to `pubspec.yaml`. We found this when we
generated the project; it was not known when step 01 was written.

## Decision
- `atmos_presentation` and the app import Material from `package:material_ui/material_ui.dart`.
  It is the only way to use Material without a deprecation warning, and CI treats every
  analyzer finding as an error (ADR-0012).
- `cupertino_icons`, also added by the template, is **removed**: the app uses Material icons
  only (`uses-material-design: true`), so we do not carry a dependency we do not use.
- `material_ui` is a UI package: `atmos_domain` and `atmos_data` must not import it, and
  `tool/source_rules` checks that.

## Alternatives considered
| Option | Why not |
|---|---|
| Keep `package:flutter/material.dart` | Deprecated; every import would be an analyzer finding, and the library will be removed. |
| Widgets only (`package:flutter/widgets.dart`), our own components | Material 3 gives accessible, RTL-aware components and the wireframes assume them (ADR-0003). |

## Consequences
- ✅ The project matches the current template and has no deprecated imports.
- ⚠️ Material now has its own version, upgraded with `flutter pub upgrade` like any package,
  separately from the SDK.
- ⚠️ Some packages may still import the old library. Step 05 must check that
  `flutter_localizations` and Riverpod work with `material_ui` without deprecation findings
  in **our** code.
