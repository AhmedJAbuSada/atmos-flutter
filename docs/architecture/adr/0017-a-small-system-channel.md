# ADR-0017: A small platform channel for links and the language page

- **Status:** Accepted (for the owner's review)
- **Date:** 2026-11-12

## Context
Step 06 wires three system calls the screens need. Two are covered by an approved library:
the location dialog and the app settings page come from geolocator (ADR-0009). Two are not:
- **About** (F-11) opens two web pages, Open-Meteo and the source code.
- **Settings → Language** opens the system page where the app language is changed (ADR-0005).
  Android 13+ has a page for exactly that (`ACTION_APP_LOCALE_SETTINGS`); geolocator's
  `openAppSettings` opens the app's general page, one tap away from it.

Flutter has no built-in API for either. React Native used `Linking`, part of React Native.
AGENTS.md: no dependency without an ADR or the owner's approval.

## Decision
A `MethodChannel` of our own, `dev.ahmedabusada.atmos/system`, with two methods:
- `openUrl(https URL)`: Android `ACTION_VIEW`, iOS `UIApplication.open`. **Only `https`**: the
  channel never opens another app's deep link.
- `openLanguageSettings()`: Android 13+ the app's language page, older Android the app's details
  page; iOS the app's page in Settings, which shows its language.

About 40 lines of Kotlin in `MainActivity.kt` and 40 of Swift in `AppDelegate.swift`, called by
`NativeAppPlatform` in the app. A failed call (no browser) changes nothing on screen. The view
models only see `AppPlatform`, so tests use a fake.

## Alternatives considered
| Option | Why not (for now) |
|---|---|
| [`url_launcher`](https://pub.dev/packages/url_launcher) (flutter.dev) | The usual choice and well maintained; but a dependency the owner has not approved, and it does not open Android's app-language page. **If the owner prefers it for links, a new ADR replaces the `openUrl` half of this channel.** |
| `android_intent_plus` / `app_settings` | Two more dependencies for two calls. |
| Showing the links as text only | US-10 asks for a link. |

## Consequences
- ✅ No new dependency; the exact pages the product asks for.
- ⚠️ Native code we maintain on two platforms. The Swift half is compiled only by the macOS CI
  job (there is no Mac in the cloud session), and neither half is run by a test until the
  device journeys of step 07.
