# Design: Delete or leave list

Amends Lists home delete so private-store vs shared-store lists take different persistence paths. Canonical requirements land in [`lists-home`](../../specs/lists-home/spec.md) and [`invite-from-contacts`](../../specs/invite-from-contacts/spec.md).

## Why bare `context.delete` is wrong for participants

Shared lists live in the **shared** store mirrored from CloudKit. Deleting the `SharedList` managed object does not remove the user from the `CKShare`. The shared database keeps syncing; remote import + history merge can recreate the list. Apple’s guidance for stopping participation with `NSPersistentCloudKitContainer` is to **purge the share’s record zone** in the shared store (`purgeObjectsAndRecordsInZone`), which removes local objects and shared-DB participation for that zone without deleting the owner’s private root.

Owners own the private-store root. Deleting that object (after confirmation) removes the share root for everyone; participants learn via CloudKit + existing history merge (same as revoke live refresh).

## Intended behavior

1. Lists home swipe-delete (or equivalent) still initiates the flow for every list row.
2. Branch on store:
   - **Private store (owner):** confirmation that deletion is permanent (and, when shared, that others lose access) → `context.delete` + save on the owned list (cascade items). Do **not** require a separate Manage Sharing stop first.
   - **Shared store (participant):** confirmation to leave → resolve `CKShare` / zone for the list → `purgeObjectsAndRecordsInZone(with:in: sharedStore)` → UI drops the list via store/history updates. Do **not** use bare `context.delete` as the leave implementation.
3. Suppress persistent-history merge around the leave/purge mutation if needed to avoid racing the UI context (same pattern as invite/remove/stop).
4. On failure (purge or save), show a visible error; do not fail silently.
5. If the user is on list detail when the list disappears (self-leave or owner delete sync), dismiss detail (existing `list.isDeleted` handling).

### Files

| Path | Role |
|------|------|
| `WifyRadar/Lists/ListsHomeView.swift` | Confirm + branch owner delete vs participant leave |
| `WifyRadar/Persistence/PersistenceController.swift` | `deleteOrLeave` orchestration; owned delete; leave via injected purger |
| `WifyRadar/Persistence/SharedZonePurging.swift` (or equivalent) | Small protocol wrapping `purgeObjectsAndRecordsInZone` (same idea as `ContactAuthorizationProviding`) |
| `WifyRadar/Lists/ListDetailView.swift` | Keep dismiss-on-delete (already present) |
| `WifyRadarTests/DeleteOrLeaveListTests.swift` | Mock purger + local Core Data stack; assert call routing |

### Testability (mocks)

Do **not** try to mock CloudKit itself. Mock the **purge boundary**:

1. Introduce a narrow protocol, e.g. `SharedZonePurging`, with one method that mirrors `NSPersistentCloudKitContainer.purgeObjectsAndRecordsInZone(with:in:completion:)`.
2. Production adapter calls through to the real container.
3. Unit tests inject a recording mock and drive `deleteOrLeave` (or equivalent) against a local Core Data stack (no CloudKit container options required for the branch under test):
   - **Owned list (private store)** → deletes the object / saves; **does not** call purge.
   - **Shared list (shared store)** → calls purge once with that list’s share zone id and the shared store; **does not** rely on bare `context.delete` as leave.
   - **Purge failure** → surfaces/throws a visible error path the UI can bind to.
4. Resolving zone id for a shared list may use a test double (`ShareZoneResolving`) if `fetchShares` is awkward offline; keep production wiring thin.

Two-phone “list does not return after sync” and owner-delete-for-everyone remain `[manual]` (live CloudKit).

### Notes

- Participants MUST NOT call `CKShare.removeParticipant` on themselves (CloudKit rejects self-removal); purge is the leave path.
- Owner **Stop Sharing** remains the way to keep the list and drop everyone; owner **delete** destroys the list for the owner too.
- Offline: leave/delete applies when the device can talk to CloudKit; participant “does not reappear” is after successful leave + subsequent syncs.

## Documentation

### README.md

- Extend the sharing blurb: owner delete removes the list for everyone after sync; a participant who deletes/leaves a shared list leaves the share and it does not come back on resync.
- No new behavioral-specs table row (still Lists home + Invite from contacts).

### Spec scenario tags

- Canonical: [`openspec/specs/lists-home/spec.md`](../../specs/lists-home/spec.md), [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md)
- Change: [`openspec/changes/delete-or-leave-list/specs/lists-home/spec.md`](specs/lists-home/spec.md), [`openspec/changes/delete-or-leave-list/specs/invite-from-contacts/spec.md`](specs/invite-from-contacts/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| User deletes an owned list | `ownedDeleteDoesNotPurgeZone()` (+ `[manual]` confirm UI) | [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) |
| Owner deletes a shared list | *(manual)* two-phone | — |
| Participant leaves a shared list | `sharedLeavePurgesZone()` | [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) |
| Left shared list does not return after sync | *(manual)* two-phone | — |
| Leave or delete failure is visible | `purgeFailureSurfacesError()` (+ `[manual]` alert) | [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) |
