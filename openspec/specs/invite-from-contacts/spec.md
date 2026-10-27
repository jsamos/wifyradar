# Invite from contacts

Let the list owner choose a share-invite recipient from Contacts after granting Contacts access, while still allowing typed Apple ID email entry.

## Requirements

### Requirement: Contacts permission before reading contacts

Before the app reads contact records from `CNContactStore`, it SHALL obtain Contacts authorization. The app SHALL present the system permission prompt when status is not determined, using a privacy usage description that states Contacts are used only to pick an invite recipient email on device.

#### Scenario: First use requests Contacts access [manual]

- GIVEN the owner opens Share on a list they own
- AND Contacts authorization status is not determined
- WHEN the owner chooses to pick a recipient from Contacts
- THEN the system Contacts permission prompt is shown before contact data is read

#### Scenario: Denied access keeps manual email entry [manual]

- GIVEN Contacts authorization is denied or restricted
- WHEN the owner opens Share on a list they own
- THEN the owner can still type an Apple ID email and send an invite
- AND the app does not read contact records from `CNContactStore`

### Requirement: Select recipient email from Contacts

When Contacts access is authorized (or limited), the app SHALL let the owner select a contact and SHALL place a chosen email in the invite recipient field used by the existing share-invite flow. When the contact has more than one email, the app SHALL present a dedicated in-app screen or sheet that lists that contact’s email addresses for the owner to tap; that selection MUST NOT rely on email property picking inside `CNContactPickerViewController`.

#### Scenario: Owner picks a contact email [manual]

- GIVEN Contacts access is authorized
- AND the owner is on the Share sheet for a list they own
- WHEN the owner picks a contact that has an email address
- THEN that email appears in the invite recipient field
- AND the owner can send the invite using the existing CloudKit invite path

#### Scenario: Contact with multiple emails [manual]

- GIVEN Contacts access is authorized
- AND the owner selects a contact with more than one email address
- WHEN the app presents a dedicated in-app screen or sheet listing that contact’s email addresses (not email selection inside `CNContactPickerViewController`)
- AND the owner taps one email in that list
- THEN that chosen email fills the Share sheet’s invite email field
- AND that email is used as the invite recipient

### Requirement: Manual email entry remains available

The app SHALL continue to allow the owner to type an Apple ID / iCloud email without using Contacts.

#### Scenario: Owner types email without Contacts

- GIVEN the owner is on the Share sheet for a list they own
- WHEN the owner types an Apple ID email without picking a contact
- THEN the invite can be sent using that typed email

### Requirement: Privacy of contact data

The app SHALL use Contacts data only on-device to fill the invite recipient email. The app MUST NOT upload the address book or contact list to a custom server. Only the selected email string MAY be sent to CloudKit as part of the existing invite participant lookup.

#### Scenario: Only selected email leaves the device for invite

- GIVEN the owner selected a contact email for an invite
- WHEN the invite is created
- THEN CloudKit receives that email for participant lookup
- AND the app does not transmit other contact fields or the full address book to a custom backend

### Requirement: CloudKit resolves invitee by Apple ID association

When sending a share invite, the app SHALL pass the recipient email to CloudKit participant lookup (`shareParticipant(forEmailAddress:)`). Success depends on whether that email is associated with an Apple ID / iCloud account — not on the email domain alone (for example, a Gmail address MAY be a valid Apple ID). Failure to resolve a participant is expected behavior and SHALL surface to the owner; it MUST NOT succeed silently.

#### Scenario: iCloud.com email resolves and invite succeeds [manual]

- GIVEN the owner is sending a share invite
- AND the recipient email is an `icloud.com` address associated with an Apple ID
- WHEN the owner sends the invite
- THEN CloudKit resolves the participant
- AND the invite completes so the owner can send the invite link

#### Scenario: Non-iCloud email that is an Apple ID resolves and invite succeeds [manual]

- GIVEN the owner is sending a share invite
- AND the recipient email is a non-iCloud address (for example `gmail.com`) that is associated with an Apple ID
- WHEN the owner sends the invite
- THEN CloudKit resolves the participant
- AND the invite completes so the owner can send the invite link

#### Scenario: Email not associated with an Apple ID fails visibly [manual]

- GIVEN the owner is sending a share invite
- AND the recipient email is not associated with any Apple ID
- WHEN the owner sends the invite
- THEN CloudKit fails to resolve the participant
- AND the owner sees the “Couldn’t share list” alert with an explanation that the address must be an Apple ID email
- AND the invite does not complete as a silent success

### Requirement: Manage Sharing

**Ownership model:** The CloudKit share **owner** is the iCloud user who created the list (private store). Only that owner sees **Share** on list detail and can invite, open Manage Sharing, remove people, or stop sharing for **that** list. A **participant** who accepted the share can view/edit items; they MUST NOT see Share (and therefore have no Manage Sharing experience) on that list. Equality between two people is achieved by **each owning their own lists** and inviting the other.

The list owner SHALL see a **Share** control on list detail for lists they own and open a Share sheet from it. **Manage Sharing…** SHALL appear on that sheet only when at least one other person has access (invited or accepted). From Manage Sharing the owner can view who has access, remove a person, and stop sharing. A participant MUST NOT see Share on a list they only accepted. The app MUST NOT rely on the system Collaboration / `UICloudSharingController` manage UI for manage actions. Failures to load or update sharing SHALL surface a visible error (not a silent no-op).

#### Scenario: Owner sees Share on a list they own [manual]

