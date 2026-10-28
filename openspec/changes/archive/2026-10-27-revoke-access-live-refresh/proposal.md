# Proposal: Revoke access live refresh

## Intent

When the owner removes a person or stops sharing, the affected participant’s Lists home should reflect lost access after CloudKit sync **without requiring an app restart**.

## Scope

Amends **invite-from-contacts** Manage Sharing outcomes. Depends on **share-list** private/shared CloudKit stores (history tracking + remote change already enabled on store descriptions).

- Listen for persistent-store remote changes on the participant device
- Refresh / merge the view context so `@FetchRequest` on Lists home drops (or otherwise stops offering) lists the user can no longer access
- Same expectation when the owner **stops sharing** (everyone else loses access)
- Keep owner-side remove/stop behavior unchanged

## Out of scope

- Guaranteeing instant update while the participant device is offline (CloudKit must deliver)
- Changing how remove/stop is performed on the owner (`CKShare` + `persistUpdatedShare`)
- Item field sync (already works via record updates)
- Participant “leave share” UX
