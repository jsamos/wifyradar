# Design: Branded scaffold

## Architecture

- Single SwiftUI iOS app target, edited primarily in Cursor, built with Xcode / `xcodebuild`
- One root view: brand name (**wifyradar**) as the hero-level signal, short supporting line, no list UI
- Signing: Automatic Signing with a personal Apple ID team for device installs
- No networking, persistence, or third-party packages

## Files to create

| Path | Role |
|------|------|
| `WifyRadar.xcodeproj/` (or Xcode-generated project layout) | App project |
| App entry + root SwiftUI view | Branded scaffold UI |
| Standard assets / entitlements as generated | Defaults only |

Exact file layout follows whatever `xcodegen`, Xcode “New Project”, or equivalent produces; keep the surface area minimal.

## Auth

None. Device install uses the developer’s Apple ID via Xcode Automatic Signing only.

## Tests

- Manual: Simulator launch shows branded UI
- Manual: Install and launch on two physical iPhones
- Automated tests are optional for this change; no `[tested]` scenarios required

## Documentation

### README.md

- Add a short **Project** / **Run** section: open the Xcode project, select a simulator or device, Run
- Note Automatic Signing / Team selection for physical devices
- Link to the branded-scaffold behavioral spec in a specs table if one is introduced

### Spec scenario tags

- Canonical: [`openspec/specs/branded-scaffold/spec.md`](../../specs/branded-scaffold/spec.md)
- Change: [`openspec/changes/branded-scaffold/specs/branded-scaffold/spec.md`](specs/branded-scaffold/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Branded launch screen appears | *(manual)* | — |
| App builds for Simulator | *(manual)* | — |
| App installs on a personal iPhone | *(manual)* | — |
