# ADR-0009: Location — geolocator

- **Status:** Accepted
- **Date:** 2026-11-12
- **Approved:** by the project owner on 2026-11-12, as written (status note added in step 03)

## Context
US-01 needs the device position once, when the app opens, and only if the user allowed it.
The data layer must **check** the permission without ever showing a prompt; asking is a UI
decision (F-02: an explanation comes first). Android uses FusedLocationProviderClient, iOS
CoreLocation, React Native the community Geolocation module plus react-native-permissions.

## Decision
[`geolocator`](https://pub.dev/packages/geolocator) (Baseflow), behind a `LocationPlatform`
interface in `atmos_data`:
- `checkPermission()` reads the permission without a prompt; `requestPermission()` is called
  only from the UI flow, after the explanation.
- `getCurrentPosition()` with low (coarse) accuracy and a time limit.
- `openAppSettings()` for a user who denied the permission permanently.
- Coarse location only: `ACCESS_COARSE_LOCATION` on Android, `NSLocationWhenInUseUsageDescription`
  on iOS.

## Alternatives considered
| Option | Why not |
|---|---|
| `location` | Similar features; geolocator's permission API matches our "check, never ask" rule more directly and it is more widely used. |
| `permission_handler` + a position plugin | Two plugins where one has both; useful only if we needed many permission types. |
| A platform channel of our own | Teaches native bridging, not this step; more code to maintain on two platforms. |

## Consequences
- ✅ One Dart API for permission and position on both platforms, faked in tests.
- ✅ Coarse location: the user shares less, and the forecast does not need more.
- ⚠️ A native plugin: an upgrade must run the Android and iOS CI builds.
