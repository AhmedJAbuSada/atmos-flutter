# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 03 of 7 — Domain layer: the business rules, in plain code

`step-03-domain-layer` · [← Step 02](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-02-project-structure) · [Step 04 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-04-data-layer) · [All steps](docs/ROADMAP.md)

**What this step is.** The business rules in pure Dart, in `packages/domain`: a sealed `Result` and `DomainError` (with `Cancelled`), valid-only `Coordinates` (a private constructor and a factory that returns `null`), units as extension types, cities and places, the WMO code table as one switch expression, the forecast entities, the cache-first `GetForecast` with its decision table, the city use cases, shared fakes in `testing.dart`, and 83 tests that run with `dart test` in about a second, with a 90% coverage gate (99.3%).

**Why it matters.** The same rules as the Android, iOS and React Native domains; comparing the four shows what is architecture (identical) and what is language (sealed classes and exhaustive switches, extension types, callable classes, streams). Two decisions are new to Flutter: Dart's core has no time-zone database, so ADR-0015 reads local times with the API's UTC offset and states the daylight-saving limitation; and the coverage gate needs no dependency (ADR-0014).

**What you will find in this branch**

| Where | What |
|---|---|
| `packages/domain/lib/src/weather/get_forecast.dart` | The cache-first decision table |
| `packages/domain/lib/src/common/` | Result, DomainError, DateProvider, ValueStore |
| `packages/domain/lib/testing.dart` | Fakes for every package's tests |
| `tool/source_rules/lib/src/coverage.dart` | The coverage gate, with no dependency |
| `docs/architecture/adr/0015-local-times-with-the-utc-offset.md` | Local times without a time-zone database |

**How to study this step**

1. **Read the full guide:** [docs/steps/03-domain-layer.md](docs/steps/03-domain-layer.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 02](https://github.com/AhmedJAbuSada/atmos-flutter/compare/step-02-project-structure...step-03-domain-layer).
3. **Run it:**
   ```bash
   flutter pub get
   cd packages/domain && dart test
   cd ../.. && tool/test_all.sh
   ```
4. **Try the exercise:** Add a new case to `DomainError` and run `dart analyze`: every exhaustive switch that must handle it stops compiling. Then move the `Cancelled` arm in `GetForecast` below the `when cached != null` arm and see which test fails.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** steps 01–03 of 7 are done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

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
| 03 | [`step-03-domain-layer`](../../tree/step-03-domain-layer) | Entities, use cases, sealed `Result` errors |
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
