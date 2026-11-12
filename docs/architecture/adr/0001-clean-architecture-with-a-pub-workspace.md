# ADR-0001: Clean Architecture enforced by packages in a pub workspace

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
The layers must be enforced by a tool, not by memory. Android uses Gradle modules, iOS uses
Swift package targets, React Native uses ESLint boundaries on folders. Dart has real packages
with their own `pubspec.yaml`, and since Dart 3.6 **pub workspaces**: several packages in one
repository that share one resolution and one `pubspec.lock`.

We tested both setups before deciding (step 01, a scratch project with Flutter 3.50):

| Setup | `import 'package:flutter/foundation.dart'` in the domain | `import 'dart:ui'` in the domain |
|---|---|---|
| Separate packages, each with its own resolution | `uri_does_not_exist` **error** | `uri_does_not_exist` **error** |
| Packages in one workspace | only the lint `depend_on_referenced_packages` (an *info*) | **nothing**: it resolves |

## Decision
- Four packages in one workspace: `packages/domain` (`atmos_domain`, pure Dart, no
  dependencies), `packages/data` (`atmos_data`), `packages/presentation`
  (`atmos_presentation`), and the app at the root (`atmos`, the workspace root and
  composition root).
- `depend_on_referenced_packages` is raised to **error** in `analysis_options.yaml`, so an
  import of an undeclared package fails `dart analyze`.
- A small custom check, `tool/source_rules` (ADR-0012), lists the allowed imports per layer and
  catches what a pubspec cannot express: `dart:ui` and `dart:io` in the domain, widgets in
  data, data packages in presentation.

## Alternatives considered
| Option | Why not |
|---|---|
| Folders in one package, rely on review | Nothing stops a stray import. |
| Folders in one package + an import-checking script only | Works, but throws away what Dart already gives us: per-package dependencies and `dart test` on a pure-Dart domain. |
| Separate packages with `path:` dependencies, no workspace | The strongest guarantee (hard compile errors), but one `pub get`, one lock file and one set of versions per package; they drift. |
| Melos | A good monorepo tool, but a dependency for what the workspace and a loop in CI already do. |
| `custom_lint` / an analyzer plugin with import rules | More moving parts than a 150-line script; see ADR-0012. |

## Consequences
- ✅ The domain package declares no dependencies and runs with `dart test`, no Flutter engine.
- ✅ One `flutter pub get`, one lock file, one `dart analyze` for the whole repository.
- ✅ A wrong import fails CI, from the analyzer or from the check, with a message naming the rule.
- ⚠️ The boundary is a lint at error level plus a script, not a resolution error; both must run
  in CI (they do), and locally before a push.
- ⚠️ Tests run per package (a loop in CI).
- The same lesson as iOS (Swift packages could not stop `import SwiftUI`) and React Native
  (`boundaries` could not see npm packages): **know what each tool guarantees, and cover the
  gaps.**
