# ADR-0008: Storage — shared_preferences behind a `KeyValueStore`

- **Status:** Accepted
- **Date:** 2026-11-12
- **Approved:** by the project owner on 2026-11-12, as written (status note added in step 03)

## Context
We store three small things: the saved cities (at most a few dozen), the settings, and the
forecast cache (the raw API response and its fetch time, a few kilobytes per place). Android
uses Room and DataStore, iOS JSON files and `UserDefaults`, React Native AsyncStorage.

## Decision
[`shared_preferences`](https://pub.dev/packages/shared_preferences) (maintained by the Flutter
team), with its **`SharedPreferencesAsync`** API: DataStore Preferences on Android,
`UserDefaults` on iOS. Values are JSON strings behind a small `KeyValueStore` interface in
`atmos_data`, so tests use an in-memory store and no platform channel.

## Alternatives considered
| Option | Why not |
|---|---|
| `sqflite` / `drift` | SQL and migrations for a list of ten cities. |
| `hive` / `isar` | Fast, but their maintenance history is uneven; more than we need. |
| JSON files with `path_provider` | Fine (the iOS choice), but a second plugin and our own atomic writes. |
| The legacy `SharedPreferences` API | Being replaced by the async and cached APIs; its in-memory cache can go stale. |

## Consequences
- ✅ The same "raw response, mapped on read" cache as the other apps.
- ✅ An official, boring plugin on the platform-recommended storage.
- ⚠️ Unencrypted: fine here, there is no personal data (NF-06).
- ⚠️ Not meant for large data; a forecast is a few kilobytes, so this is fine.
