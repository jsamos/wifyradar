# Invite from contacts

Let the list owner choose a share-invite recipient from Contacts after granting Contacts access, while still allowing typed Apple ID email entry.

## Requirements

### Requirement: Contacts permission before reading contacts

Before the app reads contact records from `CNContactStore`, it SHALL obtain Contacts authorization. The app SHALL present the system permission prompt when status is not determined, using a privacy usage description that states Contacts are used only to pick an invite recipient email on device.

#### Scenario: First use requests Contacts access

- GIVEN the owner opens Share on a list they own
- AND Contacts authorization status is not determined
- WHEN the owner chooses to pick a recipient from Contacts
- THEN the system Contacts permission prompt is shown before contact data is read

#### Scenario: Denied access keeps manual email entry

- GIVEN Contacts authorization is denied or restricted
- WHEN the owner opens Share on a list they own
- THEN the owner can still type an Apple ID email and send an invite
- AND the app does not read contact records from `CNContactStore`

### Requirement: Select recipient email from Contacts

When Contacts access is authorized (or limited), the app SHALL let the owner select a contact email and SHALL place that email in the invite recipient field used by the existing share-invite flow.

#### Scenario: Owner picks a contact email [manual]

- GIVEN Contacts access is authorized
- AND the owner is on the Share sheet for a list they own
- WHEN the owner picks a contact that has an email address
- THEN that email appears in the invite recipient field
- AND the owner can send the invite using the existing CloudKit invite path

#### Scenario: Contact with multiple emails

- GIVEN Contacts access is authorized
- AND the owner selects a contact with more than one email address
- WHEN the owner chooses one of those emails
- THEN that chosen email is used as the invite recipient

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
- AND the owner sees the “Couldn’t share list” alert with the error
- AND the invite does not complete as a silent success
