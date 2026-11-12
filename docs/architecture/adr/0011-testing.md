# ADR-0011: Testing — `package:test`, `flutter_test`, `integration_test`, hand-written fakes

- **Status:** Accepted
- **Date:** 2026-11-12
- **Approved:** by the project owner on 2026-11-12, as written (status note added in step 03)

## Decision
- **`package:test`** for the pure-Dart domain, run with `dart test` (no Flutter engine).
- **`flutter_test`** (in the SDK) for data, view models and widgets: render each screen state
  and find it by text and semantics, the way a user and a screen reader would.
- **`integration_test`** (in the SDK) for the end-to-end journey on an Android emulator in CI,
  with the real API.
- **Fakes are hand-written** classes implementing the domain interfaces, shared from a testing
  library; no mocking framework.
- Network tests replay the recorded samples with `MockClient` (ADR-0007).

## Alternatives considered
| Option | Why not |
|---|---|
| `mockito` / `mocktail` | Fakes of small interfaces are short and readable; mocks verify calls instead of behaviour. `mockito` also needs code generation. |
| Maestro (the React Native choice) | YAML flows outside the app, very readable; but a separate tool to install, while `integration_test` ships with the SDK and uses the same finders as widget tests. |
| `patrol` | Adds native system dialogs (permissions) to tests; worth a new ADR if the journey needs them. |
| Golden (screenshot) tests in CI | Fonts render differently per OS; screenshots are a step 07 decision. |

## Consequences
- ✅ The same test pyramid as the other apps: many fast unit tests, one real journey.
- ✅ No test dependency outside the SDK except `package:test`.
- ⚠️ `integration_test` cannot tap the system permission dialog; the journey starts with the
  permission already decided (as in the other apps' journeys).
