# Invite from contacts (change: delete or leave list)

Only the requirements and scenarios introduced or modified by this change. Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../../../specs/invite-from-contacts/spec.md).

## Requirements

### Requirement: Owner deletes a shared list

When the owner deletes a list they own that is (or was) shared, after CloudKit sync on each participant’s device the list SHALL no longer be available on that participant’s Lists home **without requiring an app restart**. The owner’s copy SHALL be gone as well (unlike Stop Sharing, which keeps the owner’s list).

#### Scenario: Owner deletes a shared list [manual]

- GIVEN the owner has shared a list with at least one participant who can see it on Lists home
- WHEN the owner deletes that list from Lists home and confirms
- THEN the list is gone from the owner’s Lists home
- AND after CloudKit sync on a participant’s device (app still in foreground or background, not force-quit)
- THEN that list is no longer on their Lists home (or is no longer openable from Lists home)
- AND an app restart is not required for Lists home to reflect the loss of access

### Requirement: Participant leaves a shared list

A participant SHALL be able to leave a shared list from Lists home (same delete affordance as owned lists, with leave-specific confirmation). Leaving SHALL stop participation using the shared-store CloudKit leave path (zone purge), not a local-only delete that remains subscribed to the share. After a successful leave, the list SHALL NOT reappear on that participant’s Lists home after later CloudKit sync. The owner’s list SHALL remain on the owner’s device. Leave or delete failures SHALL surface a visible error (not a silent no-op).

#### Scenario: Participant leaves a shared list [tested]

- GIVEN the user is a participant on a shared list (shared store) visible on Lists home
- WHEN the user chooses to delete/leave that list and confirms
- THEN the list disappears from that user’s Lists home
- AND the owner still has the list on the owner’s device
- **Test:** `sharedLeavePurgesZone()` — [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) (owner-side THEN and confirm UI `[manual]`)

#### Scenario: Left shared list does not return after sync [manual]

- GIVEN a participant successfully left a shared list
- AND both devices are online so CloudKit can sync
- WHEN time passes or the app receives remote store updates (no force-quit required)
- THEN that list does not reappear on the participant’s Lists home

#### Scenario: Leave or delete failure is visible [tested]

- GIVEN the user tries to delete an owned list or leave a shared list
- WHEN the persistence operation fails
- THEN the user sees a visible error
- AND the failure is not only a silent no-op
- **Test:** `purgeFailureSurfacesError()` — [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) (alert presentation `[manual]`)
