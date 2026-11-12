# ADR-0010: Navigation — the SDK's `Navigator`, typed route functions

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Four screens (Home, Cities, Settings, About) in a stack, no deep links, no web URLs (both are
non-goals). Android uses Navigation Compose, iOS `NavigationStack`, React Native React
Navigation's native stack.

## Decision
The SDK's imperative **`Navigator`** with `MaterialPageRoute`. Each screen has one typed
function in the app (`openCities(context)`, `openSettings(context)`), so a route's arguments
are checked by the compiler and no string route names exist. Back gestures, the Android
predictive back animation and RTL-aware transitions come from the SDK.

## Alternatives considered
| Option | Why not |
|---|---|
| [`go_router`](https://pub.dev/packages/go_router) | The Flutter team's router, and the right choice once deep links or URLs matter; for four screens without either it adds a dependency and a URL layer we would not use. |
| `auto_route` | Code generation. |
| Navigator 2.0 (`Router`) by hand | Much more code for the same four screens. |

## Consequences
- ✅ No dependency; the simplest navigation that meets the stories.
- ⚠️ If deep links are added later, a new ADR moves to `go_router`; the typed functions keep
  that change in one place.
