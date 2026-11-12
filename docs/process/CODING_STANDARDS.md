# Coding standards (Dart / Flutter)

Rules a machine can check are checked by tools (set up in step 02). The rest are checked in
review.

## Tooling

| Tool | Checks | Runs |
|---|---|---|
| **Dart analyzer** (`strict-casts`, `strict-inference`, `strict-raw-types`) | Types, nulls, exhaustive `switch`, undeclared package imports | `dart analyze --fatal-infos` |
| **Lints** (`flutter_lints` + an explicit list in `analysis_options.yaml`) | Style, async mistakes, Flutter pitfalls | `dart analyze --fatal-infos` |
| **`tool/source_rules`** | Layer imports, locale-safe casing, `start`/`end` | `dart run atmos_source_rules` |
| **`dart format`** (100 columns) | Formatting | `dart format .` |
| **`dart test` / `flutter test`** | Behaviour | `tool/test_all.sh` (every package) |

All run in CI on every pull request. Any analyzer finding, including an *info*, fails the build.

## Naming

| Thing | Convention | Example |
|---|---|---|
| File | `snake_case.dart`, one main type per file | `get_forecast.dart`, `home_screen.dart` |
| Package | `atmos_<layer>` | `atmos_domain` |
| Type | `UpperCamelCase` | `ForecastSnapshot` |
| Use case | a verb phrase, a class with `call` | `GetForecast`, `SearchCities` |
| Repository | interface `NounRepository`, implementation `NounRepositoryImpl` (internal to data) | `WeatherRepository` |
| DTO | `NounDto` | `ForecastDto` |
| View model | `ScreenViewModel` (a `Notifier`), state `ScreenState` (sealed) | `HomeViewModel`, `HomeState` |
| Provider | `lowerCamelCase` + `Provider` | `homeViewModelProvider` |
| Test | `test('given X, when Y, then Z', …)` | `'given stale cache, when loading, then downloads'` |

## Dart rules
- Immutable by default: `final` fields, `final` locals, `const` constructors where possible.
- `final class` for entities and DTOs, `sealed class` for states and errors,
  `abstract interface class` for repositories.
- No `dynamic` outside JSON parsing in `atmos_data`; no implicit casts (`strict-casts`).
- No null assertion `!` outside tests: handle the `null` (pattern matching, `??`, early return).
- An exhaustive `switch` over a sealed class, with no `default`, so a new case is a compile error.
- Never `throw` across a layer boundary: return a `Result` (ADR-0006). Catch specific types
  (`on SocketException`), and always handle cancellation as `Cancelled`.
- **Never** `toUpperCase()`/`toLowerCase()`: Dart's versions ignore the locale (Turkish `i`).
  Use the locale-aware helper (ADR-0005). Enforced by `tool/source_rules`.
- Inject a `DateProvider`; never `DateTime.now()` in logic.
- No magic numbers: `const cacheLifetime = Duration(minutes: 30);`.
- Every `Future` is awaited or explicitly passed to `unawaited(...)`.
- Public API of each package is exported from its main library file; everything else lives in
  `lib/src/`.

## Flutter rules
- Containers (`ConsumerWidget`) watch view models; views (`StatelessWidget`) take `state` and
  `onEvent` only and have a widget test for each state.
- `start`/`end`, never `left`/`right`: `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional`, `BorderRadiusDirectional`, `TextAlign.start`. Enforced by
  `tool/source_rules`.
- Every formatted value (temperature, wind, time, percentage) is wrapped in directional
  isolates by the formatter (ADR-0005).
- Every tappable widget has a semantic label when it has no text; minimum hit area 48 × 48 dp
  on Android and 44 × 44 pt on iOS (Material's default `kMinInteractiveDimension` is 48).
- Material comes from `package:material_ui/material_ui.dart` (ADR-0013); the old
  `package:flutter/material.dart` is deprecated.
- No inline user-facing strings: `AppLocalizations.of(context).next24Hours`. Brand names
  (`Atmos`, `Open-Meteo`) are the only exception.
- `const` widgets wherever possible; no logic in `build` beyond choosing what to show.
- Check `context.mounted` after an `await` before using the `BuildContext`.
