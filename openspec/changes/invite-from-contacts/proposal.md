# Proposal: Invite from contacts

## Intent

When sharing a list, let the owner pick the invite recipient from the device Contacts address book instead of typing an Apple ID / iCloud email by hand.

## Scope

Depends on **share-list** (owner Share sheet → email → CloudKit invite → participant accept).

- Request access to Contacts via `CNContactStore` before reading contact data
- Let the owner choose a contact (and email when a contact has more than one)
- Use the selected email as the invite recipient for the existing CloudKit invite path
- Keep manual Apple ID email entry available (including when Contacts access is denied or restricted)
- Document privacy purpose: Contacts are used only to fill the invite email on device
- Specify share-process edge outcomes for invite send and accept (send failure, accept after list deleted or unshare/remove, import timeout, wrong Apple ID opens invite)
- Make **Manage Sharing…** work with an in-app participants UI (system `UICloudSharingController` / Collaboration sheet is unreliable with Core Data + CloudKit — blank “Only people you invite” UI): list participants, remove a participant, stop sharing

## Out of scope

- Ongoing item sync after a share is already accepted (see **share-list**)
- In-app “pending invites” tracking or reminders while an invite is sent but not yet accepted (invite-ready / ShareLink after send is enough; resend via Manage Sharing once it works)
- Relying on `UICloudSharingController` / system Collaboration sheet for manage/unshare
- Specifying owner-delete-list as a Manage Sharing / post-accept remove lifecycle (use stop sharing / remove participant instead); accept failure when the list was deleted before accept remains in scope
- Participant “leave share” UX beyond remove-by-owner
- Participant re-sharing a list they received (CloudKit only lets the share owner administer participants; equality is each person owning and sharing their own lists)
- Uploading, syncing, or storing the address book off-device
- Requiring Contacts access to share a list
- Autocomplete against the full address book without an explicit pick
- Android or non-iOS contacts sources
