# Invite from contacts (change: revoke access live refresh)

Only the scenarios modified by this change. Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../../../specs/invite-from-contacts/spec.md).

## Requirements

### Requirement: Manage Sharing

When the owner removes a person or stops sharing, after CloudKit sync on the affected participant’s device (online), that person’s Lists home SHALL update so the list is no longer available there **without requiring an app restart**.

#### Scenario: Owner removes a person [manual]

- GIVEN Manage Sharing lists a person with access
- AND that person can see the shared list on their Lists home
- WHEN the owner chooses Remove for that person
- THEN that person disappears from People with access after the update succeeds
- AND the owner’s list remains on the owner’s device
- AND after CloudKit sync on the removed person’s device (app still in foreground or background, not force-quit)
- THEN that list is no longer on their Lists home (or is no longer openable from Lists home)
- AND an app restart is not required for Lists home to reflect the loss of access

#### Scenario: Owner stops sharing [manual]

- GIVEN Manage Sharing is open for a shared list
- AND a participant can see that list on their Lists home
- WHEN the owner chooses Stop Sharing
- THEN everyone else loses access to the share
- AND the owner’s list remains on the owner’s device
- AND after CloudKit sync on a participant’s device (app still in foreground or background, not force-quit)
- THEN that list is no longer on their Lists home (or is no longer openable from Lists home)
- AND an app restart is not required for Lists home to reflect the loss of access
