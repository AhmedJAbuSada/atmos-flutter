# Product Requirements Document (PRD) — Atmos

| | |
|---|---|
| **Product** | Atmos — a weather app |
| **Platforms** | Flutter (this repo), Android, iOS, React Native — same product, four codebases |
| **Owner** | Ahmed J. AbuSada |
| **Status** | Approved for development (step 01) |
| **Last updated** | 2026-11-11 |

> **Why a PRD first?** Code answers *how*. A PRD answers *what* and *why*. Without one,
> every developer (and every AI agent) fills the gaps with their own guesses, and you get
> four different apps instead of one. Everything in later steps traces back to an ID in
> this file (`F-01`, `NF-03`, …).

---

## 1. Problem

People check the weather several times a day, usually in a hurry. Most weather apps are
crowded with ads and screens they never use. Atmos answers three questions quickly:

1. **What is it like right now?**
2. **What will the next hours look like?**
3. **What about the coming week?**

It answers them for where you are now and for the cities you care about, in your own
language.

## 2. Goals and non-goals

### Goals
- **G-1** Show the current conditions in **under 2 seconds** on a normal 4G connection
  (from a cached start, instantly).
- **G-2** Work **offline** with the last known data, clearly marked as outdated.
- **G-3** Be fully usable in **English, Turkish and Arabic** (right-to-left).
- **G-4** Serve as a **reference codebase**: clean, tested, and documented step by step.

### Non-goals (version 1)
- Weather maps, radar, or animated layers
- Severe-weather push alerts
- Home-screen widgets and wearables
- User accounts, sign-in or cloud sync
- Monetisation (ads, subscriptions)

> Writing non-goals down is as important as the goals. It stops scope creep and tells the
> AI agent what **not** to build when it "helpfully" adds features.

## 3. Users

| Persona | Need |
|---|---|
| **Commuter** (primary) | Glances at the app before leaving: "Do I need a jacket or an umbrella?" |
| **Traveller** | Follows the weather in two or three other cities. |
| **Learner developer** (repo audience) | Reads the code to learn Clean Architecture and team workflow. |

## 4. Functional requirements

| ID | Requirement | Priority |
|---|---|---|
| **F-01** | Show current weather for the device location: temperature, "feels like", condition text and icon, humidity, wind speed, day/night. | Must |
| **F-02** | Ask for location permission with a clear explanation. If denied, the app still works through city search. | Must |
| **F-03** | Show the next **24 hours**: time, icon, temperature, chance of precipitation. | Must |
| **F-04** | Show the next **7 days**: day name, icon, min and max temperature, sunrise and sunset. | Must |
| **F-05** | Search cities by name, with results in the app language (for example, `İstanbul` in Turkish and `اسطنبول` in Arabic). | Must |
| **F-06** | Save cities as favourites, remove them, and switch between them. The current location is always first. | Must |
| **F-07** | Pull to refresh. Data refreshes automatically when older than **30 minutes**. | Must |
| **F-08** | Offline mode: show cached data with a "Last updated 2 h ago" banner. | Must |
| **F-09** | Settings: temperature unit (°C/°F), wind unit (km/h, m/s, mph), language (System, English, Türkçe, العربية), theme (System, Light, Dark). | Must |
| **F-10** | Clear loading, empty and error states with a retry action on every screen. | Must |
| **F-11** | "About" screen: data attribution to Open-Meteo, app version, link to the source code. | Should |

## 5. Non-functional requirements

| ID | Requirement |
|---|---|
| **NF-01** | **Architecture:** Clean Architecture with three layers (domain, data, presentation). The domain layer has no framework dependencies. See [ARCHITECTURE.md](../architecture/ARCHITECTURE.md). |
| **NF-02** | **Localization:** English, Turkish and Arabic. Full RTL mirroring for Arabic. Locale-aware text casing (Turkish `i/İ`, `ı/I`), numbers (`12,5` in Turkish) and dates. No hard-coded user-facing strings. |
| **NF-03** | **Accessibility:** every interactive element has a content description, minimum touch target of 48 dp on Android and 44 pt on iOS, supports the system font size up to 200%, and meets WCAG AA contrast. |
| **NF-04** | **Performance:** cold start under 1.5 s on a mid-range device; scrolling stays at 60 fps. |
| **NF-05** | **Testing:** domain and data layers ≥ 80% line coverage. Every ViewModel has unit tests. Key flows have UI tests. |
| **NF-06** | **Privacy:** no analytics, no tracking, no accounts. Location is used only to request the forecast and is never stored remotely. |
| **NF-07** | **Security:** no secrets in the repo (Open-Meteo needs no key). HTTPS only. |
| **NF-08** | **Quality gates:** lint, static analysis and tests run on every pull request in CI. Nothing merges with a red pipeline. |
| **NF-09** | **Min OS:** Android 8.0 (API 26) and iOS 17, from one Dart codebase, built with Flutter 3.50 (stable). |

## 6. Data source

[Open-Meteo](https://open-meteo.com/) — free, no API key, licensed CC BY 4.0
(attribution required, shown on the About screen, F-11). Details in
[API_CONTRACT.md](../api/API_CONTRACT.md).

## 7. Success criteria (definition of "v1.0 done")

- All **Must** requirements pass the acceptance criteria in
  [USER_STORIES.md](USER_STORIES.md).
- All NF requirements are verified in `step-07-quality-release`.
- The same feature set ships on all four platforms.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Open-Meteo is down or rate-limits us | Cache-first repository; offline banner (F-08); exponential back-off. |
| User denies location | Search-first flow (F-02, F-05). |
| RTL layout bugs | RTL checked in every UI review; Arabic screenshots in the PR template. |
| Turkish casing bugs | A custom source check that fails CI on `toUpperCase()`/`toLowerCase()` (Dart's versions ignore the locale); a locale-aware helper instead; unit tests with the `tr` locale. |
