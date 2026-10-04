# Share list

Share an existing list with another person and keep items in sync on a second iPhone.

## Requirements

### Requirement: Share a list

The app SHALL let the list owner invite another person to a list using the system share UI (for example via Messages).

#### Scenario: Owner shares a list [manual]

- GIVEN the user owns a list
- WHEN the user chooses Share on that list and sends an invite to another person
- THEN the system share flow completes without an in-app login

### Requirement: Accept and see a shared list

A participant who accepts the share on a second iPhone SHALL see the shared list in the Lists home.

#### Scenario: Participant sees accepted list [manual]

- GIVEN a share invite for a list was sent from phone A
- WHEN the participant accepts the invite on phone B
- THEN the shared list appears in the Lists home on phone B

### Requirement: Ongoing item sync

After a share is accepted, both participants SHALL see new items added to that list after sync (no reshare required).

#### Scenario: Item syncs to the other device [manual]

- GIVEN phones A and B both have access to the same shared list
- WHEN a user adds a text item on phone A
- THEN the item becomes visible on phone B without sending a new share invite
