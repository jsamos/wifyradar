# Proposal: Invite from contacts

## Intent

When sharing a list, let the owner pick the invite recipient from the device Contacts address book instead of typing an Apple ID / iCloud email by hand.

## Scope

Depends on **share-list** (owner Share sheet → email → CloudKit invite).

- Request access to Contacts via `CNContactStore` before reading contact data
- Let the owner choose a contact (and email when a contact has more than one)
- Use the selected email as the invite recipient for the existing CloudKit invite path
- Keep manual Apple ID email entry available (including when Contacts access is denied or restricted)
- Document privacy purpose: Contacts are used only to fill the invite email on device

## Out of scope

- Changing CloudKit share / accept / sync behavior
- Uploading, syncing, or storing the address book off-device
- Requiring Contacts access to share a list
- Autocomplete against the full address book without an explicit pick
- Android or non-iOS contacts sources
