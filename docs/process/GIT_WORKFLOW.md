# Git workflow

## Branches

| Branch | Purpose | Rules |
|---|---|---|
| `main` | Always releasable. The complete app at the latest step. | Protected. Changes only through pull requests with green CI. |
| `step-NN-name` | **Tutorial snapshots.** One per level of the project. | Frozen once merged, so readers can check out any level. |
| `feature/<issue>-<short-name>` | Day-to-day work in a real team, for example `feature/12-city-search`. | Short-lived (1–3 days). One feature per branch. |
| `fix/<issue>-<short-name>` | Bug fixes. | Same as feature. |
| `chore/…`, `docs/…` | Tooling and documentation. | Same as feature. |

> **How this repo uses them:** each `step-NN` branch is built on top of the previous one
> and merged into `main` with a merge commit, so `main` has the full history and each step
> branch stays as a frozen snapshot. In a normal product team you would only have `main`
> plus short-lived `feature/` branches.

## Commits: Conventional Commits

```
<type>(<scope>): <summary in imperative mood, ≤ 72 chars>

<body: what and why, not how. Wrap at 72.>

<footer: Refs #12, BREAKING CHANGE: …, Co-Authored-By: …>
```

| Type | Use for |
|---|---|
| `feat` | A new user-visible feature |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `refactor` | Code change with no behaviour change |
| `test` | Adding or fixing tests |
| `build` | pub packages, analysis options, Gradle, CocoaPods |
| `ci` | GitHub Actions |
| `chore` | Anything else (formatting, config) |
| `perf` | Performance |

Scopes match packages or features: `domain`, `data`, `presentation`, `app`, `weather`,
`search`, `settings`, `l10n`.

Examples:
```
feat(search): debounce city search by 300 ms
fix(l10n): use Turkish locale when uppercasing city names
test(data): cover missing "results" key in geocoding response
```

**Small commits.** One logical change per commit. If the summary needs "and", it is
probably two commits.

## Pull requests

1. Open the PR early as a **draft** if you want feedback.
2. Fill in the [PR template](../../.github/pull_request_template.md): what, why, how to
   test, screenshots (light, dark, **Arabic RTL**).
3. CI must be green: build, lint, static analysis, tests.
4. At least **one approving review** from a human. AI review is welcome but does not
   count as the approval (see [AI_WORKFLOW.md](../AI_WORKFLOW.md)).
5. Prefer **squash merge** for `feature/` branches (one clean commit on `main`). This
   tutorial uses merge commits for `step-` branches to keep the snapshots.
6. Delete the feature branch after merging.

## Reviews: what reviewers look for

- Does it follow the [architecture rules](../architecture/ARCHITECTURE.md)? (No DTO in the
  UI, no `package:flutter` import in `atmos_domain`.)
- Are there tests for the new behaviour, including the failure path?
- Is every new string translated (en, tr, ar)?
- Does it work in RTL and dark mode?
- Is it the **simplest** solution that meets the user story?

Comment with a prefix so the author knows the weight: **`nit:`** (optional), **`suggestion:`**,
**`question:`**, **`blocker:`**.

## Versioning

[Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`. Each step is tagged
`v0.N.0`; the finished app is `v1.0.0`.
