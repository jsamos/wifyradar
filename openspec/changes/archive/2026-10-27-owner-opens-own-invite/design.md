# Design: Owner opens own invite

Amends the share-accept path in **invite-from-contacts** / **share-list**. Canonical behavior lives in [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md).

## Owner opens own invite

`CKShare.Metadata` identifies whether the current user is already the share **owner**. Opening the invite while signed into that Apple ID must not look like a broken participant import.

### Intended behavior

1. System delivers share metadata → `ShareAcceptance.handle(metadata)`.
2. If the metadata indicates the current user is the share **owner** (for example `participantType == .owner`):
   - Do **not** call `acceptShare` as a participant import.
   - Find the existing `SharedList` in the private store (match `hierarchicalRootRecordID` via `recordID(for:)` when available).
   - Set `pendingListURI` so Lists home navigates to that list’s detail.
   - Surface a short owner indication (for example alert or interstitial copy: already the owner / already on this list) before or as the list opens — not the accept-failure “Couldn’t open this share” path with no explanation.
3. If the list cannot be resolved locally, show a visible error (same interstitial family is fine) — do not hang forever on “finding list” with no message.
4. Non-owner metadata continues on the existing accept → import → open (or accept-failure) path unchanged.

### Files

| Path | Role |
|------|------|
| `WifyRadar/Sharing/CloudKitShareAcceptBridge.swift` | Owner branch in `ShareAcceptance.handle`; resolve existing list without `acceptShare` |
| `WifyRadar/Sharing/ShareNavigationStore` (same file) | Optional flag/message for owner indication; reuse `pendingListURI` / interstitial |
| `WifyRadar/Sharing/ShareInviteLoadingView.swift` | Owner indication copy if shown on the finding-list UI |
| `WifyRadar/Lists/ListsHomeView.swift` | Unchanged host of overlay / navigation unless alert is presented here |

### Notes

- Prefer detecting owner from metadata **before** accept; do not rely on accept throwing.
- Do not create a second copy of the list on the owner device (`docs/icloud-sharing-plan.md`).

## Documentation

### README.md

- No new behavioral-specs table row (still covered by [Invite from contacts](../../specs/invite-from-contacts/spec.md)).
- Optional: one sentence under the Contacts / sharing blurb that opening your own invite link opens the existing list as owner.

### Spec scenario tags

- Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md)
- Change: [`openspec/changes/owner-opens-own-invite/specs/invite-from-contacts/spec.md`](specs/invite-from-contacts/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Owner opens their own invite link | *(manual)* | — |
