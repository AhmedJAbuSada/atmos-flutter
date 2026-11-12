# Atmos — Flutter

**A weather app for Android and iOS from one Dart codebase, built step by step as a public
tutorial on professional Flutter development with Clean Architecture and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 04 of 7 — Data layer: the app's backend on the phone

`step-04-data-layer` · [← Step 03](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-03-domain-layer) · [Step 05 →](https://github.com/AhmedJAbuSada/atmos-flutter/tree/step-05-presentation-ui) · [All steps](docs/ROADMAP.md)

**What this step is.** The data layer in `packages/data`: an Open-Meteo client on `package:http` with a 15-second timeout, abortable requests, an explicit UTF-8 decode and a retry decorator (network errors and 5xx, never 4xx or a cancellation; 1 s then 2 s); DTOs with every field nullable, parsed by hand; mappers tested on the recorded samples; local times read with the API's UTC offset (ADR-0015); the forecast cache (raw response + fetch time), saved cities and sanitized settings on `shared_preferences`; a location repository on `geolocator` that checks but never requests the permission; and a `DataModule` that hands out domain interfaces only. 76 tests, 92.5% line coverage.

**Why it matters.** It is the app's backend on the phone, and the place where the outside world is untrusted: a missing field, a value of the wrong type, a corrupt cache or a broken saved city must never crash the app. Every failure becomes a `DomainError` in one translation table, and no DTO leaves the package. Dart adds two lessons of its own: a `Future` cannot be cancelled, so requests are aborted with `abortTrigger`; and `http.Response` falls back to Latin-1, so the body is decoded as UTF-8 by hand.

**What you will find in this branch**

| Where | What |
|---|---|
| `packages/data/lib/src/remote/http_client.dart` | Timeout, abort, User-Agent, UTF-8, retries |
| `packages/data/lib/src/mappers/forecast_mapper.dart` | Parallel arrays to entities, safely |
| `packages/data/lib/src/repositories/` | Weather cache, saved cities, settings |
| `packages/data/lib/src/data_module.dart` | The front door: domain interfaces only |
| `packages/data/test/support/samples.dart` | Replays docs/api/samples, byte for byte |

**How to study this step**

1. **Read the full guide:** [docs/steps/04-data-layer.md](docs/steps/04-data-layer.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 03](https://github.com/AhmedJAbuSada/atmos-flutter/compare/step-03-domain-layer...step-04-data-layer).
3. **Run it:**
   ```bash
   flutter pub get
   cd packages/data && flutter test
   cd ../.. && tool/test_all.sh
   ```
4. **Try the exercise:** Remove the `on RequestCancelledException { rethrow; }` clause from `RetryingHttpClient` and run the tests: which one fails, and why would the user notice? Then store `{"temperatureUnit": "kelvin"}` in a test and check what the settings repository gives back.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-flutter).

---
<!-- step-banner:end -->

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.14%20strict-0175C2?logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** steps 01–04 of 7 are done. Follow along in [PROGRESS.md](docs/PROGRESS.md).

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
