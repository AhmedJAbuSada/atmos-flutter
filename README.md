# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 05 of 7 — Presentation: the views, before any data

`step-05-presentation-ui` · [← Step 04](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-04-data-layer) · [Step 06 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-06-integration) · [All steps](docs/ROADMAP.md)

**What this step is.** The four screens as views of a sealed state, in `packages/presentation`: Home (loading skeleton, "where are you?", error with retry, the forecast with 24 hours, 7 days and "Updated 2 hours ago"), Cities (search, results, saved places, remove with Undo), Settings (units, theme, the Language row that opens the system page) and About. Strings in ARB for gen-l10n in English, Turkish and Arabic, with Arabic's six plural forms, marked as AI-written and not reviewed; an `intl` formatter with directional isolates and Latin digits; light and dark tokens with a WCAG contrast test; 128 widget tests, every state in all three languages.

**Why it matters.** A view that can only show what it is given can be built, tested and reviewed on its own, in every language and theme, before any data exists. The step also shows two places where the toolchain needed care: Flutter 3.50's gen-l10n still writes deprecated delegates next to `material_ui` (ADR-0016), and Flutter's default locale resolution would show English to a user who ranked Turkish first, so the app resolves the language the way the other three apps do.

**What you will find in this branch**

| Where | What |
|---|---|
| `packages/presentation/lib/src/l10n/arb/` | The strings in en, tr and ar |
| `packages/presentation/lib/src/formatting/weather_formatter.dart` | Isolates, Latin digits, times at the place |
| `packages/presentation/lib/src/home/home_view.dart` | Every Home state, one switch |
| `packages/presentation/test/` | 128 tests in three languages, dark mode, 200% text |
| `docs/architecture/adr/0016-generated-localizations-with-material-ui.md` | gen-l10n next to material_ui |

**How to study this step**

1. **Read the full guide:** [docs/steps/05-presentation-ui.md](docs/steps/05-presentation-ui.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 04](https://github.com/AhmedJAbuSada/atmos-flutter/compare/step-04-data-layer...step-05-presentation-ui).
3. **Run it:**
   ```bash
   flutter pub get
   cd packages/presentation && flutter test
   cd ../.. && flutter run
   ```
4. **Try the exercise:** Remove the `isolate(...)` call from `WeatherFormatter.temperature` and run the tests: which ones fail? Then set your phone's app language to Arabic and look at "Feels like" on Home.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** steps 01–05 of 7 are done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

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
| 04 | [`step-04-data-layer`](../../tree/step-04-data-layer) | `package:http` + DTOs, mappers, shared_preferences, geolocator |
| 05 | [`step-05-presentation-ui`](../../tree/step-05-presentation-ui) | Screens as stateless views, theme, gen-l10n, RTL |
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
