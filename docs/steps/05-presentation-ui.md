# Step 05 — Presentation: the views, before any data (Flutter)

**Branch:** `step-05-presentation-ui` · **Previous:** [step 04](04-data-layer.md) · **Next:** [step 06, integration](06-integration.md)

Every screen is a **view of a state value**: a sealed state in, events out. No view model, no
repository, no navigation yet. A view that can only show what it is given can be built, tested
and reviewed on its own, in every language and theme. The same step exists for
[Android](https://github.com/AhmedJAbuSada/atmos-android/blob/step-05-presentation-ui/docs/steps/05-presentation-ui.md),
[iOS](https://github.com/AhmedJAbuSada/atmos-ios/blob/step-05-presentation-ui/docs/steps/05-presentation-ui.md)
and [React Native](https://github.com/AhmedJAbuSada/atmos-react-native/blob/step-05-presentation-ui/docs/steps/05-presentation-ui.md).

## What this step adds

```
packages/presentation/
├── l10n.yaml                         ← gen-l10n: ARB in, typed Dart out
└── lib/src/
    ├── l10n/arb/app_en.arb, app_tr.arb, app_ar.arb   ← 78 messages; ICU plurals
    ├── l10n/app_localizations*.dart  ← generated and committed; CI checks they are current
    ├── l10n/app_language.dart        ← the three locales, the delegates, resolveAppLocale()
    ├── formatting/weather_formatter.dart  ← intl + directional isolates + Latin digits
    ├── theme/atmos_colors.dart       ← light and dark tokens as a ThemeExtension
    ├── weather/condition_ui.dart     ← condition → emoji and label; moon at night
    ├── error_message.dart            ← DomainError → message; Cancelled → nothing
    ├── components/message_view.dart  ← the shared empty and error state
    ├── home/      home_state.dart, home_view.dart
    ├── cities/    cities_state.dart, cities_view.dart
    └── settings/  settings_view.dart, about_view.dart
packages/presentation/test/           ← 128 tests: every state in en, tr and ar
android/…/res/xml/locales_config.xml, ios/Runner/Info.plist ← the languages, declared to the OS
docs/architecture/adr/0016-…          ← gen-l10n next to material_ui
```

## Same ideas, four platforms

| Concern | Android | iOS | React Native | Flutter |
|---|---|---|---|---|
| Stateless screen | `HomeScreen(state, onEvent)` | `HomeContent(state, actions)` | `<HomeView state actions />` | `HomeView(state:, onEvent:)` |
| State | sealed interface | enum | union of `{kind}` | sealed class |
| Strings | `strings.xml` × 3 | String Catalog | i18next JSON × 3 | ARB × 3 + gen-l10n |
| Plurals | `<plurals>` | catalog variations | `_one`, `_few` … | ICU `{count, plural, …}` |
| Numbers, dates | `NumberFormat`, `DateTimeFormatter` | `FormatStyle` | `Intl` | `intl` |
| Arabic digits | `-u-nu-latn` | `@numbers=latn` | `ar-u-nu-latn` | `intl`'s `ar` (Latin), never `ar_EG` |
| RTL check | Lint `RtlHardcoded` | `leading`/`trailing` | ESLint rule | `tool/source_rules` `start-end` (step 02) |
| View tests | Compose UI tests | previews + XCUITest | Testing Library | `flutter_test` widget tests |

## Key ideas

### 1. Sealed state in, events out
```dart
sealed class HomeState {}
final class HomeLoading extends HomeState {}
final class HomeNeedsLocation extends HomeState {}
final class HomeFailed extends HomeState { final DomainError error; }
final class HomeContent extends HomeState { final Forecast forecast; final UserSettings settings; … }

HomeView(state: state, onEvent: (event) => …)   // HomeRefresh, HomeRetry, HomeOpenCities, …
```
The view's `body` is one `switch` over the state, so a new state is a compile error until the
view handles it. Events are sealed classes too: step 06's view models will `switch` over them.

The Cities view is a `StatefulWidget`, but only for the text field's controller, a Flutter
detail. The query itself is in `CitiesState`, and the field follows it.

### 2. The OS owns the language, and the user's order wins
`MaterialApp` gets the three `supportedLocales` and **no `locale:`**: the system's per-app
language (Android 13+, iOS) or the device languages decide. Settings has no picker, only a
button to the system page (step 06 wires it). The app declares its languages to the OS
(`locales_config.xml`, `CFBundleLocalizations`) so that page lists them.

A test found that Flutter's default resolution is not what the other apps do: for a phone set
to German, Turkish (Türkiye), English, it shows **English**, because an exact match lower in the
list beats a language-only match (`tr_TR` → `tr`). `resolveAppLocale` picks the first language in
the user's order that the app ships, as Android, iOS and React Native do.

### 3. Typed strings, and the toolchain's rough edge
gen-l10n turns `app_en.arb` into `AppLocalizations` with one getter or method per message, so a
missing key or a wrong placeholder is a compile error. Tests check that Turkish and Arabic have
exactly the English keys and placeholders, that every Arabic plural has its six forms, and that the
translations say they are AI-written and **not reviewed by a native speaker**.

Flutter 3.50 deprecated `package:flutter/material.dart` (ADR-0013), but gen-l10n's template still
lists the old `flutter_localizations` delegates. ADR-0016 explains the fix: use `material_ui`'s
delegates, exclude that single generated file from analysis by name, commit the generated code,
and let CI fail if it differs from what `flutter gen-l10n` writes.

### 4. Arabic plurals for free
```dart
l10n.homeUpdatedHours(2)   // "تم التحديث قبل ساعتين"   (two)
l10n.homeUpdatedHours(3)   // "تم التحديث قبل 3 ساعات"  (few)
l10n.homeUpdatedHours(11)  // "تم التحديث قبل 11 ساعة"  (many)
```

### 5. Formatting: the language changes more than the words

| | English | Turkish | Arabic |
|---|---|---|---|
| Humidity | `69%` | `%69` | `69%` |
| Wind (m/s) | `6.9 m/s` | `6,9 m/s` | `6.9 m/s` |
| Sunrise | `7:46 AM` | `07:46` | `7:46 ص` |

Every value is wrapped in **directional isolates** (U+2066 … U+2069), so an Arabic sentence cannot
turn `11°` into `°11`. Times are shown **at the place**: the instant plus the forecast's UTC offset
(ADR-0015). The formatter takes only the language code: `intl`'s `ar` writes Latin digits, while
`ar_EG`, a common phone setting, would write `٦٩`. A test fails on any Arabic-Indic digit.

### 6. Tokens, contrast and direction
`AtmosColors` (a `ThemeExtension`) holds the same colours as the other apps, light and dark. A test
computes the WCAG contrast of every text colour on its background: all pairs pass AA (4.5 : 1,
NF-03). Layouts use `EdgeInsetsDirectional` and `AlignmentDirectional`; the day bar grows from the
start edge, so it mirrors in Arabic. Step 02's `start-end` rule would fail CI on `left:`.

### 7. Accessible by construction (NF-03)
- Icon buttons have tooltips, which are also their spoken labels ("المدن").
- Each hour and day is one semantics node read as a sentence: "Now, 15°, Partly cloudy".
- Settings choices are `SegmentedButton`s: "°C, selected".
- Material's padded tap targets (48 dp); no fixed text heights. A test renders Home at **200%**
  font size in every language and fails on any overflow.

### 8. Tests read like the user
```dart
await pumpView(tester, HomeView(state: const HomeNeedsLocation(), onEvent: events.call), language: 'ar');
await tester.tap(find.text(l10n.homeAllowLocation));
expect(events.sent, [isA<HomeRequestLocation>()]);
```
Every state of every screen runs in English, Turkish and Arabic. The Home fixture carries the
values of the recorded Istanbul sample, built from domain types: presentation must not import the
data layer, not even in tests.

### 9. Decisions you might question
- **Emoji, not an icon font**, as in the React Native app: colour glyphs on both platforms, no
  dependency, never mirrored.
- **A remove button, not a swipe**, as in the React Native app: every screen reader can reach it.
- **No casing helper yet.** No screen changes the case of a text, so the locale-aware helper
  ADR-0005 planned is not written, and the source rule's allow-list stays empty. The rule still
  stops anyone from calling `toUpperCase()`.

## Run it yourself

```bash
git switch step-05-presentation-ui
flutter pub get
cd packages/presentation && flutter test     # 128 tests in en, tr and ar
cd ../.. && flutter run                       # Home, in the phone's language
```
To see Arabic, set the app language in the system settings (Android 13+:
*Settings → Apps → Atmos → Language*; iOS: *Settings → Atmos → Language*).

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Converted the React Native texts (from the iOS app) to ARB with a script, plurals included | Approved `flutter_localizations` and `intl` in ADR-0005 |
| Probed `intl` before writing the formatter: Arabic digits, Turkish times and percents | Reviews ADR-0016 |
| Read `material_ui`'s README and the generated code before deciding ADR-0016 | — |
| Wrote a test for every state, in all three languages, dark mode and 200% text | — |

What ran where: format, analyze, the source rules, all 311 tests and both coverage gates ran in
the Linux cloud session, and a debug APK (with the new manifest) was built there. The iOS build
is proven only by the macOS CI job. The app was **not** run on a device or emulator in this step,
so nobody has looked at the Arabic screens yet; step 07's screenshots will.

**What went wrong, and what we learned**
1. **The generated code used a deprecated API.** gen-l10n in Flutter 3.50 still writes the old
   delegates, and CI fails on any finding. Rather than an ignore comment (forbidden), ADR-0016
   records a narrow, named exclusion and a CI check. **Lesson:** when the toolchain lags behind
   itself, make the workaround visible and easy to remove.
2. **Flutter's locale resolution differed from the other apps.** The test "the first supported
   language in the phone list wins" failed with English. Reading `basicLocaleListResolution`
   explained why; `resolveAppLocale` keeps the four apps identical. **Lesson:** "the same
   behaviour" includes the defaults of each framework.
3. **"Expected: 7:46 AM, Actual: 7:46 AM".** The difference was invisible: CLDR puts a narrow
   no-break space (U+202F) before "AM". The test now expects it. **Lesson:** when two strings look
   equal, compare code points.
4. **Invisible characters in source.** The agent's tool turned `⁦` escapes into the raw,
   invisible characters; the analyzer's `text_direction_code_point_in_literal` warning caught it,
   and the files were rewritten with real escapes. **Lesson:** a strict analyzer also protects you
   from your own tools.
5. **Two loose tests.** `find.text('15°')` matched three widgets (the hourly list repeats it), and
   the attribution at the bottom was never built, because `ListView` builds lazily. The tests now
   look inside the current-conditions block and scroll like a user.
6. **Translations are AI-written** and not reviewed by a native speaker.

## Checklist: is step 05 done?
- [x] Home, Cities, Settings and About as views of sealed states; every state tested in en, tr, ar
- [x] Strings in ARB with typed accessors, Arabic plurals and a completeness test
- [x] `intl` formatting with Latin digits for Arabic and directional isolates
- [x] Light and dark tokens, contrast tested; start/end only; 200% text without overflow
- [x] The OS language is the only source of truth, declared to Android and iOS
- [x] ADR-0016; step guide and `PROGRESS.md` updated
