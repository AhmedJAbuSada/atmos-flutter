# User stories and acceptance criteria

Each story maps to a requirement in the [PRD](PRD.md). Acceptance criteria use the
**Given / When / Then** format, so they can be turned directly into tests.

> **Tip for working with an AI agent:** paste a single story with its criteria into the
> prompt and ask for "the tests first, then the implementation". The criteria become the
> test names, which keeps the agent honest.

---

## US-01 — Current weather at my location (F-01, F-02)
*As a commuter, I want to see the weather where I am, so that I can dress correctly.*

- **Given** location permission is granted, **when** I open the app, **then** I see the
  temperature, "feels like", condition, humidity and wind for my location.
- **Given** I open the app for the first time, **when** the permission dialog appears,
  **then** it is preceded by a short explanation of why location is needed.
- **Given** I deny permission, **when** the home screen loads, **then** I see a prompt to
  search for a city instead of an error.
- **Given** it is night at the location, **when** the condition is "clear", **then** the
  icon is a moon, not a sun.

## US-02 — Hourly forecast (F-03)
*As a commuter, I want the next 24 hours, so that I know if it will rain on my way home.*

- **When** the forecast loads, **then** I see 24 hourly items starting from the current
  hour, in the location's time zone.
- **Then** each item shows the hour (24 h or 12 h according to the device setting), an
  icon, the temperature and the precipitation chance.
- **Given** the precipitation chance is 0%, **then** the percentage is hidden to reduce
  noise.

## US-03 — Daily forecast (F-04)
*As a traveller, I want the coming week, so that I can plan my trip.*

- **Then** I see 7 days, with today labelled "Today" (`Bugün`, `اليوم`).
- **Then** each day shows the localized day name, an icon, and the min/max temperature.
- **When** I tap a day, **then** I see its sunrise and sunset times.

## US-04 — Search for a city (F-05)
*As a traveller, I want to find a city by name, so that I can check its weather.*

- **Given** I type fewer than 2 characters, **then** no search is made.
- **Given** I type `ista`, **when** I stop typing for 300 ms, **then** a search runs
  (debounced) and results show the name, region and country.
- **Given** the app language is Turkish, **then** `Istanbul` appears as `İstanbul`.
- **Given** no city matches, **then** I see "No cities found" (not an error).
- **Given** the network fails, **then** I see an error with a retry button.

## US-05 — Favourite cities (F-06)
*As a traveller, I want to save cities, so that I can switch between them quickly.*

- **When** I tap "Add" on a search result, **then** the city is saved and appears in my
  list.
- **Then** my current location is always the first item and cannot be removed.
- **When** I swipe a saved city, **then** it is removed and I can undo for 5 seconds.
- **Given** I already saved a city, **then** adding it again does nothing (no
  duplicates).
- **Then** saved cities survive an app restart.

## US-06 — Fresh data (F-07)
*As a user, I want the data to stay up to date without thinking about it.*

- **When** I pull down on the home screen, **then** the data refreshes.
- **Given** the cached data is older than 30 minutes, **when** I open the app, **then** it
  refreshes automatically.
- **Given** the cached data is newer than 30 minutes, **then** no network call is made.

## US-07 — Offline (F-08)
*As a user on the metro, I want to see the last forecast without internet.*

- **Given** I am offline and have cached data, **then** I see it with the banner "Last
  updated 2 hours ago".
- **Given** I am offline and have no cached data, **then** I see an offline message with a
  retry button.
- **When** the connection comes back and I retry, **then** the banner disappears.

## US-08 — Settings (F-09)
*As a user, I want the app in my language and units.*

- **When** I change the temperature unit, **then** every screen updates immediately, with
  no new network call (conversion happens in the app).
- **When** I choose العربية, **then** the whole layout mirrors (right to left), including
  the direction of the hourly list.
- **When** I choose Türkçe, **then** numbers use a decimal comma (`12,5°`) and dates are
  in Turkish.
- **Then** settings survive an app restart.

## US-09 — States (F-10)
*As a user, I always want to know what the app is doing.*

- **While** loading for the first time, **then** I see a skeleton placeholder, not a blank
  screen.
- **Given** any request fails, **then** I see a human message (not an exception) and a
  retry button.

## US-10 — About (F-11)
- **Then** I see "Weather data by Open-Meteo.com" with a link, the app version, and a link
  to this repository.
