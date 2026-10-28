# Design: Revoke access live refresh

Amends participant-side UI after owner remove/stop. Canonical scenarios live in [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md).

## Why item sync already feels live

Item edits are CloudKit **record field** updates on objects the UI already observes. Share revoke is a **membership / zone** change that deletes or drops shared objects locally; Lists home does not reliably refresh until process restart unless the view context merges those store updates.

## Intended behavior

1. Store descriptions already set history tracking + `NSPersistentStoreRemoteChangeNotificationPostOptionKey` (share-list).
2. Observe `NSPersistentStoreRemoteChange` on the persistent store coordinator.
3. On each notification, **consume persistent history** since the last saved token on a background context, then `mergeChanges(fromContextDidSave:)` into `viewContext` via each transaction’s `objectIDNotification()` — **not** `refreshAllObjects()`.
4. Suppress history merges while local share mutations run (`invite` / `removeParticipant` / `stopSharing` + `persistUpdatedShare`) so owner Manage Sharing is not racing the UI context.
5. After CloudKit sync with both devices online, the revoked list disappears from Lists home (or is no longer openable) **without** force-quitting the app.
6. If the participant is mid-detail when the list is deleted locally, dismiss detail.

Owner path stays: `removeParticipant` / `stopSharing` + `persistUpdatedShare`, with live participant matching on the current `CKShare`.

### Files

| Path | Role |
|------|------|
| `WifyRadar/Persistence/PersistentHistoryMerger.swift` | Tokened history fetch + merge into view context |
| `WifyRadar/Persistence/PersistenceController.swift` | Remote-change observer; suppress around share mutations |
| `WifyRadar/Sharing/ShareParticipantMatching.swift` | Match remove target on the live share |
| `WifyRadar/Sharing/ManageSharingView.swift` | Surface remove/stop errors on the sheet |
| `WifyRadar/Lists/ListDetailView.swift` | Dismiss when list is deleted |

### Notes

- Do not use blanket `refreshAllObjects()` for revoke refresh.
- Do not add `BGTaskScheduler` identifiers for Core Data’s internal CloudKit activity IDs.
- Offline participant: update when they next sync; no restart required once import lands.

## Documentation

### README.md

- No new behavioral-specs table row (still [Invite from contacts](../../specs/invite-from-contacts/spec.md)).
- Optional: note that unshare/remove updates the other person’s Lists home after iCloud sync without relaunching.

### Spec scenario tags

- Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md)
- Change: [`openspec/changes/revoke-access-live-refresh/specs/invite-from-contacts/spec.md`](specs/invite-from-contacts/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Owner removes a person | `mergeAppliesDeletes()` / `suppressedMergeDoesNotApply()` + matching unit tests; end-to-end remains `[manual]` | [`WifyRadarTests/PersistentHistoryMergerTests.swift`](../../../../WifyRadarTests/PersistentHistoryMergerTests.swift), [`WifyRadarTests/ShareParticipantMatchingTests.swift`](../../../../WifyRadarTests/ShareParticipantMatchingTests.swift) |
| Owner stops sharing | *(manual)* | — |
