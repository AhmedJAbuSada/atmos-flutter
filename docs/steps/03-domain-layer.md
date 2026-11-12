# Step 03 — Domain layer: the business rules, in pure Dart

**Branch:** `step-03-domain-layer` · **Previous:** [step 02](02-project-structure.md) · **Next:** [step 04, data layer](04-data-layer.md)

The same rules as the [Android](https://github.com/AhmedJAbuSada/atmos-android/blob/step-03-domain-layer/docs/steps/03-domain-layer.md),
[iOS](https://github.com/AhmedJAbuSada/atmos-ios/blob/step-03-domain-layer/docs/steps/03-domain-layer.md)
and [React Native](https://github.com/AhmedJAbuSada/atmos-react-native/blob/step-03-domain-layer/docs/steps/03-domain-layer.md)
domains, written in pure Dart: no Flutter, no `dart:ui`, no package at all. They run with
`dart test` on the plain Dart VM: 83 tests in about a second, 99.3% of the lines covered.

## What this step adds

```
packages/domain/lib/
├── src/common/    result.dart, domain_error.dart, date_provider.dart, value_store.dart
├── src/settings/  units.dart (extension types), user_settings.dart
├── src/location/  coordinates.dart (valid-only), city.dart, repositories.dart, city_use_cases.dart
├── src/weather/   weather_condition.dart (WMO table), forecast.dart, get_forecast.dart
├── atmos_domain.dart   the public face of the domain
└── testing.dart        fakes for every package's tests (no lib/ may import it)
packages/domain/test/   83 tests; coverage gate 90%
tool/source_rules/      + the coverage gate and the "no fakes in production" rule
```

## Same rules, four languages

| Idea | Kotlin | Swift | TypeScript | Dart |
|---|---|---|---|---|
| Errors as values | `sealed interface AppResult` | `throws(DomainError)` | `{ok, value} \| {ok, error}` | `sealed class Result` (`Ok`, `Err`) |
| Error cases | `sealed interface DomainError` | `enum DomainError` | union of `{kind}` | `sealed class DomainError` + `final class`es |
| Valid coordinates only | `require` in `init` | failable `init?` | branded type + `makeCoordinates` | private constructor + `Coordinates.validated` → `null` |
| Units that cannot be mixed up | value classes | structs | `{celsius}` objects | **extension types** over `double` |
| Use case | class with `invoke` | struct with `callAsFunction` | factory returning a function | class with `call` |
| Observable value | `StateFlow` | `ValueStream` | `ValueStore.subscribe` | `ValueStore.watch()` → `Stream` |
| Shared fakes | Gradle test fixtures | `AtmosTesting` target | `src/testing` + a lint rule | `testing.dart` + a source rule |

## Key ideas

### 1. Sealed classes make the compiler check every case
```dart
return switch (await _repository.fetchForecast(coordinates)) {
  Ok(:final value) => Ok(ForecastSnapshot(value)),
  Err(error: Cancelled()) => const Err(Cancelled()),
  Err(:final error) when cached != null => Ok(ForecastSnapshot(cached, refreshError: error)),
  Err(:final error) => Err(error),
};
```
That is the whole decision table of `GetForecast`, in the same order as its documentation.
A `switch` over a sealed class has no `default`: add a `DomainError` and every switch that
must handle it stops compiling. The order matters, too: `Cancelled` comes **before** the "keep
the cache" arm, so a cancelled download is never hidden behind old data.

### 2. A private constructor instead of a brand
`Coordinates._` is private, so the only way to get coordinates is
`Coordinates.validated(lat, lon)`, which returns `null` for impossible values (latitude 999,
and `NaN`, because `NaN.abs() <= 90` is false). Every `Coordinates` in the app is valid.

### 3. Extension types: a unit you cannot mix up, for free
```dart
extension type const Temperature(double celsius) { double inUnit(TemperatureUnit unit) => … }
```
At run time a `Temperature` is a `double`, with no object to allocate. At compile time a
`WindSpeed`, or a bare `double`, cannot be passed where a `Temperature` is expected.

### 4. Use cases are callable classes
`GetForecast(repository: …, freshness: …)` reads like a constructor call; then
`getForecast(coordinates)` reads like a function, thanks to `call`. Its fields are private,
given through **private named parameters** (`required this._repository`): callers still
write `repository:`.

### 5. Streams instead of listeners
React Native's `ValueStore.subscribe(listener)` becomes `ValueStore.watch()`, a `Stream` that
starts with the current value. It is the type Riverpod and Flutter's `StreamBuilder`
understand, so step 06 needs no adapter. Cancelling the subscription is the "unsubscribe".

### 6. Values are values
Entities override `==` and `hashCode`, so tests compare whole objects and values work in sets
and as map keys. Lists inside entities use a five-line `listEquals`: the domain has **no
dependencies**, not even `package:collection`. `value_semantics_test.dart` checks the contract
for every type.

### 7. The time question, decided now (ADR-0015)
Dart's core libraries cannot convert a time in `Europe/Istanbul`: they know UTC and the
phone's own zone only. So `Forecast` carries the place's IANA name *and* the UTC offset the API
reported. Step 04 reads every local time with that offset, and the UI adds it back to show
local times. The shown times are always the API's own. **The limitation:** instants after a
daylight-saving change inside the 7-day window are one hour off. ADR-0015 explains when that
matters and when we would add the `timezone` package.

### 8. A coverage gate without a dependency (ADR-0014)
`dart test --coverage-path=coverage/lcov.info` writes an lcov report with no extra package.
A 30-line, tested function in `tool/source_rules` sums it, and the gate fails CI below 90%:

```
$ dart run atmos_source_rules:coverage_gate packages/domain/coverage/lcov.info 99.5 packages/domain
packages/domain/coverage/lcov.info:1:1: error: [coverage] packages/domain: 99.3% of lines (267/269), minimum 99.5%.
```

The owner had allowed a small dev package for this; it was not needed.

## Run it yourself

```bash
git switch step-03-domain-layer
flutter pub get
cd packages/domain && dart test          # 83 tests, no Flutter engine
cd ../.. && tool/test_all.sh             # every package, with the coverage gate
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Ported the React Native domain and its tests, idiom by idiom, keeping each test name | Approved the library ADRs before the step (recorded in AGENTS.md and the ADRs) |
| Chose extension types and private named parameters, and checked them with the analyzer | Allowed a dev package for coverage (not needed in the end) |
| Raised the time-zone question in step 03 rather than step 04, and wrote ADR-0015 | Reviews ADR-0015's trade-off |
| Split the work into commits that each compile and pass on their own | — |

**What went wrong, and what we learned**
1. **Coverage started at 84.8%.** The uncovered lines were `hashCode` and `toString`. Lowering
   the gate or excluding files would have been easy; instead `value_semantics_test.dart` tests
   the `==`/`hashCode` contract, which is real behaviour (sets, map keys, `expect`). Coverage
   rose to 99.3%. **Lesson:** read *which* lines are uncovered before deciding what to do.
2. **The agent's own test found a hole in its rule.** The first "no fakes in production" rule
   caught `package:atmos_domain/testing.dart` but allowed `import '../../testing.dart'` from
   inside the domain, and the test written for it asserted that this was fine. Reading the test
   again showed the assertion was wrong; the rule and the test were fixed together.
   **Lesson:** a test that encodes a gap is worse than no test; read what you assert.
3. **Two Dart scoping surprises.** A test-data value named `now` clashed with the `now()`
   method of the fake clock (renamed `testNow`); and inside an extension, the top-level
   `coordinates()` helper won over the implicit `this.coordinates`, a compile error until
   written as `this.coordinates`. Both were caught by the analyzer, not at run time.
4. **A switch expression did not type-check** in `GetCurrentLocationForecast`: one arm
   returned a `Future`, the other a `Result`. It became a `switch` statement with `return`s.

## Checklist: is step 03 done?
- [x] `Result`, `DomainError` (with `Cancelled`), `DateProvider`, `ValueStore`
- [x] Units, settings, coordinates, cities, places, city use cases (minimum query length 2)
- [x] WMO table, forecast entities, freshness, the cache-first `GetForecast` table
- [x] Shared fakes, protected by a source rule; coverage gate 90% (99.3%)
- [x] ADR-0014 and ADR-0015; step guide and `PROGRESS.md` updated
