# API contract — Open-Meteo

Atmos uses two free Open-Meteo APIs. Neither needs an API key, so there is **no secret
in this repository**, and anyone can clone and run the app straight away.

| API | Base URL | Used for |
|---|---|---|
| Forecast | `https://api.open-meteo.com/v1/forecast` | Current, hourly and daily weather (F-01, F-03, F-04) |
| Geocoding | `https://geocoding-api.open-meteo.com/v1/search` | City search (F-05) |

**License:** data is CC BY 4.0. Attribution "Weather data by Open-Meteo.com" is required
(F-11). The free tier is for non-commercial use and allows up to 10,000 calls a day.

> **Why write a contract for an API we don't own?** Because it is the boundary between our
> app and the outside world. The data layer (step 04) is written against this document,
> and the tests use the real recorded responses in [`samples/`](samples/). When the API
> changes, this is the one place to update.

---

## 1. Forecast

### Request

```
GET https://api.open-meteo.com/v1/forecast
    ?latitude=41.01
    &longitude=28.97
    &current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m
    &hourly=temperature_2m,weather_code,precipitation_probability
    &daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset
    &timezone=auto
    &forecast_days=7
    &forecast_hours=24
```

| Parameter | Value | Why |
|---|---|---|
| `latitude`, `longitude` | Decimal degrees | From the device location or a saved city. |
| `current` | List of fields | Only what F-01 needs. Asking for less makes the response smaller. |
| `hourly` | List of fields | F-03. |
| `daily` | List of fields | F-04. |
| `timezone` | `auto` | Times come back in the **location's** local time, not the device's. |
| `forecast_days` | `7` | F-04. |
| `forecast_hours` | `24` | F-03. Starts from the current hour. |

**Units are always requested in metric** (°C, km/h). Conversion to °F, m/s or mph
happens in the **domain layer** (see ADR-0005). Changing the unit therefore never needs a
network call (US-08).

### Response `200 OK` (shortened; full file: [`samples/forecast_istanbul.json`](samples/forecast_istanbul.json))

```json
{
  "latitude": 41.02444,
  "longitude": 28.940546,
  "utc_offset_seconds": 10800,
  "timezone": "Europe/Istanbul",
  "current": {
    "time": "2026-11-11T10:15",
    "temperature_2m": 14.9,
    "relative_humidity_2m": 69,
    "apparent_temperature": 11.2,
    "is_day": 1,
    "weather_code": 3,
    "wind_speed_10m": 24.8
  },
  "hourly": {
    "time": ["2026-11-11T10:00", "2026-11-11T11:00"],
    "temperature_2m": [14.8, 15.3],
    "weather_code": [2, 3],
    "precipitation_probability": [0, 0]
  },
  "daily": {
    "time": ["2026-11-11", "2026-11-12"],
    "weather_code": [3, 3],
    "temperature_2m_max": [16.9, 20.5],
    "temperature_2m_min": [11.4, 16.5],
    "sunrise": ["2026-11-11T07:46", "2026-11-12T07:48"],
    "sunset": ["2026-11-11T17:49", "2026-11-12T17:48"]
  }
}
```

### Things to watch for (they become tests in step 04)

1. **Arrays, not objects.** `hourly` and `daily` are *parallel arrays*: index `i` of
   `time` belongs to index `i` of `temperature_2m`. The mapper zips them into a list of
   objects. If the arrays have different lengths, the mapper must fail safely, not crash.
2. **Times have no offset.** `"2026-11-11T10:15"` is local time at the location. Combine
   it with `utc_offset_seconds` or `timezone` to get a real instant.
3. **`is_day` is `0` or `1`**, not a boolean.
4. **Values can be `null`** (for example, `precipitation_probability` far in the future).
   Every field in the DTO is nullable; the mapper decides the fallback.
5. **The returned coordinates differ slightly** from the requested ones (the API snaps to
   its grid). Never use them as a cache key; use the requested ones.

### Error response `400 Bad Request` ([`samples/forecast_error.json`](samples/forecast_error.json))

```json
{
  "error": true,
  "reason": "Latitude must be in range of -90 to 90°. Given: 999.0."
}
```

---

## 2. Geocoding (city search)

### Request

```
GET https://geocoding-api.open-meteo.com/v1/search
    ?name=Istanbul
    &count=10
    &language=tr
    &format=json
```

| Parameter | Value | Why |
|---|---|---|
| `name` | User input, URL-encoded, at least 2 characters | The API returns nothing for 1 character (US-04). |
| `count` | `10` | Enough for a results list. |
| `language` | `en`, `tr` or `ar` | Names come back translated (F-05). Follows the app language, not the device language. |

### Response `200 OK` (language `tr`, shortened)

```json
{
  "results": [
    {
      "id": 745044,
      "name": "İstanbul",
      "latitude": 41.01384,
      "longitude": 28.94966,
      "country_code": "TR",
      "country": "Türkiye Cumhuriyeti",
      "admin1": "İstanbul",
      "timezone": "Europe/Istanbul"
    }
  ]
}
```

The same city in other languages: [`en`](samples/geocoding_istanbul_en.json),
[`tr`](samples/geocoding_istanbul_tr.json), [`ar`](samples/geocoding_istanbul_ar.json).

### Things to watch for

1. **No results means no `results` key at all**, not an empty list
   ([`samples/geocoding_empty.json`](samples/geocoding_empty.json)):
   ```json
   { "generationtime_ms": 0.07 }
   ```
   The DTO must default `results` to an empty list. This is a classic bug that the recorded
   sample catches.
2. **`id` is stable**, so it is the key for saved cities (no duplicates, US-05).
3. `admin1` (region) and `country` can be missing for small places.

---

## 3. WMO weather codes

`weather_code` follows the WMO standard. The domain layer maps it to a `WeatherCondition`
enum, and the presentation layer maps that to a localized label and an icon.

| Code | Condition | Code | Condition |
|---|---|---|---|
| 0 | Clear sky | 61, 63, 65 | Rain: slight, moderate, heavy |
| 1, 2, 3 | Mainly clear, partly cloudy, overcast | 66, 67 | Freezing rain |
| 45, 48 | Fog, depositing rime fog | 71, 73, 75 | Snowfall: slight, moderate, heavy |
| 51, 53, 55 | Drizzle: light, moderate, dense | 77 | Snow grains |
| 56, 57 | Freezing drizzle | 80, 81, 82 | Rain showers |
| | | 85, 86 | Snow showers |
| | | 95 | Thunderstorm |
| | | 96, 99 | Thunderstorm with hail |

Any code not in this table maps to `WeatherCondition.Unknown`; it must never crash.

---

## 4. Client rules

| Rule | Value |
|---|---|
| Timeouts | Connect 10 s, read 15 s |
| Retries | Up to 2, only for network errors and HTTP 5xx, with exponential back-off (1 s, 2 s) |
| No retry for | HTTP 4xx (our request is wrong; retrying will not help) |
| Cache freshness | 30 minutes (F-07) |
| User-Agent | `Atmos/<version> (Flutter; android|ios)`; no personal data |
