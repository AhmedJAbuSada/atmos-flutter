# Roadmap — the seven steps

```bash
git clone https://github.com/AhmedJAbuSada/atmos-flutter.git
cd atmos-flutter
git switch step-02-project-structure   # any step
```

| Step | Branch | You learn | Guide |
|---|---|---|---|
| 01 | `step-01-planning` | Requirements, user stories, API contract, architecture and ADRs, team process, AI agent rules | [01-planning.md](steps/01-planning.md) |
| 02 | `step-02-project-structure` | Flutter project, pub workspace with one package per layer, strict analysis, custom source rules, CI | [02-project-structure.md](steps/02-project-structure.md) |
| 03 | `step-03-domain-layer` | Entities, use cases, sealed `Result` errors, `package:test`, a coverage gate | [03-domain-layer.md](steps/03-domain-layer.md) |
| 04 | `step-04-data-layer` | `package:http` + DTOs, mappers, shared_preferences cache, settings, geolocator | — |
| 05 | `step-05-presentation-ui` | Theme, screens as stateless views, gen-l10n ARB, RTL, directional isolates | — |
| 06 | `step-06-integration` | Riverpod Notifiers, `Navigator`, permissions, real data | — |
| 07 | `step-07-quality-release` | `integration_test` end to end, screenshots, release builds | — |
| — | `main` | The finished app | — |
