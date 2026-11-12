# ADR-0002: Open-Meteo as the weather data source

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
The repositories are public. Anyone should be able to clone and run the app without
creating an account, and we must never commit an API key.

## Decision
Use [Open-Meteo](https://open-meteo.com/) for the forecast and geocoding APIs.

## Alternatives considered
| Option | Why not |
|---|---|
| OpenWeatherMap | Needs an API key; a public repo would leak it or force every reader to sign up. |
| WeatherAPI.com | Same: key required. |
| Apple WeatherKit | Native on iOS, but needs a paid Apple Developer account and does not exist on Android, so the four apps could not share one data source. |

## Consequences
- ✅ Zero setup: clone and run.
- ✅ Free geocoding with translated names (`tr`, `ar`), which we need for F-05.
- ⚠️ Free tier is non-commercial, ~10,000 calls a day. Fine for a portfolio; a commercial
  app would need the paid plan.
- ⚠️ Attribution required (CC BY 4.0), so we have an About screen (F-11).
- The repository interface hides the provider, so switching later only changes `atmos_data`.
