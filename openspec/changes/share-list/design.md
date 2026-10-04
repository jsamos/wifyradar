# Design: Share list

## Architecture

- Builds on **lists-home** SwiftData models and UI
- Turn on CloudKit for the model container (private DB + sharing)
- Share via system UI (`UICloudSharingController` / SwiftUI equivalent) → `CKShare`
- Identity = device iCloud accounts; no login screens
- App capabilities: iCloud + CloudKit container

## Files to modify / add

| Area | Role |
|------|------|
| Model container | CloudKit-enabled configuration |
| Entitlements / Signing | iCloud & CloudKit capability |
| Share entry point | Share action on an owned list |
| Accept path | Handle incoming share so list appears on Lists home |

## Auth

None in-app. Both devices must be signed into iCloud.

## Tests

| Kind | Coverage |
|------|----------|
| Manual | Share from phone A; accept on B; list visible on B |
| Manual | Add item on A; visible on B (no new invite) |
| Automated | Not required for invite path |

## Documentation

### README.md

- Note iCloud requirement for sharing
- Link the share-list behavioral spec
- Optional short `docs/` checklist for the two-phone share demo

### Spec scenario tags

- Canonical: [`openspec/specs/share-list/spec.md`](../../specs/share-list/spec.md)
- Change: [`openspec/changes/share-list/specs/share-list/spec.md`](specs/share-list/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Owner shares a list | *(manual)* | — |
| Participant sees accepted list | *(manual)* | — |
| Item syncs to the other device | *(manual)* | — |
