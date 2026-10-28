# Proposal: Delete or leave list

## Intent

Deleting a list from Lists home MUST mean different things for the **owner** and a **participant**. Today both paths call `context.delete` + save. For a participant that only clears the local shared mirror while they remain on the `CKShare`, so CloudKit can bring the list back. Fix both roles.

## Scope

Amends **lists-home** (delete affordance) and **invite-from-contacts** (shared-list lifecycle). Depends on **share-list** private/shared stores and existing persistent-history merge for live UI updates.

1. **Owner deletes an owned list** (private store) — after confirmation, the list is removed for the owner; if it was shared, participants lose access after CloudKit sync without requiring an app restart (same live-refresh expectation as remove/stop).
2. **Participant leaves a shared list** (shared store) — after confirmation, the app stops participation via the Core Data CloudKit leave path (`purgeObjectsAndRecordsInZone` for that share’s zone in the shared store), not a bare local delete. The list MUST NOT reappear on the next sync. The owner’s list remains.

## Out of scope

- Soft delete / trash / undo beyond the confirmation step
- A separate “Leave” button on list detail (Lists home delete/leave is enough for this change)
- Changing Manage Sharing Remove / Stop Sharing (list stays for the owner)
- Guaranteeing updates while a device is offline (CloudKit must deliver)
- Multi-participant edge cases beyond “each affected participant loses the list when the owner deletes”
