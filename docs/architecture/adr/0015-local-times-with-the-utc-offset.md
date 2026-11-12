# ADR-0015: Local times from the API's UTC offset, no time-zone database

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
Open-Meteo sends local wall-clock times without an offset (`"2026-11-11T10:15"` means 10:15
*in Istanbul*), plus `timezone` (`Europe/Istanbul`) and `utc_offset_seconds` (`10800`). The
other apps turn these into real instants with the platform's time-zone database
(`java.time`, `TimeZone`, `Intl.DateTimeFormat` in Hermes). **Dart's core libraries know only
UTC and the device's own zone**, not IANA zones by name.

## Decision
- The data layer reads every local time as `wall clock − utc_offset_seconds`, a UTC
  `DateTime`. No new dependency.
- The domain `Forecast` keeps both `timeZone` (the IANA name, for display) and `utcOffset`
  (a `Duration`). The UI shows a time at the place as `instant + utcOffset`, read in UTC, so
  the wall-clock times it shows are **exactly the ones the API sent**.
- An unknown or missing offset is `Duration.zero` and a missing name is `UTC`, never a crash.

## The limitation, stated plainly
`utc_offset_seconds` is the offset **at the time of the request**. If the place changes its
clocks inside the 7-day window (a daylight-saving change):
- the *displayed* local times stay correct, because the display adds back the same offset;
- the *instants* after the change are one hour off. That matters only where an instant is
  compared with the device clock (for example "which hourly item is now") within an hour of
  the change, and in the repeated hour of an autumn change, where two hourly items map to the
  same instant.

The cache stores the raw response, and with it the offset that belongs to its times, so a
cached forecast stays consistent.

## Alternatives considered
| Option | Why not (for now) |
|---|---|
| [`timezone`](https://pub.dev/packages/timezone) package (IANA database in Dart) | Correct across changes, but a ~400 KB database to ship and keep current, and a dependency that needs the owner's approval. The first choice if the limitation above becomes a real bug. |
| `flutter_timezone` / a platform channel | Gives the *device's* zone name, not conversions for another place. |
| Ask Open-Meteo for `timeformat=unixtime` | Correct instants, but then the display needs the zone rules to show local times: the same problem moved to the UI. |

## Consequences
- ✅ No dependency; times shown are the API's own local times.
- ⚠️ Instants can be one hour off after a clock change inside the forecast window. A test in
  the data layer (step 04) documents the behaviour, so a change to it is deliberate.
- If a step needs exact instants across changes, a new ADR adds `timezone` (owner approval).
