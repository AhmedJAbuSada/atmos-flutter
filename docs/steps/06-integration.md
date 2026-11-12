# Step 06 — Integration: the app works end to end (Flutter)

**Branch:** `step-06-integration` · **Previous:** [step 05](05-presentation-ui.md) · **Next:** step 07, quality and release

Steps 03 to 05 built three layers that did not know each other: the rules, the data, the views.
This step connects them. **View models** (Riverpod `Notifier`s) turn use-case results into the
states the views already understand, **containers** connect each view model to its view, and the
**composition root** hands the real data layer to the presentation layer as `ProviderScope`
overrides. The same step exists for
[Android](https://github.com/AhmedJAbuSada/atmos-android/blob/step-06-integration/docs/steps/06-integration.md),
[iOS](https://github.com/AhmedJAbuSada/atmos-ios/blob/step-06-integration/docs/steps/06-integration.md)
and [React Native](https://github.com/AhmedJAbuSada/atmos-react-native/blob/step-06-integration/docs/steps/06-integration.md).

## What this step adds

```
packages/presentation/lib/src/
├── providers.dart           ← the injection points (one per domain interface) and the use cases
├── app_platform.dart        ← the phone calls the screens need: dialog, settings pages, links
├── view_models/
│   ├── home_view_model.dart     ← the place and settings in, HomeState out; permission flow
│   ├── cities_view_model.dart   ← 300 ms debounce, Undo for 5 s, cached weather per row
│   └── settings_view_model.dart ← observe and change the settings
└── screens/screens.dart     ← containers: view model → view; navigation out as callbacks
packages/data/lib/src/location/geolocator_permissions.dart ← asks; the repository still cannot
lib/app/
├── composition.dart         ← AppDependencies: the real graph, as ProviderScope overrides
├── routes.dart              ← AppRoutes: one typed function per screen (ADR-0010)
├── native_platform.dart     ← AppPlatform on geolocator and a small system channel (ADR-0017)
└── atmos_app.dart, ../main.dart
android/…/MainActivity.kt, ios/Runner/AppDelegate.swift ← the channel's native halves
AndroidManifest.xml, Info.plist, {en,tr,ar}.lproj/InfoPlist.strings ← coarse location, explained
test/journey_test.dart       ← 7 journeys through the real app with fakes
```

## Same ideas, four platforms

| Concern | Android | iOS | React Native | Flutter |
|---|---|---|---|---|
| View model | `ViewModel` + `StateFlow` | `@Observable` class | Zustand vanilla store | Riverpod `Notifier` |
| Screen ↔ view model | route composable | `.task { await run() }` | container + `useStore` | `ConsumerWidget` + `ref.watch` |
| Stop work when leaving | `viewModelScope` | task cancellation | `stop()` + generation | `autoDispose` + `ref.onDispose` + generation |
| Debounce | `debounce(300)` | `Task.sleep` + cancel | `setTimeout` | `Timer` |
| Wiring | Hilt | `AppContainer` | composition root + Context | `ProviderScope(overrides: …)` |
| Navigation | Navigation Compose | `NavigationStack` | React Navigation, typed routes | `Navigator`, typed functions |
| Journey test | Compose UI test | XCUITest | Testing Library over `<App>` | `testWidgets` over `AtmosApp` |

## Key ideas

### 1. Providers are the seams
`atmos_presentation` declares one provider per domain interface. Without an override it fails at
once, naming itself (a test checks the message). The use cases are providers built from them:

```dart
final getForecastProvider = Provider((ref) => GetForecast(
  repository: ref.watch(weatherRepositoryProvider),
  freshness: ref.watch(forecastFreshnessProvider),
));
```
The app overrides the six seams with `AppDependencies(...).overrides`; tests override them with
the domain's fakes. **The wiring the journey tests run is the wiring the app runs.**

### 2. A view model is a Notifier and one `onEvent`
```dart
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

ref.watch(homeViewModelProvider);                                  // the HomeState of step 05
ref.read(homeViewModelProvider.notifier).onEvent(const HomeRetry());
```
`build()` subscribes to the selected place and the settings and returns `HomeLoading`;
`ref.onDispose` cancels the subscriptions. View models are tested with
`ProviderContainer.test(overrides: …)`, no widget at all. They hold **presentation logic only**:
which state to show and when to load. Whether to download is still `GetForecast`'s table.

### 3. Late answers are ignored, and the test proves it
Dart cannot cancel a `Future`. Each load and each search takes a number; an answer is used only if
its number is still the latest, and only while `ref.mounted`:
```dart
final token = ++_generation;
final result = await getForecast(coordinates);
if (token != _generation || !ref.mounted) return; // the user picked another place meanwhile
```
**We checked each guard by removing it.** For Home, the first test ("a late answer for the previous
place is ignored") *still passed* without the guard: `_render` happened to hide the stale value.
Two stronger tests were added: a late "permission denied" for the current location must not
replace Ankara with "Where are you?", and after a late answer a settings change must still update
the city on screen. With the guard removed, exactly those two fail:

```
00:00 +12 -1: a late "permission denied" for the current location does not hide the city [E]
00:00 +12 -2: after a late answer, a settings change still updates the city on screen [E]
```
For Cities, "an older search that answers last is ignored" fails without its guard.

### 4. Timers in fake time
Search waits 300 ms after the last keystroke; "Ankara removed · Undo" stays 5 seconds. Both are
`Timer`s. `testWidgets` runs in a fake-time zone, so the view-model tests move the clock with
`tester.pump(duration)`, with no extra package:
```dart
await type(cities, 'ank');
await tester.pump(const Duration(milliseconds: 299)); expect(searches, isEmpty);
await tester.pump(const Duration(milliseconds: 1));   expect(searches, hasLength(1));
```
`autoDispose` disposes the Cities view model when its screen goes away; a test checks that a
waiting search never runs afterwards.

### 5. Asking for location: explain first, then the system dialog
The data layer only **checks** (step 04). Asking is a separate class, `GeolocatorPermissions`,
which the location repository never receives: it *cannot* ask, by construction. Home shows the
explanation with two ways forward. "Allow location" shows the system dialog through `AppPlatform`;
granted, the forecast loads; blocked (the system will not ask again), the app opens its settings
page; denied, the explanation and "Search for a city" stay (F-02).

The dialog's text is declared for both platforms: `ACCESS_COARSE_LOCATION` only on Android, and
`NSLocationWhenInUseUsageDescription` on iOS, translated into Turkish and Arabic in
`InfoPlist.strings` (the iOS app's own AI-written texts).

### 6. Typed routes, shared state
```dart
AppRoutes.openCities(context);   // no route names, no string to mistype
```
No route takes parameters: the selected place is a `ValueStore` that Cities writes and Home follows,
so going back to Home always shows what Cities picked, even after the city on screen is removed.
The containers report navigation as callbacks, so `atmos_presentation` knows no route.

### 7. Two system calls without a library (ADR-0017)
Opening a web page (About) and the Android 13 app-language page have no approved library. A small
`MethodChannel` (about 40 lines each of Kotlin and Swift) does both and opens `https` links only.
`url_launcher` is the usual choice; it is written down as the alternative, for the owner to decide.

### 8. Journeys through the real app
```dart
await app.start(tester, phone: const [Locale('tr', 'TR')]);
await tester.tap(find.byTooltip('Şehirler'));
await tester.enterText(find.byKey(const Key('cities.search')), 'ank');
await tester.pump(const Duration(milliseconds: 300));
await tester.tap(find.byTooltip('Ankara ekle'));
```
Seven journeys run `AtmosApp` with its real routes and view models, in Turkish, Arabic and English:
search, add and pick a city; °F; dark mode; the language page and the About links; the permission
flow, granted and blocked; and "search instead".

## Run it yourself

```bash
git switch step-06-integration
flutter pub get
tool/test_all.sh         # 348 tests, both coverage gates
flutter run              # the real app: location, search, settings
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Ported the React Native view models to Riverpod Notifiers, test by test | Approved Riverpod 3 without code generation (ADR-0003) |
| Removed each late-answer guard to see its test fail, and strengthened the one that did not | Reviews ADR-0017 (platform channel vs. `url_launcher`) |
| Read Riverpod 3.5's and the iOS embedder's sources for the APIs it used | — |
| Wrote seven journey tests over the real app | — |

What ran where: format, analyze, the source rules, all 348 tests and both coverage gates ran in the
Linux cloud session, and a debug APK with the new Kotlin code was built there. The Swift code and
the hand-edited Xcode project are compiled only by the macOS CI job; it passed on the first try
(that proves they compile and bundle, not that iOS shows the Turkish text: a device run will). **Nobody has run the app on a
device or an emulator yet**, so the permission dialog, the system pages and the links have only run
against fakes; step 07's device journeys are the first real run.

**What went wrong, and what we learned**
1. **A guard test that guarded nothing.** The first late-answer test for Home passed with the guard
   removed, the same trap the React Native guide describes. **Lesson:** a test you have never seen
   fail proves nothing; remove the code it protects and watch.
2. **The layers caught the app.** The app's first `import 'package:flutter_riverpod/…'` failed
   `dart analyze`: `depend_on_referenced_packages` (an error since step 02) said the app did not
   declare Riverpod. It does now, as ADR-0003 and ADR-0004 intend.
3. **Memory was out of date.** Riverpod 3 moved `Override` to `package:flutter_riverpod/misc.dart`;
   the first tests did not compile. The agent read the 3.5 source instead of guessing further, and
   did the same for the iOS `FlutterImplicitEngineBridge`, which is new in Flutter 3.50.
4. **Ignored, not aborted.** As in the React Native app, the domain's interfaces take no
   cancellation token, so an older search still finishes; its answer just never reaches the screen.
   The HTTP client can abort (step 04); passing a token through the domain is a possible improvement.
5. **A decision the agent could not make alone.** Opening a link needs a library or native code.
   `url_launcher` has no ADR and no approval, so the agent wrote a small channel instead and
   ADR-0017 asks the owner which one the project should keep.

## Checklist: is step 06 done?
- [x] Home, Cities and Settings view models as Riverpod Notifiers, with late-answer guards (mutation-checked)
- [x] 300 ms debounced search, Undo for 5 seconds
- [x] Permission flow: explanation, dialog, app settings when blocked; the data layer never asks
- [x] Typed `Navigator` routes; the selected place shared between Cities and Home
- [x] The composition root as `ProviderScope` overrides; seven journeys through the real app
- [x] ADR-0017; step guide and `PROGRESS.md` updated
