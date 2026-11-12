# Step 01 — Planning: documents before code (Flutter)

**Branch:** `step-01-planning` · **Next:** [step 02, project structure](02-project-structure.md)

No code yet, on purpose. This is the fourth codebase for the same product
([Android](https://github.com/AhmedJAbuSada/atmos-android),
[iOS](https://github.com/AhmedJAbuSada/atmos-ios),
[React Native](https://github.com/AhmedJAbuSada/atmos-react-native)), so this step shows how a
team adds a second **cross-platform** app to a product that already exists, and how much of the
earlier work carries over.

## Shared vs platform-specific

| Shared (same product, same requirement IDs) | Written for Flutter |
|---|---|
| [PRD](../product/PRD.md), [user stories](../product/USER_STORIES.md), [wireframes](../design/WIREFRAMES.md) | [Architecture](../architecture/ARCHITECTURE.md): layers as packages in a pub workspace |
| [API contract](../api/API_CONTRACT.md) and the recorded [samples](../api/samples/), byte for byte | [Twelve ADRs](../architecture/adr/), each compared with the other three apps |
| [Git workflow](../process/GIT_WORKFLOW.md), [Definition of Done](../process/DEFINITION_OF_DONE.md) | [Coding standards](../process/CODING_STANDARDS.md), [AGENTS.md](../../AGENTS.md) |

Only three lines of the product documents changed: the platform list, NF-09 ("from one Dart
codebase") and the Turkish casing risk. The API contract changed one line (the User-Agent).

## One concept, five tools

| Concept | Android | iOS | React Native | Flutter |
|---|---|---|---|---|
| Enforce the layers | Gradle modules | Swift package targets | ESLint boundaries | Packages in a pub workspace + a lint at error + a custom check |
| View model | `ViewModel` + `StateFlow` | `@Observable` class | Zustand store | Riverpod `Notifier` |
| Dependency injection | Hilt | `AppContainer` | composition root + React Context | composition root + `ProviderScope` overrides |
| Errors as values | `AppResult` | typed throws | `Result` union | sealed `Result` + sealed `DomainError` |
| Networking | Retrofit | `URLSession` | `fetch` | `package:http` |
| Storage | Room, DataStore | JSON files, UserDefaults | AsyncStorage | shared_preferences |
| Translations | `strings.xml` | String Catalog | i18next | ARB + `gen-l10n` |
| End-to-end test | Compose UI test | XCUITest | Maestro | `integration_test` |

The architecture is the same in all four; only the tools change. That is the main lesson of
these repositories.

## Decisions made by the project owner

- **Riverpod** for state: `flutter_riverpod`, `Notifier` view models, one state per screen.
- English, Turkish and Arabic (RTL); the AI-written translations are marked as not reviewed.
- Errors are values; cancellation is never shown.
- The OS owns the app language: no in-app language picker.
- Arabic uses Latin digits, and every formatted value sits inside directional isolates.
- Turkish casing and `start`/`end` are enforced by tools, not by memory.

Everything else (http client, storage, location, navigation, testing, lints) was proposed by
the agent, one ADR each, for the owner to review with this step. Each picks the boring,
maintained option, usually the one the Dart or Flutter team maintains, and says when we would
switch.

## The trade-off of a cross-platform app

| ✅ Gains | ⚠️ Costs |
|---|---|
| One Dart codebase for Android and iOS | Two native host projects to keep up to date |
| Real packages: the domain runs with `dart test`, no engine | A workspace shares one resolution, so packages alone do not stop a stray import (ADR-0001) |
| Flutter draws every pixel: the same UI on both platforms | Platform conventions (back gesture, fonts, dialogs) need deliberate care |

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Copied the product docs and samples and changed only the platform facts | Chose Riverpod, the languages, the error model and the language rules |
| Looked up the current stable Flutter and the current package versions before choosing | Reviews the library choices in the ADRs |
| Tested what a pub workspace enforces in a scratch project before writing ADR-0001 | — |
| Wrote twelve ADRs comparing every choice with the other three apps | — |

Prompts: [docs/ai/prompts/step-01-planning.md](../ai/prompts/step-01-planning.md).

## What went wrong, and what we learned

1. **"Packages enforce the layers" was only half true.** The first draft of ADR-0001 said a
   pure-Dart domain package *cannot* import Flutter. A ten-minute experiment showed that inside
   a pub workspace, `import 'package:flutter/foundation.dart'` in the domain resolves (the
   analyzer only reports an *info*), and `import 'dart:ui'` resolves with no finding at all.
   The ADR now records the experiment and adds two guards. **Lesson:** test a tool's guarantee
   before you write it down; the same lesson the iOS and React Native repos learned in their
   own way.
2. **A shared document and an owner decision disagreed.** F-09 in the shared PRD lists a
   language setting, while the owner decided that the OS owns the language. Changing the
   shared PRD for one app would break "same product, same IDs", so the PRD stays as it is and
   ADR-0005 explains how F-09 is met: the Language row shows the language and opens the system
   page where it is changed. **Lesson:** when a shared spec and a platform decision meet, write
   down the mapping instead of quietly editing the spec.
3. **A rule did not port.** React Native's rule says "use `toLocaleUpperCase(locale)`". Dart has
   no such method: `toUpperCase()` ignores the locale entirely. The Flutter rule therefore bans
   the calls and plans one small locale-aware helper. **Lesson:** port the *intent* of a rule,
   not its wording.
4. **A name clash, caught in review.** The draft `DomainError` had a `Timeout` case;
   `package:test` also exports `Timeout`, so every test file would have needed an import
   prefix. It is now `RequestTimeout`.

## Exercise for you
1. Read ADR-0001 here and in the iOS and React Native repos. Which tool gives the strongest
   guarantee, and what does each one cost?
2. F-09 lists a language setting. Write the acceptance test that proves the Flutter app meets
   it without an in-app picker.

## Checklist: is step 01 done?
- [x] Shared product documents, platform facts adapted; samples byte for byte
- [x] Architecture and twelve ADRs
- [x] Coding standards, Definition of Done, PR and issue templates
- [x] `AGENTS.md`, `CLAUDE.md`, `AI_WORKFLOW.md`
- [x] `PROGRESS.md` updated