- GIVEN the user created a list (list is in the private store)
- WHEN they open that list’s detail
- THEN a Share control is visible

#### Scenario: Recipient does not see Share on a list shared with them [manual]

- GIVEN the user is a participant on a list they did not create (shared store)
- WHEN they open that list’s detail
- THEN the Share control is not shown at all
- AND there is no path to Manage Sharing for that list
- AND they can still view and edit items

#### Scenario: Owner opens Share sheet before anyone has access [manual]

- GIVEN the user owns a list and no one else has been invited
- WHEN the owner taps Share
- THEN the Share sheet appears for that list
- AND the owner can send an invite
- AND Manage Sharing… is not available

#### Scenario: Owner opens Share sheet when someone has access [manual]

- GIVEN the user owns a list and at least one other person has been invited or has accepted
- WHEN the owner taps Share
- THEN the Share sheet appears for that list
- AND the owner can send an invite
- AND Manage Sharing… is available

#### Scenario: Owner opens Manage Sharing [manual]

- GIVEN the owner is on the Share sheet and Manage Sharing… is available
- WHEN the owner chooses Manage Sharing…
- THEN an in-app Manage Sharing screen appears for that list

#### Scenario: People with access lists invitees only [manual]

- GIVEN the owner has shared the list with at least one other person
- WHEN the owner opens Manage Sharing…
- THEN People with access lists those invitees or participants
- AND the owner is not listed

#### Scenario: Owner removes a person [manual]

- GIVEN Manage Sharing lists a person with access
- WHEN the owner chooses Remove for that person
- THEN that person disappears from People with access after the update succeeds
- AND the owner’s list remains on the owner’s device
- AND after CloudKit sync that person no longer has access to the list

#### Scenario: Owner stops sharing [manual]

- GIVEN Manage Sharing is open for a shared list
- WHEN the owner chooses Stop Sharing
- THEN everyone else loses access to the share
- AND the owner’s list remains on the owner’s device

#### Scenario: Owner can invite again after stopping sharing [manual]

- GIVEN the owner previously stopped sharing a list via Manage Sharing…
- WHEN the owner uses the Share sheet Send Invite flow again for that list
- THEN a new invite can be created successfully
- AND a participant can accept and see the list again
- AND Manage Sharing… becomes available again after someone has access

#### Scenario: Either person can share lists they own [manual]

- GIVEN two users A and B
- WHEN A creates a list and invites B, and B creates a different list and invites A
- THEN each sees Share only on lists they created
- AND on lists they only accepted, Share is not shown

#### Scenario: Manage Sharing fails with a visible error [manual]

- GIVEN the owner opens Manage Sharing… or tries Remove / Stop Sharing
- WHEN loading or updating the share fails
- THEN the owner sees a visible error
- AND the failure is not only a silent dismiss

### Requirement: Share invite process outcomes

The app SHALL handle the invite → accept process outcomes below. This requirement covers only sharing (sending and accepting an invite), not item sync after a share is already accepted.

When accepting a share fails after the app has started the accept path (including when the list never appears after accept), the app SHALL keep the finding-list screen visible, switch it to an error state that the share could not be opened, and offer **Retry** and **Go to Lists** (dismiss). The app MUST NOT dismiss that screen to Lists home with no explanation. The following scenarios cover accept failure when the invite was invalidated before accept, plus the error-screen actions.

#### Scenario: List deleted before accept [manual]

- GIVEN the owner sent a share invite for a list
- AND the owner deletes that list before the participant accepts
- WHEN the participant opens the invite and the app runs accept
- THEN the finding-list screen stays up and shows that the share could not be opened
- AND the participant is offered Retry and Go to Lists

#### Scenario: List unshared before accept [manual]

- GIVEN the owner sent a share invite for a list
- AND the owner stops sharing / removes the invitee via Manage Sharing before the participant accepts
- WHEN the participant opens the invite and the app runs accept
- THEN the finding-list screen stays up and shows that the share could not be opened
- AND the participant is offered Retry and Go to Lists

#### Scenario: Retry after accept failure [manual]

- GIVEN the finding-list screen is showing the accept-failure error state
- AND the app still has share metadata available for this session
- WHEN the participant chooses Retry
- THEN the error state clears and the finding-list loading state returns
- AND the app runs accept again with the retained invite metadata
- AND if accept still fails the error state is shown again
- AND if accept succeeds the app continues the normal open-list path

#### Scenario: Go to Lists after accept failure [manual]

- GIVEN the finding-list screen is showing the accept-failure error state
- WHEN the participant chooses Go to Lists
- THEN the finding-list screen is dismissed
- AND the participant is on Lists home
- AND the accept-failure error state is cleared

#### Scenario: Import is slow then succeeds

- GIVEN the participant accepted a share invite
- AND the shared list is not immediately available locally
- WHEN the app is waiting for CloudKit import
- THEN the app shows the finding-list interstitial
- AND once the list is available the app opens that list’s detail screen

#### Scenario: Import never arrives after accept [manual]

- GIVEN the participant accepted a share invite
- WHEN the shared list does not become available within the app’s wait window
- THEN the finding-list screen stays up and shows that the shared list could not be opened
- AND the participant is offered Retry and Go to Lists
- AND the app MUST NOT leave them on Lists home with no explanation

#### Scenario: Owner opens their own invite link

- GIVEN a share invite was created by the list owner
- WHEN the owner opens that invite while signed into the owner Apple ID
- THEN the app does not treat this as a failed import with no message
- AND the app indicates the user is already on this list (or already the owner)
- AND the app opens the existing list’s detail screen
