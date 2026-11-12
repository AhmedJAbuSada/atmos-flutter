# Step 02 — Project structure: make the architecture a rule (Flutter)

**Branch:** `step-02-project-structure` · **Previous:** [step 01](01-planning.md) · **Next:** [step 03, domain layer](03-domain-layer.md)

The Flutter project, with the three layers in place as packages and **tools that enforce
them** before any feature exists.

## What this step adds

```
atmos-flutter/
├── pubspec.yaml               ← the app (package atmos) + the workspace root
├── lib/
│   ├── main.dart              ← runApp(AtmosApp())
│   └── app/                   ← AtmosApp + composition.dart (the composition root)
├── android/, ios/             ← the native host projects (dev.ahmedabusada.atmos.flutter)
├── packages/
│   ├── domain/                ← atmos_domain: pure Dart, no dependencies, `dart test`
│   ├── data/                  ← atmos_data: depends on the domain only
│   └── presentation/          ← atmos_presentation: the placeholder screen for now
├── tool/
│   ├── source_rules/          ← the custom checks: layers, casing, start/end (+ 15 tests)
│   └── test_all.sh            ← runs the tests of every package
├── analysis_options.yaml      ← strict analyzer + lints, shared by every package
├── scripts/annotate-log.py    ← turns build logs into CI annotations
└── .github/workflows/ci.yml   ← checks, Android build, iOS build
```

Built with **Flutter 3.50.0 (stable), Dart 3.14.0**. CI pins the same version.

## Key ideas

### 1. Packages, and what they really guarantee
Each layer is a package with its own `pubspec.yaml`, in one **pub workspace** (ADR-0001). The
domain declares no dependencies at all. Step 01 found, in a scratch project, that a workspace
shares one resolution, so a package can still *resolve* what another package uses. Here is the
real output when every rule is broken on purpose (a `leak.dart` in each layer):

```dart
// packages/domain/lib/src/leak.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';

const bool debug = kDebugMode;
const Color red = Color(0xFFFF0000);   // dart:ui works in the "pure Dart" domain
final int code = jsonDecode('3');      // an implicit cast from dynamic
String shout(String city) => city.toUpperCase();
```

```
$ dart analyze --fatal-infos
  error - packages/data/lib/src/leak.dart:1:8 - The imported package 'material_ui' isn't a dependency of the importing package. … - depend_on_referenced_packages
  error - packages/domain/lib/src/leak.dart:4:8 - The imported package 'flutter' isn't a dependency of the importing package. … - depend_on_referenced_packages
  error - packages/domain/lib/src/leak.dart:8:18 - A value of type 'dynamic' can't be assigned to a variable of type 'int'. … - invalid_assignment
  error - packages/presentation/lib/src/leak.dart:1:8 - The imported package 'atmos_data' isn't a dependency of the importing package. … - depend_on_referenced_packages
```

`depend_on_referenced_packages` is only an *info* by default; `analysis_options.yaml` raises it
to an error. `strict-casts` turns the silent `jsonDecode` cast into an error. But look at what is
**missing**: `import 'dart:ui'` in the domain, and `Color` from it, compile without a single
finding. Only the custom check sees it:

```
$ dart run atmos_source_rules
packages/data/lib/src/leak.dart:1:1: error: [layer-imports] atmos_data must not import 'package:material_ui/material_ui.dart': data knows the domain only (ADR-0001).
packages/domain/lib/src/leak.dart:2:1: error: [layer-imports] atmos_domain is pure Dart: it may import only core Dart libraries and itself, not 'dart:ui' (ADR-0001).
packages/domain/lib/src/leak.dart:4:1: error: [layer-imports] atmos_domain is pure Dart: it may import only core Dart libraries and itself, not 'package:flutter/foundation.dart' (ADR-0001).
packages/domain/lib/src/leak.dart:9:35: error: [locale-casing] Dart's toUpperCase()/toLowerCase() ignore the locale: Turkish 'i' must become 'İ'. Use the locale-aware helper (ADR-0005).
packages/presentation/lib/src/leak.dart:1:1: error: [layer-imports] atmos_presentation must not import 'package:atmos_data/atmos_data.dart': it talks to the domain, never to data sources (ADR-0001).
packages/presentation/lib/src/leak.dart:5:56: error: [start-end] 'left' does not mirror in Arabic. Use start/end: EdgeInsetsDirectional, AlignmentDirectional, PositionedDirectional, BorderRadiusDirectional, TextAlign.start (ADR-0005).
packages/presentation/lib/src/leak.dart:6:24: error: [start-end] 'Alignment.centerLeft' does not mirror in Arabic. Use start/end: … (ADR-0005).
Source rules: 7 problem(s) in 15 files.
```

There is a third, late guard: a domain *test* that loads the leaking file fails with
`Dart library 'dart:ui' is not available on this platform`, because `dart test` runs on the
plain Dart VM. It only fires if a test happens to import that file, so it is a bonus, not the
guard. **Lesson (again, after iOS and React Native):** know what each tool guarantees, and
cover the gaps.

