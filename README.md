# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 01 of 7 — Planning: documents before code

`step-01-planning` · [Step 02 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-02-project-structure) · [All steps](docs/ROADMAP.md)

**What this step is.** There is **no code** in this branch, on purpose. This is the fourth codebase for the same product, so the requirements, user stories, wireframes, API contract and recorded samples are **shared** with the Android, iOS and React Native apps (same IDs, samples byte for byte), while the architecture, twelve ADRs, Dart standards and `AGENTS.md` are written **for Flutter**, each choice compared with the other three apps.

**Why it matters.** It shows how much of a product carries over to a new stack: the architecture stays the same and only the tools change (packages in a pub workspace instead of Gradle modules, Swift targets or ESLint boundaries; Riverpod Notifiers instead of ViewModels, `@Observable` classes or Zustand stores). It also shows why a tool's guarantee is tested before it is written down: a pub workspace does not, on its own, keep Flutter out of the domain.

**What you will find in this branch**

| Where | What |
|---|---|
| `docs/product/, docs/design/, docs/api/` | Shared with the other three apps: the same product |
| `docs/architecture/ARCHITECTURE.md` | Three layers as packages in a pub workspace |
| `docs/architecture/adr/` | Twelve decisions, each compared with the other apps |
| `docs/process/CODING_STANDARDS.md` | Dart and Flutter rules, and which tool checks each |
| `AGENTS.md, docs/AI_WORKFLOW.md` | How to work with an AI coding agent |

**How to study this step**

1. **Read the full guide:** [docs/steps/01-planning.md](docs/steps/01-planning.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **Read in this order:** PRD → user stories → API contract → architecture → ADRs → AGENTS.md.
3. **Try the exercise:** Read ADR-0001 here and its counterparts in the iOS and React Native repos. Which tool gives the strongest guarantee, and what does each one cost?

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** step 01 of 7 is done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

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
| 02 | `step-02-project-structure` | Flutter project, pub workspace, strict analysis, custom source rules, CI |
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
