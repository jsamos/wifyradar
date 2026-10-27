# Proposal: Owner opens own invite

## Intent

When the list owner opens their own share invite link (signed into the owner Apple ID), open the existing list with a clear “already the owner” indication instead of running the participant accept/import failure path.

## Scope

Amends **invite-from-contacts** (share invite process outcomes). Depends on **share-list** accept plumbing.

- Detect that the current user is the CloudKit share owner for the opened invite metadata
- Do not treat this as a failed import / accept-failure interstitial with no owner-specific message
- Resolve and open the existing list on the owner’s device
- Show a short indication that they are already the owner (or already on this list)

## Out of scope

- Participant accept, import timeout, and accept-failure Retry / Go to Lists (already specified)
- Manage Sharing, Contacts invite, or re-share by participants
- Changing how invite links are created or sent
