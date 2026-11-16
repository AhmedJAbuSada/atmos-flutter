# Changelog

All notable changes to Atmos for Flutter. The format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [1.0.0] — 2026-11-12
The first release, with the same features as the Android, iOS and React Native apps (PRD v1.0).
Built with Flutter 3.50.0 (Dart 3.14.0).

### Added
- Current weather at your location, the next 24 hours and 7 days, sunrise and sunset (US-01–US-03).
- City search with names in the app language; saved cities with remove and Undo (US-04, US-05).
- Offline: the last forecast is shown with how old it is (US-06, US-07).
- °C/°F, wind in km/h, m/s or mph, and light/dark/system theme (US-08).
- English, Turkish and Arabic (right to left), following the phone's per-app language.
  The Turkish and Arabic texts are AI-written and not yet reviewed by a native speaker.
- About screen with the Open-Meteo attribution and the source code link (US-10).

### Known limitations
- Forecast instants after a daylight-saving change inside the 7-day window are one hour off;
  the local times shown are correct (ADR-0015).
- The device journey runs in profile mode; the release build itself is smoke-tested only
  (ADR-0018). The current-location path is tested with fakes, not on a device.
