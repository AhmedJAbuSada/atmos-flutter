# ADR-0005: Localization — gen-l10n ARB, `intl`, RTL, language from the OS

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
NF-02 asks for English, Turkish and Arabic, full RTL, locale-aware casing, numbers and dates.
The other three apps found three bugs we must not repeat:
1. Android: an in-app language picker next to the per-app language of the OS gave **two
   sources of truth** that disagreed.
2. Android: in Arabic, `11°` displayed as `°11` and `25 km/h` as `km/h 25`, because the
   Unicode bidirectional algorithm reorders a left-to-right value inside right-to-left text.
3. All platforms: `"istanbul".toUpperCase()` gives `ISTANBUL`; Turkish readers expect `İSTANBUL`.

## Decision
1. **Strings:** ARB files (`app_en.arb`, `app_tr.arb`, `app_ar.arb`) in `atmos_presentation`,
   compiled to typed Dart by Flutter's `gen-l10n` with `flutter_localizations`. A missing key is
   a compile error. Plurals use ICU syntax, so Arabic gets all six forms.
2. **Translations are AI-written** and are marked as such, in each ARB file and in the README:
   *not reviewed by a native speaker*.
3. **Numbers, units and dates** through [`intl`](https://pub.dev/packages/intl) (`NumberFormat`,
   `DateFormat`): Turkish `%69` and `12,5`. **Arabic uses Latin digits**; a unit test asserts
   that every formatted Arabic value contains only `0–9`, whatever the locale data defaults to.
4. **Every formatted value is wrapped in Unicode directional isolates** (`U+2066 … U+2069`),
   so a value reads as one left-to-right unit inside any sentence: the Android fix.
5. **RTL:** `GlobalWidgetsLocalizations` sets the text direction from the locale. Layouts use
   `start`/`end` (`EdgeInsetsDirectional`, `AlignmentDirectional`), never `left`/`right`,
   enforced by a custom check (ADR-0012).
6. **The OS owns the app language.** The app follows the system's per-app language (Android 13+
   and iOS) or the device language; there is **no in-app language picker**. The Settings
   "Language" row (F-09) shows the current language and opens the system settings page where
   it is changed. The app declares its languages to the OS (`CFBundleLocalizations` on iOS,
   `locales_config.xml` on Android). Which call opens that page is decided when it is built
   (step 06), with a new ADR if it needs a dependency.
7. **Casing:** Dart's `toUpperCase()`/`toLowerCase()` take no locale. They are forbidden by a
   custom check (ADR-0012); a small locale-aware helper handles Turkish and Azerbaijani `i/İ`,
   `ı/I` and is the only place allowed to call them.
8. Units are always requested in metric and converted in the **domain** (see the API contract),
   so changing a unit never needs a network call.

## Alternatives considered
| Option | Why not |
|---|---|
| `easy_localization`, `slang` | Good libraries, but a dependency for what the SDK's `gen-l10n` already does with type safety. |
| An in-app language picker | Two sources of truth: the Android bug. |
| Arabic-Indic digits (`٠١٢`) | A valid choice, but the owner chose Latin digits, as in the other apps. |

## Consequences
- ✅ Same behaviour as the other three apps.
- ✅ Typed string accessors: a typo is a compile error.
- ⚠️ Translations need a native-speaker review before release.
- ⚠️ Before Android 13 there is no per-app language; the app follows the device language.
