# Prompts — step 06: integration (Flutter)

| Task | Instruction |
|---|---|
| View models | "Port the React Native view models to Riverpod Notifiers, one per screen, with one `onEvent`. Presentation logic only; the decision table stays in `GetForecast`." |
| Late answers | "Every load and search takes a number; ignore an answer that is not the latest, and anything after dispose. Then remove each guard and show me its test failing." |
| Timers | "300 ms debounce and a 5 s Undo, tested in `testWidgets`' fake time; no new package." |
| Permission | "Explanation first, then the system dialog; the app settings when the system will not ask again. The location repository must not be able to ask." |
| Wiring | "The composition root as `ProviderScope` overrides; a provider without an override fails with its name. Journey tests run the real `AtmosApp` with fakes, in all three languages." |
| Navigation | "Typed functions per screen, no route names; the selected place is shared state." |
| Dependencies | "Opening a link has no approved library: do not add one. Propose an option in an ADR for the owner." → ADR-0017. |
| Native | "Read the 3.50 iOS embedder headers before writing Swift; the macOS CI job is the only compiler." |
