# Definition of Done

A story or task is **done** only when every box is ticked. This applies equally to code
written by a person and code written by an AI agent.

## Code
- [ ] Meets every acceptance criterion of its user story.
- [ ] Follows the [architecture rules](../architecture/ARCHITECTURE.md) and
      [coding standards](CODING_STANDARDS.md).
- [ ] No hard-coded user-facing strings; every new key added to `app_en.arb`, `app_tr.arb` and
      `app_ar.arb`.
- [ ] `dart format`, `dart analyze --fatal-infos` and `tool/source_rules` pass (including the
      layer, casing and start/end rules).

## Tests
- [ ] Unit tests for new logic, including at least one **failure** path.
- [ ] Existing tests pass locally and in CI.
- [ ] Coverage of `atmos_domain` and `atmos_data` did not drop.

## UI (if the change has UI)
- [ ] Checked in light and dark mode.
- [ ] Checked in **Arabic (RTL)** and **Turkish**.
- [ ] Checked with the largest system font size, on Android and iOS.
- [ ] Loading, empty and error states exist.
- [ ] Screenshots attached to the PR.

## Review
- [ ] PR template filled in.
- [ ] Approved by at least one human reviewer.
- [ ] CI is green.

## Docs
- [ ] README, ADRs or step guide updated if behaviour or decisions changed.
- [ ] `docs/PROGRESS.md` updated.
