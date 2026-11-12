# Prompts — step 03: domain layer (Flutter)

> The owner approved the library ADRs first; the agent recorded that as status notes, not as
> changes to the decisions.

| Task | Instruction |
|---|---|
| Port | "Port the React Native domain (`src/domain`) and its tests to idiomatic Dart in `packages/domain`. Same behaviour, same test names, Dart idioms: sealed classes, extension types, callable classes, streams." |
| Errors | "Sealed `Result` and `DomainError`, including `Cancelled`. The cache-first table: a cancelled download is never hidden behind old data. One test per row." |
| Coordinates | "Valid-only coordinates: a private constructor and a factory that returns `null`." |
| Fakes | "Shared fakes for every package's tests in `testing.dart`; make it a rule that no `lib/` imports them." |
| Coverage | "A 90% line gate for the domain. A dev-only package for lcov is allowed if needed; check first whether the SDK already writes lcov." → `--coverage-path`, no package (ADR-0014). |
| Time | "Dart core has no IANA zones. Decide now how local times become instants, before the domain entities are fixed; prefer no new dependency, and state the limitation." → ADR-0015. |
| Commits | "Small commits that each compile and pass on their own." |
