# Prompts — step 04: data layer (Flutter)

| Task | Instruction |
|---|---|
| Port | "Port `src/data` and `__tests__/data` from the React Native repo to `packages/data`. Tests use `docs/api/samples` only, read byte for byte." |
| Client | "`package:http`: 15 s timeout, the User-Agent, cancellation with abortable requests. Read the package's source for what `MockClient` supports before writing the timeout test." |
| Retry | "A decorator: network errors and 5xx, never 4xx or a cancellation; 1 s then 2 s; the sleep injected." |
| Parsing | "DTOs with every field nullable, parsed by hand under `strict-casts`; a value of the wrong type is missing, never a crash; keep parallel arrays aligned." |
| Times | "Local times with the response's `utc_offset_seconds` (ADR-0015). Pin the daylight-saving limitation in a test." |
| Storage | "The raw response and the fetch time in the cache; corrupt data is no data; settings sanitized; saved cities without duplicates, observed as a stream." |
| Location | "Check the permission, never request it." |
| Surface | "A data module that hands out domain interfaces only. The composition root creates it with the real store and location." |
| Platforms | "Check whether the new plugins need a Podfile on iOS; build the Android APK locally." |
