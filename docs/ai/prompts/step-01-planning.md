# Prompts — step 01: planning (Flutter)

> Same product, fourth codebase. Reuse the product documents; write the architecture for
> Flutter. The owner decided Riverpod, the three languages, errors as values, the OS-owned
> language, Latin digits with directional isolates, and tool-enforced casing and `start`/`end`.

| Task | Instruction |
|---|---|
| Shared docs | "Copy the product docs, the API contract and the samples byte for byte; change only the platform facts. Keep every requirement ID." |
| Versions | "Install the current stable Flutter and look up the current versions of the packages you propose before you choose them." |
| Architecture | "Same three layers plus a composition root. The domain is pure Dart. Dart has packages: what exactly does a pub workspace enforce? Try it before you write the ADR." → ADR-0001. |
| View models | "Riverpod, `Notifier`-based, one state per screen. Compare with ViewModel, `@Observable` and Zustand." → ADR-0003. |
| Libraries | "One ADR per library choice: boring, maintained, current. Say what the other three apps use and when we would switch." → ADR-0007 to ADR-0011. |
| Lessons | "Carry over: one source of truth for the language, directional isolates in RTL text, Latin digits, CI that explains its failures. Port the intent of each rule, not its wording." |
