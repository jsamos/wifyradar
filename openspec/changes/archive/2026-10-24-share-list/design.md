# Design: Share list

## Architecture

SwiftData cannot create multi-user CloudKit shares (`CKShare`). Apple’s supported stack:

- **Core Data** + **`NSPersistentCloudKitContainer`**
- Private CloudKit store (owned lists) + **shared** store (accepted lists)
- Primary invite UX: in-app sheet → Apple ID email → `CKContainer.shareParticipant(forEmailAddress:)` → add participant → `persistUpdatedShare` → send `CKShare.url` via `ShareLink` (invite-only, `publicPermission = .none`)
- Optional **Manage Sharing…** uses `UICloudSharingController` (UIKit present) for stop-sharing / participants; do not rely on its Collaboration row for invites
- Identity = device iCloud accounts; no in-app login

This change migrates list persistence off SwiftData onto that stack so lists-home UI keeps working and sharing works.

### Ownership

- **Owner** = iCloud user who created the list (private store). Only the owner shows Share / Manage Sharing for that list.
- **Participant** = accepted a share (shared store). Can edit items; **cannot** re-share or manage that same list (CloudKit share administration is owner-only).
- Equality = each person creates and shares **their own** lists with the other — not re-sharing a list they received.
- Gate Share with “object is in the private store.”

### Runtime flow

1. iCloud CloudKit capability + container `iCloud.com.wifyradar.app` (paid ADP team).
2. `PersistenceController` loads private + shared store descriptions (history tracking + remote change).
3. Owner → Share → `container.share(_:to:)` → `UICloudSharingController` → Messages / link.
4. Participant accepts → `acceptShareInvitations(from:into:)` into shared store → list on Lists home.
5. Edits sync via CloudKit; no reshare.

### Info.plist / entitlements

- `WifyRadar/WifyRadar.entitlements` — iCloud + CloudKit (+ `aps-environment` as Xcode adds for CloudKit)
- `Config/Info.plist` (outside synchronized `WifyRadar/` folder) — `CKSharingSupported` = true; `UIBackgroundModes` includes `remote-notification` (required for CloudKit push sync)

### Xcode setup

1. Signing team = paid ADP (not Personal Team).
2. iCloud → CloudKit → container `iCloud.com.wifyradar.app`.
3. Two phones, different iCloud accounts, for end-to-end proof ([`docs/icloud-sharing-plan.md`](../../../docs/icloud-sharing-plan.md)).

## Files

| Path | Role |
|------|------|
| `WifyRadar/WifyRadar.xcdatamodeld` | Entities `SharedList`, `ListItem` (codegen class) |
| `WifyRadar/Persistence/PersistenceController.swift` | Container, private/shared stores, share/accept |
| `WifyRadar/Lists/ListsHomeView.swift` | `@FetchRequest` home |
| `WifyRadar/Lists/ListDetailView.swift` | Items + owner-only Share |
| `WifyRadar/Sharing/CloudSharingView.swift` | `UICloudSharingController` wrapper |
| `WifyRadar/Sharing/CloudKitShareAcceptBridge.swift` | Accept-share via App + **Scene** delegates; while waiting for import, `ShareNavigationStore.isOpeningSharedList` shows loading UI; then Lists home pushes the opened list |
| `WifyRadar/Sharing/ShareInviteLoadingView.swift` | Branded full-screen interstitial during invite accept / CloudKit import; dismisses into list detail |
| `WifyRadar/WifyRadarApp.swift` | Context + share-accept adaptor |
| `Config/Info.plist` | `CKSharingSupported`, remote-notification |
| `WifyRadar/WifyRadar.entitlements` | CloudKit container |
| *(remove)* `WifyRadar/Models/*.swift` | SwiftData `@Model` types |

`PersistenceController` is a singleton (`shared`), not `ObservableObject` — default MainActor isolation breaks that conformance under this target’s Swift settings.

## Auth

None in-app. Both devices signed into iCloud.

## Tests

| Kind | Coverage |
|------|----------|
| Manual | Share A → accept B → list on B |
| Manual | Add item on A → visible on B |
| Build | Simulator/device `xcodebuild` succeeds |
| Automated | Not required for invite path |

## Documentation

### README.md

- iCloud / ADP note (already linked via sharing plan)
- Keep share-list behavioral spec row

### docs/

- [`docs/icloud-sharing-plan.md`](../../../docs/icloud-sharing-plan.md) — enroll → signing → restore share → two phones

### Spec scenario tags

- Canonical: [`openspec/specs/share-list/spec.md`](../../specs/share-list/spec.md)
- Change: [`openspec/changes/share-list/specs/share-list/spec.md`](specs/share-list/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Owner shares a list | *(manual)* | — |
| Participant sees accepted list | *(manual)* | — |
| Accepting an invite opens that list | *(manual)* | — |
| Item syncs to the other device | *(manual)* | — |
