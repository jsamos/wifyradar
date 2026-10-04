# Proposal: Share list

## Intent

Prove two iPhones can share one list over iCloud: owner invites, participant accepts, items keep syncing — no app login and no custom backend.

## Scope

Depends on **lists-home** (lists UI + models already exist).

- Share a list the user owns via the system share UI (e.g. Messages) using the device iCloud account
- Keep shared list data in sync between participants’ devices
- Participant accepts on a second iPhone (different iCloud account)
- Shared list appears on the participant’s Lists home
- New items sync both ways without resharing

## Out of scope

- Building Lists home / create / detail UI (see **lists-home**)
- In-app login
- Custom servers
- Push notifications for every edit
- Unshare / leave UX beyond system defaults
- Grocery-specific features
