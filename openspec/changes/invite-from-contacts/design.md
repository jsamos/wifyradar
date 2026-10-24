# Design: Invite from contacts

## Architecture

Extends the existing **share-list** owner Share sheet. Today the owner types an Apple ID email; `PersistenceController.invite(emailAddress:to:)` looks up a CloudKit participant and returns an invite URL. This change adds an on-device Contacts path that fills that same email field.

### Contacts access (`CNContactStore`)

1. On “Choose from Contacts” (or equivalent), read `CNContactStore.authorizationStatus(for: .contacts)`.
2. If **not determined**, call `CNContactStore.requestAccess(for: .contacts)` (or the current iOS authorization API for Contacts). Show the system prompt first; do not enumerate contacts beforehand.
3. If **authorized** or **limited**, present a contact selection UI backed by Contacts (store-backed list and/or system picker used only after access is granted as required by this change’s permission model).
4. If the chosen contact has **exactly one** email, put that email in the Share sheet’s invite field.
5. If the chosen contact has **more than one** email, present a **dedicated in-app screen or sheet** (not email property selection inside `CNContactPickerViewController`) that lists that contact’s email addresses; the owner taps one email, which fills the Share sheet’s invite email field. Send invite uses the unchanged CloudKit path.
6. If **denied** or **restricted**, do not open a contacts UI that reads the store; keep the typed-email field; optionally explain that Contacts access can be enabled in Settings.

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
| `WifyRadar/Sharing/` (new helper as needed) | Authorization + contact selection; dedicated in-app email-list sheet when a contact has multiple emails |
| `PersistenceController.invite` | Unchanged; still takes an email string |

## Auth

No in-app account. Contacts permission is separate from iCloud. CloudKit invite still uses the device iCloud account.

## Tests

| Kind | Coverage |
|------|----------|
| Manual | Grant Contacts → pick email → invite sends |
| Manual | Deny Contacts → typed email still works |
| Manual | Contact with multiple emails → chosen email used |
| Automated | `ContactEmailSelectionTests`, `ContactInviteAccessTests` (mocked authorization provider) |

## Documentation

### README.md

- Note under sharing / privacy that Contacts access is optional for picking an invite email
- Add behavioral specs table row for `invite-from-contacts`

### Spec scenario tags

- Canonical: [`openspec/specs/invite-from-contacts/spec.md`](../../specs/invite-from-contacts/spec.md)
- Change: [`openspec/changes/invite-from-contacts/specs/invite-from-contacts/spec.md`](specs/invite-from-contacts/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| First use requests Contacts access | `notDeterminedRequestsThenProceeds()` (branch unit) + `[manual]` prompt | [`WifyRadarTests/ContactInviteAccessTests.swift`](../../../../WifyRadarTests/ContactInviteAccessTests.swift) |
| Denied access keeps manual email entry | `deniedKeepsTypedEmail()` (branch unit) + `[manual]` typed send | [`WifyRadarTests/ContactInviteAccessTests.swift`](../../../../WifyRadarTests/ContactInviteAccessTests.swift) |
| Owner picks a contact email | `oneEmailFillsField()` (selection unit) + `[manual]` end-to-end | [`WifyRadarTests/ContactEmailSelectionTests.swift`](../../../../WifyRadarTests/ContactEmailSelectionTests.swift) |
| Contact with multiple emails | `manyEmailsPresentChoices()` (selection unit) + `[manual]` sheet | [`WifyRadarTests/ContactEmailSelectionTests.swift`](../../../../WifyRadarTests/ContactEmailSelectionTests.swift) |
| Owner types email without Contacts | *(manual)* | — |
| Only selected email leaves the device for invite | *(manual)* | — |
| iCloud.com email resolves and invite succeeds | *(manual)* | — |
| Non-iCloud email that is an Apple ID resolves and invite succeeds | *(manual)* | — |
| Email not associated with an Apple ID fails visibly | *(manual)* | — |