### 2. A checker of our own, with tests
Dart's `toUpperCase()` has no locale parameter, and no built-in lint knows about `left`/`right`
in Flutter layouts. `tool/source_rules` is a small pure-Dart package (ADR-0012):
- It blanks out comments and the text of string literals first (but keeps code inside
  `'${…}'`), so a rule word in a comment is not an error, and `'${name.toUpperCase()}'` is.
- The `start-end` rule looks for `left:`/`right:` (and `topLeft:` …) named arguments only after
  `(` or `,`, so `isRtl ? left : right` is not flagged.
- It prints `file:line:column: error: [rule] message`, the format of a compiler, so CI
  annotates each line.
- It has **no ignore comment**. The only exception mechanism is an allow-list in its source, for
  the one locale-aware casing helper of step 05: an exception is a reviewed change.

Its 15 tests include every violation it must catch and the look-alikes it must not.

### 3. Strict analysis, shared by every package
One `analysis_options.yaml` at the root applies to the whole workspace: `strict-casts`,
`strict-inference`, `strict-raw-types`, `flutter_lints` and an explicit list of extra rules
(async mistakes, catches without `on`, immutability). CI runs `dart analyze --fatal-infos`, so
an *info* fails the build too. `dart format` owns the layout at 100 columns; that is why the
fixed-80 `lines_longer_than_80_chars` and `require_trailing_commas` (which fights the
formatter's tall style) are not in the list. A badly formatted file fails CI:

```
$ dart format --output=none --set-exit-if-changed .
Changed lib/leak_format.dart
Formatted 20 files (1 changed) in 0.08 seconds.
```

### 4. What the 3.50 template changed
- `package:flutter/material.dart` is **deprecated** in Flutter 3.50; the template imports
  Material from the `material_ui` package (flutter.dev). We kept it and recorded it in
  ADR-0013, and removed the unused `cupertino_icons`.
- iOS plugins use **Swift Package Manager**: there is no Podfile, so CI needs no `pod install`.
- Ids and minimum versions: `dev.ahmedabusada.atmos.flutter` on both platforms, Android 8.0
  (`minSdk = 26`) and iOS 17 (NF-09).

### 5. One resolution means shared pins
`flutter_test` pins `test_api` to the SDK's version. The domain's `test` dev dependency must
match it (`^1.32.0`, not the newest `^1.33.0`): in a workspace, one package's constraint
limits all of them. The comment in `packages/domain/pubspec.yaml` says why.

### 6. CI on three machines

| Job | Runs on | Proves |
|---|---|---|
| Format, analyze, source rules and tests | Linux | Formatting, types, lints, layers, casing, start/end, every package's tests |
| Android build | Linux | `flutter build apk --debug` |
| iOS build | macOS | `flutter build ios --debug --no-codesign` |

The builds run only after the fast checks pass. Every failing step prints its log and turns it
into annotations with `scripts/annotate-log.py`, the script the iOS repo wrote and the React
Native repo reused.

## Run it yourself

```bash
git switch step-02-project-structure
flutter pub get                    # resolves the whole workspace
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run atmos_source_rules
tool/test_all.sh
flutter run                        # on an emulator, a simulator or a device
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Installed the current stable Flutter (3.50.0) and generated the project with the official template | Reviews the folder layout and the ids |
| Noticed the template's new `material_ui` dependency and wrote ADR-0013 instead of adding it silently | Reviews ADR-0013 |
| Wrote `tool/source_rules` and its tests, then broke every rule on purpose and captured the errors | — |
| Reused the annotation script from the React Native repo | — |

What ran where: format, analyze, the source rules and all tests (21 in five packages) ran in
the Linux cloud session, and an Android debug APK was built there as well. **The iOS build was
not run locally** (there is no Mac); only the macOS CI job proves it.

**What went wrong, and what we learned**
1. **The first `flutter pub get` failed.** The domain asked for the newest `test` (`^1.33.0`),
   but `flutter_test` in another package pins `test_api` to an older version, and a workspace
   has one resolution. The fix was to let pub choose (`flutter pub add dev:test` gave
   `^1.32.0`) and to write down why. **Lesson:** in a workspace, a version is a decision for
   all packages at once.
2. **A wrong test, not wrong code.** One masking test failed; the expected string in the test
   had five spaces where ` e */ ` has six. The agent checked by counting before touching the
   code, then fixed the test. **Lesson:** when a test fails, first ask which side is wrong.
3. **The first lint list fought the formatter.** It included `lines_longer_than_80_chars` and
   `require_trailing_commas`, which gave dozens of findings on freshly formatted code. They were taken
   out *before* the first commit, in favour of the formatter's own `page_width: 100`, and the
   reason is a comment in `analysis_options.yaml`. That is choosing a tool, not disabling a
   rule to pass: no finding was silenced.
4. **The plan said "Material 3 widgets"** but did not know where Material would come from in
   3.50. Generating the project first showed it. **Lesson:** generate, then read the template's
   diff before writing about it.

## Checklist: is step 02 done?
- [x] Flutter 3.50.0 project for Android and iOS, ids and minimum OS versions set
- [x] Four packages in a workspace; the domain has no dependencies
- [x] Strict analysis; layer, casing and start/end violations fail (proved)
- [x] Tests in every package; `dart format` clean
- [x] CI: checks, Android build, iOS build, with failure annotations
- [x] Step guide and `PROGRESS.md` updated
