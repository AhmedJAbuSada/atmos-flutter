# Prompts — step 07: quality and release (Flutter)

> Start from React Native's five red emulator runs: no coarse location on an emulator, a Pixel 7
> profile, a launcher ANR dialog, a 60 s budget for the real API, and a bash script for the runner.

| Task | Instruction |
|---|---|
| Mode | "Read the Flutter tool and Gradle plugin sources: which build modes can run an `integration_test` on an emulator, and which of them have R8? Test the release build too, and say in the guide what mode the journey runs in." → ADR-0018. |
| Journey | "The same journey as the other apps, without location: search, add Ankara (323786), open it, °F. By key, not by text. Wait 60 s for the real API; retry a language once with a log line." |
| Language | "Set the per-app language with adb before each run, and make the test fail if the app shows another language." |
| Failures | "On failure, put the test's message, the screen (uiautomator dump) and the app log into `error:` lines: annotations are all we can read." |
| Screenshots | "Record them per language; with `[screenshots]` CI commits them. Then look at them yourself, Arabic first, and fix what they show, with a test that fails without the fix." |
| Release | "Version 1.0.0+1, iOS permission text in three languages, a privacy manifest that declares coarse location, an iOS Release build, a changelog and a release checklist with no keys in the repo." |
| Docs | "Count the tests per level; do not estimate. List every red run and its lesson." |
