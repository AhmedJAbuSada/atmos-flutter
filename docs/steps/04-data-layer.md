# Step 04 — Data layer: the app's backend on the phone (Flutter)

**Branch:** `step-04-data-layer` · **Previous:** [step 03](03-domain-layer.md) · **Next:** [step 05, presentation](05-presentation-ui.md)

`packages/data` implements the domain's repository interfaces: the Open-Meteo client, the
mappers, the cache, the saved cities, the settings and the location. It is a port of the
[React Native data layer](https://github.com/AhmedJAbuSada/atmos-react-native/blob/step-04-data-layer/docs/steps/04-data-layer.md),
on the three libraries the owner approved: `package:http`, `shared_preferences` and
`geolocator`. 76 tests replay the **recorded** samples from `docs/api/samples`; no test touches
the network. Line coverage is 92.5%, against an 85% gate.

## What this step adds

```
packages/data/lib/
├── atmos_data.dart          ← the public surface: DataModule + its inputs, no DTO, no repository
└── src/
    ├── remote/   http_client.dart (timeout, abort, retry), dtos.dart, json_reading.dart,
    │             open_meteo_api.dart, error_mapping.dart (the one translation table)
    ├── mappers/  local_time.dart (ADR-0015), forecast_mapper.dart, city_mapper.dart
    ├── local/    key_value_store.dart, shared_preferences_store.dart, cache_key.dart, stored_city.dart
    ├── location/ location_repository.dart, geolocator_location_platform.dart
    ├── repositories/  weather, city, settings
    └── data_module.dart     ← builds everything, hands out domain interfaces only
packages/data/test/          76 tests; support/samples.dart reads the samples byte for byte
lib/app/composition.dart     ← the app now creates the real data layer
```

## Same data layer, four stacks

| Concern | Android | iOS | React Native | Flutter |
|---|---|---|---|---|
| HTTP | Retrofit + OkHttp | `URLSession` | `fetch` | `package:http` |
| JSON | kotlinx.serialization | `Codable` | `JSON.parse` + optional fields | `jsonDecode` + hand-written readers |
| Cancel and timeout | coroutines, OkHttp timeouts | task cancellation | `AbortController` | abortable requests (`abortTrigger`) |
| Local times at a place | `java.time` | `TimeZone` | `Intl.DateTimeFormat` | the API's `utc_offset_seconds` (ADR-0015) |
| Storage | Room, DataStore | JSON files, UserDefaults | AsyncStorage | `SharedPreferencesAsync` |
| Location | FusedLocationProvider | CoreLocation | Geolocation + permissions | geolocator |
| Fake network in tests | MockWebServer | `URLProtocol` stub | a replaying `HttpClient` | a replaying `HttpClient` + `MockClient` |

## Key ideas

### 1. One interface for the network, decorated
`HttpClient` has one method, `get(url, {cancel})`. `PackageHttpClient` is the real one;
`RetryingHttpClient` wraps any `HttpClient` and adds the contract's retries. Tests replace the
real client with `ReplayingClient`, which answers with the recorded files and remembers each
URL, or wrap `package:http`'s own `MockClient` to test the real client.

The retry rules, one test each: a network error or a timeout or a 5xx is retried after 1 s,
then 2 s; a 4xx is not (our request is wrong); a cancellation is not (the user left); anything
else is passed on at once. The sleep is injected, so the tests take no time.

### 2. Abort, don't just stop listening
A Dart `Future` cannot be cancelled. `package:http` (1.5+) has **abortable requests**: the
request carries an `abortTrigger` future, and the client closes the connection when it
completes. Both the 15-second timeout and the caller's `cancel` complete that one trigger;
afterwards the client tells them apart and throws `RequestTimeoutException` or
`RequestCancelledException`, which become `RequestTimeout` and `Cancelled`.

To test the timeout, the fake server must behave like the real one. `MockClient`'s simple
constructor copies the request and **drops the trigger**, so the test uses
`MockClient.streaming`, which receives the original request and waits for its trigger.

### 3. Decode UTF-8 yourself
`http.Response` decodes the body with the charset from `Content-Type` and falls back to
**Latin-1** when there is none, which would turn `İstanbul` and `اسطنبول` into garbage. The
client reads the bytes and calls `utf8.decode` (JSON is UTF-8 by its RFC). A test sends the
recorded Arabic sample without a charset and expects `اسطنبول`.

### 4. Hand-written parsing, safely
`json_reading.dart` has five tiny readers (`readDouble`, `readInt`, `readString`,
`readList`, `readObject`) that return `null` instead of throwing for a value of the wrong
type. With `strict-casts`, every cast from `dynamic` is visible, and there is no
`as` that could throw. A list item of the wrong type becomes `null` **in its place**, so the
parallel arrays (`time[i]` ↔ `temperature_2m[i]`) stay aligned. Then the mapper's
collection-`for` with an `if-case` keeps only complete hours:

```dart
for (final (i, text) in (dto.time ?? const <String?>[]).indexed)
  if ((parseLocalTime(text, offset), _at(dto.temperature2m, i), _at(dto.weatherCode, i))
      case (final time?, final temperature?, final code?))
    HourlyForecast(…),
```

### 5. Local times without a time-zone database
`parseLocalTime("2026-11-11T10:15", 3 h)` gives 07:15 UTC. It also **refuses impossible
dates**: `DateTime.utc(2026, 2, 30)` silently becomes 2 March, so the function rebuilds the
date and compares every part. One test pins down the limitation ADR-0015 accepts: after a
daylight-saving change inside the forecast window, the instant is one hour off while the
displayed local time is still the API's own.

### 6. Corrupt data is no data
Every read from storage goes through `readJson`, which returns `null` for missing or unreadable
JSON. A cache entry without `raw` or `fetchedAt`, a `raw` that is not JSON, a forecast without
current conditions: each is "no cache", never a crash (one test loops over five broken
entries). A saved-cities list with one broken entry keeps the good ones. Settings are stored as
enum **names** and sanitized field by field, so `"kelvin"` falls back to Celsius and keeps the
user's dark theme.

### 7. The cache stores what the server sent
The forecast cache keeps the raw response and the fetch time, and maps them on every read, so a
fix in the mapper also fixes old data. It also keeps the offset that belongs to those local
times (ADR-0015), so a cached forecast is always consistent.

### 8. Check, never ask
`LocationRepositoryImpl` only **checks** the permission. Asking is a UI decision, after the
explanation US-01 requires (step 06). Denied, unavailable, no fix in time and impossible
coordinates all become a `DomainError`, and the position is not even requested when the
permission is missing (a test counts the calls).

### 9. A front door that hides the rooms
`atmos_data.dart` exports `DataModule` (four domain interfaces), the two real inputs
(`SharedPreferencesStore`, `GeolocatorLocationPlatform`), the interfaces of the inputs, and
`InMemoryKeyValueStore` for tests. **No DTO and no `…Impl`**: outside `atmos_data`, nothing can
name them. The data package's own tests import `src/` directly, which Dart allows inside a
package.

## Run it yourself

```bash
git switch step-04-data-layer
flutter pub get
cd packages/data && flutter test     # 76 tests, the recorded samples, no network
cd ../.. && tool/test_all.sh         # everything, with both coverage gates
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Ported the React Native data layer and its tests to Dart, test by test | Approved the three libraries before the step |
| Read `package:http`'s source for abort support and `MockClient`'s limits before writing the timeout test | — |
| Checked that both iOS plugins ship `Package.swift` (no Podfile needed) | — |
| Built the Android APK locally with the new plugins | — |

What ran where: format, analyze, the source rules, all tests (182 in five packages) and both
coverage gates ran in the Linux cloud session, and a debug APK was built there. The iOS build,
now with two native plugins, is proven only by the macOS CI job.

**What went wrong, and what we learned**
1. **The first local Android build failed** with a Gradle error that named nothing useful
   (`Cannot invoke "java.util.List.get(int)" because "path" is null`). Running Gradle directly
   with `--stacktrace` succeeded, and a second `flutter build apk` succeeded too; the agent could
   not reproduce it, so it is recorded here rather than "fixed". It happened on the first build
   after three plugins arrived. **Lesson:** report a failure you could not explain; do not hide
   it because the retry was green.
2. **More packages than expected.** `pubspec.lock` gained `jni` (used by
   `shared_preferences_android`) and `package_info_plus` (used by `geolocator_linux`, the Linux
   implementation of geolocator). Both are transitive and come with the approved libraries, so
   no ADR is needed, but they are now in the Android build. **Lesson:** read the lock file
   diff, not only the pubspec.
3. **`MockClient` cannot test a timeout as it is.** Its simple constructor copies the request
   and drops the abort trigger, so a test with it would wait forever. The source of
   `package:http` showed `MockClient.streaming` keeps the original request.
4. **A one-off helper script broke on quoting.** While adding step 03's README banner, an
   inline Python snippet with nested quotes failed to parse, and the README script then
   stopped with a `KeyError` before writing anything. The agent checked that the worktree was
   clean, moved the snippet into a file and ran it again. Then a second snag: the step-03 branch
   was still checked out in the main folder, and Git allows a branch in one worktree only, so
   step 04's branch was created first. **Lesson:** for anything with quotes inside quotes, write
   a file; and check the state after a failure before you retry.

## Checklist: is step 04 done?
- [x] HTTP client: 15 s timeout, abort, User-Agent, UTF-8; retry decorator with injected sleep
- [x] DTOs with nullable fields and hand-written parsing; one error translation table
- [x] Mappers on the recorded samples; local times with the API's offset (ADR-0015)
- [x] Cache (raw response + fetch time), saved cities, sanitized settings; corrupt data = no data
- [x] Location checks, never requests; `DataModule` hands out domain interfaces only
- [x] Data coverage gate 85% (92.5%); step guide and `PROGRESS.md` updated
