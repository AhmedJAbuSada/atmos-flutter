# Architecture Decision Records (ADRs)

An ADR records **one** important decision: the context, the choice, the alternatives and the
consequences. Accepted ADRs are never edited; a new ADR *supersedes* an old one, so the history
of *why* is never lost. Each one here compares the Flutter choice with the Android, iOS and
React Native apps.

| # | Title | Status |
|---|---|---|
| [0001](0001-clean-architecture-with-a-pub-workspace.md) | Clean Architecture enforced by packages in a pub workspace | Accepted |
| [0002](0002-open-meteo-as-data-source.md) | Open-Meteo as the weather data source | Accepted |
| [0003](0003-flutter-and-riverpod-view-models.md) | Flutter with Material 3; view models as Riverpod Notifiers | Accepted |
| [0004](0004-composition-root-with-riverpod-overrides.md) | Dependency injection: one composition root, Riverpod overrides | Accepted |
| [0005](0005-localization-en-tr-ar.md) | Localization: gen-l10n ARB, `intl`, RTL, language from the OS | Accepted |
| [0006](0006-errors-as-result-values.md) | Errors as values: a sealed `Result` with `DomainError` | Accepted |
| [0007](0007-http-client-and-hand-written-json.md) | Networking: `package:http` and hand-written JSON parsing | Accepted |
| [0008](0008-shared-preferences-storage.md) | Storage: shared_preferences behind a `KeyValueStore` | Accepted |
| [0009](0009-geolocator-for-location.md) | Location: geolocator | Accepted |
| [0010](0010-navigator-for-navigation.md) | Navigation: the SDK's `Navigator`, typed route functions | Accepted |
| [0011](0011-testing.md) | Testing: `package:test`, `flutter_test`, `integration_test`, hand-written fakes | Accepted |
| [0012](0012-static-analysis-and-source-rules.md) | Static analysis: strict analyzer, `flutter_lints`, a custom source check | Accepted |

Template: copy [`template.md`](template.md).
