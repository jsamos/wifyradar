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

### Accept fails after invite is invalidated (deleted or unshared)

Same visible-error path when the invite is invalidated **before** accept:

| Cause | Owner action before participant accepts |
|-------|----------------------------------------|
| List deleted | Owner deletes the shared list |
| List unshared / invitee removed | Owner stops sharing or removes the pending invitee in Manage Sharing (list may still exist for the owner) |

System-level failures that never reach the app (for example invitee offline before Open) are outside this UI path. Post-accept “owner deletes list” as a remove lifecycle is not specified here — use stop sharing / remove participant for that.

#### Flow

1. Participant opens invite → `ShareNavigationStore.isOpeningSharedList = true` (finding-list interstitial).
2. `PersistenceController.acceptShare(metadata:)` throws because CloudKit no longer has a valid share (list deleted, or share stopped / invitee removed).
3. Keep the finding-list screen up (`isOpeningSharedList` stays true).
4. Set `acceptErrorMessage` on `ShareNavigationStore` and retain `CKShare.Metadata` for retry (same path when accept throws **or** the imported list never appears after the wait window).
5. `ShareInviteLoadingView` switches to an error state on that same full-screen UI: “Couldn’t open this share”, detail message, **Retry** and **Go to Lists**.
6. **Retry** clears the error message and re-runs `ShareAcceptance.handle` with retained metadata.
7. **Go to Lists** clears accept/opening state and reveals Lists home.

Do not dismiss to home with no explanation. Do not rely on a separate home alert as the primary failure UI.

#### State

| Store field (illustrative) | Role |
|----------------------------|------|
| `isOpeningSharedList` | Finding-list interstitial (unchanged success path) |
| `acceptErrorMessage` (or equivalent) | Non-nil → show visible accept failure UI |
| Retained `CKShare.Metadata` (or accept retry token) | Needed so Retry can call accept again without re-opening the invite link |

#### UI

- Prefer a system alert on Lists home while the share sheet / detail are not involved (accept lands at app root).
- Retry must be available without forcing the user to find the invite message again when metadata is still in memory for this session.

#### Files (accept-failure)

| Path | Role |
|------|------|
| `WifyRadar/Sharing/CloudKitShareAcceptBridge.swift` | On accept `catch`: set visible error + retain metadata; stop print-only handling |
| `WifyRadar/Sharing/ShareNavigationStore` (same file) | Hold accept error + retry metadata; clear on OK / successful open |
| `WifyRadar/Sharing/ShareInviteLoadingView.swift` | Loading + failure states on the finding-list screen; Retry / Go to Lists |
| `WifyRadar/Lists/ListsHomeView.swift` | Hosts the finding-list overlay while `isOpeningSharedList` |

### Manage Sharing

System `UICloudSharingController` / Collaboration UI presents a share sheet where **Only people you invite have access** opens a **blank** sheet with Core Data + CloudKit. Manage Sharing therefore uses an **in-app** screen over `CKShare` APIs.

#### Intended behavior

1. Share sheet shows **Manage Sharing…** only when `hasPeopleWithAccess` (at least one non-owner participant).
2. Owner taps Manage Sharing… → dismiss Share sheet → present `ManageSharingView`.
3. Load existing `CKShare` only (do not create a share); list non-owner `participants`.
4. **Remove** → `share.removeParticipant` + `persistUpdatedShare` (keeps owner’s list).
5. **Stop Sharing** → remove all non-owner participants + `persistUpdatedShare` (keeps owner’s list; does not purge the share zone).
6. Errors surface via the existing “Couldn’t share list” alert.

#### Files (Manage Sharing)

| Path | Role |
|------|------|
| `WifyRadar/Lists/ListDetailView.swift` | Manage Sharing… → in-app sheet |
| `WifyRadar/Sharing/ManageSharingView.swift` | Participants list, remove, stop sharing |
| `PersistenceController` | `participants`, `removeParticipant`, `stopSharing` |

## Files

| Path | Role |
|------|------|
| `Config/Info.plist` | `NSContactsUsageDescription` |
| `WifyRadar/Lists/ListDetailView.swift` | Share sheet: Contacts action + keep email `TextField`; Manage Sharing… |
| `WifyRadar/Sharing/` (new helper as needed) | Authorization + contact selection; dedicated in-app email-list sheet when a contact has multiple emails |
| `PersistenceController.invite` | Unchanged; still takes an email string |
| `WifyRadar/Sharing/CloudKitShareAcceptBridge.swift` | Accept failure → visible error + Retry (see above) |
| `WifyRadar/Lists/ListsHomeView.swift` | Show accept-failure alert |
| `WifyRadar/Sharing/ManageSharingView.swift` | In-app Manage Sharing UI |

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
| Owner sees Share on a list they own | *(manual)* | — |
| Recipient does not see Share on a list shared with them | *(manual)* | — |
| Owner opens Share sheet before anyone has access | *(manual)* | — |
| Owner opens Share sheet when someone has access | *(manual)* | — |
| Owner opens Manage Sharing | *(manual)* | — |
| People with access lists invitees only | *(manual)* | — |
| Owner removes a person | *(manual)* | — |
| Owner stops sharing | *(manual)* | — |
| Owner can invite again after stopping sharing | *(manual)* | — |
| Either person can share lists they own | *(manual)* | — |
| Manage Sharing fails with a visible error | *(manual)* | — |
| List deleted before accept | *(manual)* | — |
| List unshared before accept | *(manual)* | — |
| Retry after accept failure | *(manual)* | — |
| Go to Lists after accept failure | *(manual)* | — |
| Import is slow then succeeds | *(manual)* | — |
| Import never arrives after accept | *(manual)* | — |
| Owner opens their own invite link | *(manual)* | — |
