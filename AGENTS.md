# Agent Instructions

This repo is a **Swift / SwiftUI iOS** app (**wifyradar**), developed primarily in **Cursor**, built and signed with **Xcode**.

The first time I ask for a new feature in a session, familiarize yourself with the conventions of this codebase. Review `README.md` and `openspec/specs/`. Tell me when you have done the review before proposing anything.

## Documentation tone

Project docs (`README.md`, OpenSpec, comments meant for readers) MUST be written for a generic reader of the repo. Do **not** include meta remarks from our conversation — transitions that only make sense in chat, “as we discussed,” machine-specific check results, or bridging lines that restate the next heading (e.g. “Command Line Tools alone are not enough… continue with Xcode below”). State facts and steps; let section order carry the flow.

## Xcode / platform facts agents may not know

Training data may predate current Apple tooling. Prefer the installed toolchain over older assumptions. Document only versions and components actually present on the machine — do not treat unreleased or next-major Xcode marketing as the project baseline.

Use Xcode for the iOS toolchain (build, Simulator, device install, signing), not as the primary editor.

### Toolchain (installed)

- Baseline toolchain is **Xcode 27.1** with platform SDKs such as **iOS 27.1** / **macOS 27.0** (Swift **6.4**). Confirm with `xcodebuild -version` and the selected platforms in Xcode’s component installer. Upgrade notes: [`docs/system-upgrade-27.1.md`](docs/system-upgrade-27.1.md).
- An iOS app needs the **iOS** platform component installed (not only macOS, which may be marked built-in). watchOS / tvOS / visionOS are optional and unused here unless a feature needs them.
- Do not assume Xcode 16.x / Swift 5.x / iOS 18-era defaults when choosing APIs; match the project’s deployment target and the SDK reported by `xcodebuild`.
- From Cursor, drive builds/tests/simulators via **`xcodebuild`**, **`xcrun simctl`**, and related CLI.

## New Features

Before building a new feature or integration, write specs first in `openspec/`:

1. **Proposal** (`openspec/changes/<name>/proposal.md`) — Intent, scope, and out-of-scope boundaries.
2. **Behavioral spec** (`openspec/specs/<name>/spec.md`) — Requirements and scenarios using RFC 2119 keywords (SHALL, MUST, MAY).
3. **Design** (`openspec/changes/<name>/design.md`) — Architecture, files to modify, auth, documentation, and tests. **Must include a `## Documentation` section** (see below).

Also include a spec in the change folder at `openspec/changes/<name>/specs/<name>/spec.md`.

| Path | Purpose |
|------|---------|
| `openspec/specs/<name>/spec.md` | **Canonical** — long-lived source of truth for all implemented behavior |
| `openspec/changes/<name>/specs/<name>/spec.md` | **Change spec** — only the requirements and scenarios introduced or modified by this change |

When a change adds to an existing canonical spec, the change spec contains only the new/modified sections — not a full copy. When a change creates a brand-new spec, the change spec and canonical spec start identical. The canonical spec grows over time; archived change specs stay frozen as a record of what each change introduced.

When the feature ships, move `openspec/changes/<name>/` to `openspec/changes/archive/`. The canonical spec stays in `openspec/specs/`. Later amendments update only the canonical spec unless a new change folder is opened.

**Before committing**, archive any in-progress change folder whose feature is fully implemented in that commit. Update the canonical spec with any new tags or test links, then `mv` the folder to `openspec/changes/archive/<date>-<name>/`. Include the archive move in the same commit as the implementation.

Scenario tags:

| Tag | When to use |
|-----|-------------|
| `[tested]` | An automated test **directly asserts the scenario's WHEN/THEN** — not merely related code in the same file or feature area. |
| `[manual]` | True end-to-end behavior that cannot run in CI (e.g. install on a personal iPhone, live CloudKit with real Apple IDs). |
| *(untagged)* | Planned or partially implemented; not yet verified. |

