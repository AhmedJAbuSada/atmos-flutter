# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 06 of 7 — Integration: connect the views to the real data

`step-06-integration` · [← Step 05](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-05-presentation-ui) · [Step 07 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-07-quality-release) · [All steps](docs/ROADMAP.md)

**What this step is.** The layers connected: Riverpod `Notifier` view models for Home, Cities and Settings, each with one `onEvent`; containers that give each view its state; a 300 ms debounced search and a 5-second Undo; the permission flow (explanation first, then the system dialog, then the app settings when the system will not ask again); typed `Navigator` routes; the composition root as `ProviderScope` overrides; a small platform channel for links and the language page (ADR-0017); and seven journey tests that run the real app with fakes, in Turkish, Arabic and English.

**Why it matters.** After this step the app works end to end, and the wiring the tests run is the wiring the app runs. It also shows how to test what is easy to get wrong: a `Future` cannot be cancelled, so late answers are ignored by number, and each guard was removed once to see its test fail (the first Home test did not, and was strengthened). Timers run in `testWidgets`' fake time, with no extra package.

**What you will find in this branch**

| Where | What |
|---|---|
| `packages/presentation/lib/src/view_models/` | Home, Cities and Settings as Notifiers |
| `packages/presentation/lib/src/providers.dart` | The injection points and the use cases |
| `lib/app/composition.dart` | The real graph, as ProviderScope overrides |
| `lib/app/routes.dart` | One typed function per screen |
| `test/journey_test.dart` | Seven journeys through the real app |

**How to study this step**

1. **Read the full guide:** [docs/steps/06-integration.md](docs/steps/06-integration.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 05](https://github.com/AhmedJAbuSada/atmos-flutter/compare/step-05-presentation-ui...step-06-integration).
3. **Run it:**
   ```bash
   flutter pub get
   tool/test_all.sh
   flutter run
   ```
4. **Try the exercise:** Delete `token != _generation ||` in `HomeViewModel._load` and run the view-model tests: which two fail, and what would the user see? Then change `CitiesViewModel.debounce` to 1 second and find the test that tells you.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** steps 01–06 of 7 are done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

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
| 06 | [`step-06-integration`](../../tree/step-06-integration) | Riverpod view models, navigation, permissions |
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
