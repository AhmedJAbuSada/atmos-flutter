# AGENTS.md — rules for AI coding agents

Read automatically by AI coding agents (Claude Code reads it through `CLAUDE.md`). It is also
a one-page summary for human contributors.

## Project
Atmos is a weather app in **Flutter** (Dart) for Android and iOS, built as a **tutorial**.
Clarity matters more than speed: readers learn from every line. The same app exists natively
for Android and iOS and in React Native; keep the behaviour identical to the product docs.

## Before you write code
1. Read [`docs/PROGRESS.md`](docs/PROGRESS.md): the current step and what is next.
2. Read the step guide in [`docs/steps/`](docs/steps/).
3. Find the user story in [`docs/product/USER_STORIES.md`](docs/product/USER_STORIES.md).
   No story? Ask before building.
4. For anything non-trivial, **write a plan first** and wait for approval.

## Architecture (non-negotiable)
Full rules: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md).

- Packages in one pub workspace: `atmos_domain` ← `atmos_data` and `atmos_presentation`;
  the app (`lib/`, package `atmos`) is the only composition root (ADR-0001, ADR-0004).
- **`atmos_domain` is pure Dart:** no `package:flutter`, no `dart:ui`, no `dart:io`, no http,
  no storage, no Riverpod. Core `dart:` libraries only.
- DTOs never leave `atmos_data`. Widgets never see a DTO or an exception.
- Fallible functions return `Future<Result<T>>`; map every failure to a `DomainError` in
  `atmos_data`; cancellation is `Cancelled` and is never shown (ADR-0006).
- One Riverpod `Notifier` per screen with one sealed state class; views take `state` +
  `onEvent` only (ADR-0003).
- Inject a `DateProvider`; never `DateTime.now()` in logic.

## Decisions already made
- The project owner approved the library ADRs as written on 2026-11-12: Riverpod 3 without
  code generation (ADR-0003), `package:http` (ADR-0007), shared_preferences with its async API
  (ADR-0008), geolocator (ADR-0009), the SDK's `Navigator` (ADR-0010), `integration_test`
  for end-to-end tests (ADR-0011) and `material_ui` (ADR-0013). Do not reopen them without a
  new ADR.

## Code rules
- Follow [`docs/process/CODING_STANDARDS.md`](docs/process/CODING_STANDARDS.md).
- No `!` (null assertion) outside tests. No `dynamic` outside JSON parsing.
- **Never** `toUpperCase()`/`toLowerCase()`: Dart's versions ignore the locale (Turkish `i`).
- No hard-coded user-facing strings: add every key to `app_en.arb`, `app_tr.arb` **and**
  `app_ar.arb`. Translations are AI-written and marked "not reviewed by a native speaker".
- `start` / `end`, never `left` / `right` (`EdgeInsetsDirectional`, `AlignmentDirectional`).
- Every formatted value goes inside directional isolates; Arabic uses Latin digits (ADR-0005).
- The OS owns the app language: no in-app language picker.

## Tests
- Write tests **with** the change, including at least one failure path.
- Data tests use the recorded JSON in [`docs/api/samples/`](docs/api/samples/). Do not
  invent API responses.
- Run before saying "done":
  ```bash
  flutter pub get
  dart format --output=none --set-exit-if-changed .
  dart analyze --fatal-infos
  dart run atmos_source_rules
  tool/test_all.sh
  ```
  The iOS build runs on macOS in CI. If you cannot run something, **say so**. Never claim tests
  pass without running them.

## Git
- Conventional Commits: `feat(search): …`, `fix(l10n): …`, `test(data): …`.
- Small commits, one logical change each.
- Update `docs/PROGRESS.md` at the end of every work session.

## Do not
- Add a dependency (to any `pubspec.yaml`) without an ADR or the owner's explicit approval.
- Add features that are not in the PRD (see its non-goals).
- Commit secrets, keystores, `key.properties`, `local.properties` or signing files.
- Change an accepted ADR: write a new one that supersedes it.
- Disable a lint rule, a source rule or a test to make the build pass. No `// ignore:` to
  silence a finding.

## When unsure
Stop and ask. A question costs one message; a wrong assumption costs a rewrite.
