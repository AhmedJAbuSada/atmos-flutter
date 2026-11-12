# ADR-0004: Dependency injection — one composition root, Riverpod overrides

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Android uses Hilt, iOS a hand-written `AppContainer`, React Native a composition root handed
down by React Context. Flutter already has a dependency container in the stack we chose:
Riverpod providers (ADR-0003).

## Decision
- `atmos_presentation` declares a provider for each domain interface or use case a view model
  needs. Without an override, such a provider throws a clear "not provided" error.
- The app (`lib/`) is the **composition root**: it creates the real `atmos_data`
  implementations once and passes them to the root `ProviderScope(overrides: [...])`.
- Tests override the same providers with fakes. Nothing imports a global singleton.
- The domain and data layers do not know Riverpod: their classes take their dependencies
  through constructors.

## Alternatives considered
| Option | Why not |
|---|---|
| `get_it` (service locator) | A global registry; dependencies become invisible at the call site, and a second container next to Riverpod. |
| `injectable` | Code generation on top of `get_it`. |
| Constructor injection only, passed down the widget tree | Works for a few screens, but every widget in between must carry objects it does not use. |

## Consequences
- ✅ One place shows how the app is wired.
- ✅ Tests pass fakes by overriding providers; no global state to reset.
- ✅ The same idea as iOS's `AppContainer` and RN's composition root.
- ⚠️ A provider that is never overridden fails at runtime, not at compile time; a test of the
  composition root covers it.