**`[tested]` requirements:**

1. **Name the scenario in the test** — use a comment (`// Scenario: …`) or a `@Test` function name / display name that matches the spec scenario heading so reviewers can trace spec ↔ test.
2. **Exercise the WHEN** — call the function, type, or code path the scenario describes.
3. **Assert the THEN** — check outputs, thrown errors, side effects, or call order exactly as the spec states (`#expect` / `try #require` in Swift Testing).
4. **One scenario, one primary test** — a single test may cover multiple assertions for the same scenario; do not mark a scenario `[tested]` because a nearby scenario in the same module is tested.

**Do not mark `[tested]` when:**

- Coverage is only indirect (e.g. "happy path runs" but the scenario is about a specific edge case).
- The test only reads static markdown **without a parser or structured assertion** (a bare string contains check is not enough).
- The spec and implementation diverge (fix the spec or the code first, then tag).

When adding `[tested]`, add or update the test in the same change. When removing behavior, remove the tag or delete the scenario.

Each change **`design.md` MUST include a `## Documentation` section** with:

1. **`README.md`** — bullet list of what to add or update for this feature (sections, examples, behavioral specs table). Do not duplicate full README prose in the design; list the targets.
2. **Spec scenario tags** — links to both spec copies for this change, plus a **scenario → test mapping** table (scenario name, `@Test` name to fill at ship time, test file link).

When implementation and tests land, follow the tag rules below **and** complete the Documentation checklist in that change's `design.md` (README updates, tag both spec copies, fill in the mapping table).

**Spec tagging rules** (apply when shipping; paths for each change live in its `design.md`):

| Path | Purpose |
|------|---------|
| `openspec/specs/<name>/spec.md` | Canonical — add tags and test links here first |
| `openspec/changes/<name>/specs/<name>/spec.md` | Change spec — only the new/modified requirements and scenarios from this change |

For each `[tested]` scenario, add a **Test** line with the exact `@Test` name (or suite name when the whole suite maps to one scenario) and a markdown link to the test file:

```markdown
#### Scenario: Example behavior [tested]

- GIVEN …
- WHEN …
- THEN …
- **Test:** `exampleBehavior()` — [`WifyRadarTests/ExampleTests.swift`](../../../WifyRadarTests/ExampleTests.swift)
```

Use paths relative to the spec file so links resolve from `openspec/specs/<name>/` (typically `../../../WifyRadarTests/…`) or `openspec/changes/<name>/specs/<name>/` (typically `../../../../WifyRadarTests/…`).

Do not mark a scenario `[tested]` until the linked test exists and asserts the THEN. Use `[manual]` only when CI coverage is genuinely impossible — not as a shortcut for skipped tests.

Commit the specs before writing any implementation code.

## Tests

Prefer **Swift Testing** (`@Test`, `#expect`, `try #require`) for new unit tests. Use XCTest only when required (e.g. UI automation with `XCUIApplication`).

When a test target exists, run the full suite before committing any change:

```bash
xcodebuild test -scheme WifyRadar -destination 'platform=iOS Simulator,name=iPhone 17'
```

Adjust the scheme or destination if the project’s simulators differ. All tests must pass. Do not commit if tests fail. Fix the failing tests first.

Until a test target exists, rely on OpenSpec `[manual]` scenarios and `docs/` for verification (Simulator launch, personal device install).

**Rule of thumb:** if the change affects app behavior or logic users rely on — new output, different format, new rules — add or update automated tests when that logic can run under `xcodebuild test`. Mock external services when testing those flows; don't skip tests just because the code path involves an external call.

**Mock fidelity:** When wrapping an external API, capture the real response format before writing parsers or tests. Run the integration once (script or manual call), log the raw response, and base parsers and test mocks on that actual output — not on assumptions about the format. Speculative mocks that match the parser rather than reality will pass tests but hide bugs.
