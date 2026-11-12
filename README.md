# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 02 of 7 — Project structure: the architecture as a compile-time rule

`step-02-project-structure` · [← Step 01](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-01-planning) · [Step 03 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-03-domain-layer) · [All steps](docs/ROADMAP.md)

**What this step is.** The Flutter 3.50 project for Android and iOS (`dev.ahmedabusada.atmos.flutter`, Android 8.0 and iOS 17 minimums), with one package per layer in a pub workspace (`atmos_domain` in pure Dart with no dependencies, `atmos_data`, `atmos_presentation`, and the app as the composition root), a strict `analysis_options.yaml` shared by every package, `tool/source_rules` (a tested checker for layer imports, Turkish casing and `start`/`end`), a test in every package, and CI that runs the checks, an Android build and an iOS build.

**Why it matters.** A pub workspace shares one resolution, so packages alone do not stop a stray import: `package:flutter` in the domain is only an info, and `dart:ui` passes with no finding at all. The lint `depend_on_referenced_packages` is raised to an error and a small custom check covers the rest. Every rule was broken once on purpose and the real errors are in the guide: know what each tool guarantees, and cover the gaps.

**What you will find in this branch**

| Where | What |
|---|---|
| `pubspec.yaml, packages/*/pubspec.yaml` | The workspace: one package per layer |
| `analysis_options.yaml` | Strict analyzer + lints, one file for every package |
| `tool/source_rules/` | Layer imports, locale-safe casing, start/end, with tests |
| `lib/app/composition.dart` | The composition root |
| `.github/workflows/ci.yml` | Checks, Android build, iOS build |

**How to study this step**

1. **Read the full guide:** [docs/steps/02-project-structure.md](docs/steps/02-project-structure.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 01](https://github.com/AhmedJAbuSada/atmos-flutter/compare/step-01-planning...step-02-project-structure).
3. **Run it:**
   ```bash
   flutter pub get
   dart format --output=none --set-exit-if-changed .
   dart analyze --fatal-infos
   dart run atmos_source_rules
   tool/test_all.sh
   flutter run
   ```
4. **Try the exercise:** Add `import 'dart:ui';` to a file in `packages/domain/lib` and run `dart analyze`, then `dart run atmos_source_rules`. Which one notices? Then write `EdgeInsets.only(left: 8)` in the placeholder screen.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** steps 01–02 of 7 are done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

## The same app on four platforms

| Platform | Repository | Status |
|---|---|---|
| Android (Kotlin, Compose) | [atmos-android](https://github.com/AhmedJAbuSada/atmos-android) | ✅ v1.0.0 |
| iOS (Swift, SwiftUI) | [atmos-ios](https://github.com/AhmedJAbuSada/atmos-ios) | ✅ v1.0.0 |
| React Native (TypeScript) | [atmos-react-native](https://github.com/AhmedJAbuSada/atmos-react-native) | 🚧 |
| **Flutter** (Dart) | you are here | 🚧 |

## The seven steps

| Step | Branch | What you learn |
|---|---|---|
| 01 | [`step-01-planning`](../../tree/step-01-planning) | Shared product docs, Flutter architecture, ADRs, AI agent rules |
| 02 | [`step-02-project-structure`](../../tree/step-02-project-structure) | Flutter project, pub workspace, strict analysis, custom source rules, CI |
| 03 | `step-03-domain-layer` | Entities, use cases, sealed `Result` errors |
| 04 | `step-04-data-layer` | `package:http` + DTOs, mappers, shared_preferences, geolocator |
| 05 | `step-05-presentation-ui` | Screens as stateless views, theme, gen-l10n, RTL |
| 06 | `step-06-integration` | Riverpod view models, navigation, permissions |
| 07 | `step-07-quality-release` | `integration_test` end to end, screenshots, release |

Full details: [ROADMAP.md](docs/ROADMAP.md).

## Features (v1.0)
Current weather at your location · 24 hours and 7 days · city search with names in your
language · saved cities · offline with the last data · °C/°F and wind units · dark mode ·
**English, Türkçe, العربية** (right to left). Weather data by
[Open-Meteo.com](https://open-meteo.com/); no API key needed.

> **Note on translations:** the Turkish and Arabic texts are written with an AI agent and have
> not yet been reviewed by a native speaker.

## 🤖 Built with an AI agent
[AI_WORKFLOW.md](docs/AI_WORKFLOW.md) · [AGENTS.md](AGENTS.md) ·
[docs/ai/prompts/](docs/ai/prompts/) · every step guide ends with *how the AI agent helped*.

## Author
**Ahmed J. AbuSada**, senior mobile and front-end developer ·
[@AhmedJAbuSada](https://github.com/AhmedJAbuSada)

## License
[MIT](LICENSE). Weather data © Open-Meteo.com, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
