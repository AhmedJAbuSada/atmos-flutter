# ADR-0003: Flutter with Material 3; view models as Riverpod Notifiers

- **Status:** Accepted
- **Date:** 2026-11-12
- **Approved:** by the project owner on 2026-11-12, as written (status note added in step 03)

## Context
We need a UI toolkit setup and a presentation pattern that are testable and comparable with
the `ViewModel` + `StateFlow` (Android), the `@Observable` view model (iOS) and the Zustand
store (React Native) of the other repos. The project owner chose **Riverpod**.

## Decision
- **Project:** a standard Flutter app for Android and iOS (`flutter create --platforms
  android,ios`), Material 3 widgets, with the native `android/` and `ios/` host projects in the
  repository. Flutter draws every pixel itself, so the same widgets render on both platforms.
- **View models:** [`flutter_riverpod`](https://riverpod.dev) 3, one **`Notifier`** per screen.
  Its state is **one sealed class** per screen (for example `HomeLoading`, `HomeContent`,
  `HomeError`), written by us, so the states match the other three apps one to one. The
  notifier receives its use cases through `ref` (ADR-0004) and exposes `onEvent`.
- **No code generation:** providers are written by hand (no `riverpod_generator`, no
  `build_runner`), so a reader sees everything that runs.
- **Screens:** a container (`ConsumerWidget`) watches the notifier; a view (`StatelessWidget`)
  takes `state` + `onEvent` only.
- Riverpod 3 retries a provider that *throws*; ours never throw (errors are values, ADR-0006),
  so retrying is an explicit user event (the "Try again" button), as in the other apps.

## Alternatives considered
| Option | Why not |
|---|---|
| `ChangeNotifier` / `ValueNotifier` from the SDK | No dependency, but no built-in way to provide and override dependencies; we would rebuild half of Riverpod by hand. |
| `provider` | Riverpod is its successor by the same author; `provider` depends on the widget tree, so view models are harder to test without widgets. |
| Bloc / Cubit | Excellent and popular; events-as-classes is more ceremony than one state per screen needs. The owner chose Riverpod. |
| `AsyncNotifier` with `AsyncValue` as the screen state | Convenient, but `AsyncValue` mixes errors in as exceptions; our states are explicit sealed classes, the same in all four apps. |
| `riverpod_generator` | Less boilerplate, but code generation hides what the tutorial wants to show. |

## Consequences
- ✅ The same "state in, events out" model as the other three apps.
- ✅ A notifier is tested with a `ProviderContainer`, overrides and fakes; no widget needed.
- ⚠️ Riverpod is a dependency of the presentation layer only; the domain never sees it.
- ⚠️ Hand-written providers mean a few more lines; we accept that for clarity.
