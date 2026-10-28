# Lists home (change: delete or leave list)

Only the requirements and scenarios introduced by this change. Canonical: [`openspec/specs/lists-home/spec.md`](../../../../specs/lists-home/spec.md).

## Requirements

### Requirement: Delete an owned list

The app SHALL let the user delete a list they own from Lists home. Before deleting, the app SHALL ask for confirmation. After the user confirms, the list SHALL disappear from Lists home and SHALL NOT return on relaunch for that owner.

#### Scenario: User deletes an owned list [tested]

- GIVEN the user owns a list that appears on Lists home
- WHEN the user chooses to delete that list and confirms
- THEN the list is no longer on Lists home
- AND after relaunch the list is still gone for that owner
- **Test:** `ownedDeleteDoesNotPurgeZone()` — [`WifyRadarTests/DeleteOrLeaveListTests.swift`](../../../../WifyRadarTests/DeleteOrLeaveListTests.swift) (confirmation UI `[manual]`)
