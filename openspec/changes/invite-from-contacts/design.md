# Design: Invite from contacts

## Architecture

Extends the existing **share-list** owner Share sheet. Today the owner types an Apple ID email; `PersistenceController.invite(emailAddress:to:)` looks up a CloudKit participant and returns an invite URL. This change adds an on-device Contacts path that fills that same email field.

### Contacts access (`CNContactStore`)

1. On “Choose from Contacts” (or equivalent), read `CNContactStore.authorizationStatus(for: .contacts)`.
2. If **not determined**, call `CNContactStore.requestAccess(for: .contacts)` (or the current iOS authorization API for Contacts). Show the system prompt first; do not enumerate contacts beforehand.
3. If **authorized** or **limited**, present a contact/email selection UI backed by Contacts (store-backed list and/or system picker used only after access is granted as required by this change’s permission model).
4. If **denied** or **restricted**, do not open a contacts UI that reads the store; keep the typed-email field; optionally explain that Contacts access can be enabled in Settings.
5. On email selection, set the Share sheet’s invite email field; send invite uses the unchanged CloudKit path.

### Privacy

| Rule | Detail |
|------|--------|
| Purpose | Contacts exist only to help fill the invite recipient email on device |
| Usage string | `NSContactsUsageDescription` in `Config/Info.plist` stating that purpose |
| Minimization | Prefer reading email addresses (and display name for UI) only; do not persist the address book in app storage |
| Exfiltration | No custom backend. Do not upload the contact list. Only the selected email string is passed into the existing CloudKit `shareParticipant(forEmailAddress:)` invite flow |
| Optional | Sharing remains fully usable without granting Contacts |

### Info.plist

- Add `NSContactsUsageDescription` to `Config/Info.plist` (required for `CNContactStore` access).

## Files

| Path | Role |
|------|------|
| `Config/Info.plist` | `NSContactsUsageDescription` |
| `WifyRadar/Lists/ListDetailView.swift` | Share sheet: Contacts action + keep email `TextField` |
| `WifyRadar/Sharing/` (new helper as needed) | Authorization + contact/email selection wired to invite email binding |
| `PersistenceController.invite` | Unchanged; still takes an email string |

## Auth

No in-app account. Contacts permission is separate from iCloud. CloudKit invite still uses the device iCloud account.

## Tests

| Kind | Coverage |
|------|----------|
| Manual | Grant Contacts → pick email → invite sends |
| Manual | Deny Contacts → typed email still works |
| Manual | Contact with multiple emails → chosen email used |
| Automated | Optional unit tests for email extraction / authorization branching if isolated without UI |

## Documentation

### README.md

- Note under sharing / privacy that Contacts access is optional for picking an invite email
- Add behavioral specs table row for `invite-from-contacts`

### Spec scenario tags

- Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md)
- Change: [`openspec/changes/invite-from-contacts/specs/invite-from-contacts/spec.md`](specs/invite-from-contacts/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| First use requests Contacts access | *(manual or unit)* | — |
| Denied access keeps manual email entry | *(manual or unit)* | — |
| Owner picks a contact email | *(manual)* | — |
| Contact with multiple emails | *(manual)* | — |
| Owner types email without Contacts | *(manual)* | — |
| Only selected email leaves the device for invite | *(manual)* | — |
| iCloud.com email resolves and invite succeeds | *(manual)* | — |
| Non-iCloud email that is an Apple ID resolves and invite succeeds | *(manual)* | — |
| Email not associated with an Apple ID fails visibly | *(manual)* | — |
