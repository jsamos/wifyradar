# Invite from contacts (change: owner opens own invite)

Only the requirement and scenario modified by this change. Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../../../specs/invite-from-contacts/spec.md).

## Requirements

### Requirement: Share invite process outcomes

When the current user opens a share invite and CloudKit metadata indicates they are already the **owner** of that share, the app SHALL open the existing list on that device and indicate they are already the owner (or already on this list). The app MUST NOT run the participant accept/import failure path as if the share could not be opened with no owner-specific explanation.

#### Scenario: Owner opens their own invite link [manual]

- GIVEN a share invite was created by the list owner
- WHEN the owner opens that invite while signed into the owner Apple ID
- THEN the app detects that the current user is the share owner without treating this as a failed participant import
- AND the app indicates the user is already on this list (or already the owner)
- AND the app opens the existing list’s detail screen
