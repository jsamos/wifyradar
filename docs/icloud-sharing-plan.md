# iCloud sharing plan

How to enable two-phone list sharing with CloudKit, and how to confirm each step before depending on the next.

## Why a paid Apple Developer Program membership

Sharing lists across different Apple IDs uses **iCloud CloudKit** entitlements.

| Account type | iCloud / CloudKit capability |
|--------------|------------------------------|
| Free Personal Team | Not supported |
| Paid [Apple Developer Program](https://developer.apple.com/programs/) (ADP) | Supported |

Apple documents this in [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios): **iCloud: CloudKit** requires ADP membership.

Without ADP, Xcode cannot create a provisioning profile that includes iCloud. Device install then fails with errors such as:

- Personal development teams do not support the iCloud capability
- Provisioning profile doesn’t include the iCloud capability / container / entitlements

A free Apple ID is still enough to install a **non-iCloud** build on personal iPhones (see [`build.md`](build.md)).

## Chosen stack

Apple’s supported path for invite-another-Apple-ID sync:

- **Core Data** + **`NSPersistentCloudKitContainer`**
- Private CloudKit store (lists you own) + shared store (lists you accepted)
- System share UI (`UICloudSharingController`) and `CKShare`
- Container id: `iCloud.com.wifyradar.app`
- Bundle id: `com.wifyradar.app`

SwiftData alone cannot create multi-user CloudKit shares. Behavioral requirements live in [`openspec/specs/share-list/spec.md`](../openspec/specs/share-list/spec.md); architecture detail in [`openspec/changes/share-list/design.md`](../openspec/changes/share-list/design.md).

## Confidence before and after paying

| Claim | Confidence before ADP | How it becomes certain |
|-------|----------------------|-------------------------|
| Personal Team cannot use iCloud | Certain (Xcode + Apple docs) | Already observed |
| ADP unlocks iCloud / CloudKit signing | High (Apple capability matrix) | Checkpoint 1 |
| Share invite / accept / item sync works end to end | Not provable until code + two devices | Checkpoints 2–3 |

Do not treat enrollment alone as proof that sharing works. Use the checkpoints below in order and stop if a checkpoint fails.

## Checkpoint 1 — membership and signing (no share feature required)

Goal: prove the $99 membership removed the iCloud provisioning block.

1. Enroll at [developer.apple.com/programs](https://developer.apple.com/programs/) and wait until membership is active.
2. In Xcode → **Settings → Accounts**, sign in and refresh. The team should be an Apple Developer Program team, not only a Personal Team.
3. Open `WifyRadar.xcodeproj` → **TARGETS → WifyRadar → Signing & Capabilities**.
4. Set **Team** to the paid team. Keep **Automatically manage signing** on.
5. Add capability **iCloud**, enable **CloudKit**, and select or create container `iCloud.com.wifyradar.app`.
6. Build and run on one physical iPhone (**▶**).

**Pass:** build installs with no iCloud / provisioning-profile errors for the container and entitlements.

**Fail:** do not proceed to restore or build the share stack until Signing & Capabilities is green on a device.

## Checkpoint 2 — CloudKit persistence and Share UI (one device)

Goal: prove the app can use CloudKit and present system share UI after the Core Data + sharing implementation is restored.

1. Restore or re-implement the share-list stack (Core Data model, private + shared stores, Share control, accept-share path, entitlements, `CKSharingSupported`). See the share-list design doc for file layout.
2. Install on phone A. Create a list and confirm local create / open / add-item still work.
3. Open an owned list and start **Share**. Confirm the system share sheet appears without entitlement errors.

**Pass:** Share UI opens; CloudKit container is usable in Development.

**Fail:** fix signing, container id, or persistence setup before testing a second phone.

## Checkpoint 3 — two-phone share (product proof)

Goal: prove the share-list behavioral scenarios.

Prerequisites:

- App installed on two iPhones ([`build.md`](build.md))
- Phone A and phone B signed into **different** iCloud accounts
- Both online

Steps:

1. On phone A, open an owned list → **Share** → send invite (Messages or link) to the person on phone B.
2. On phone B, accept the invite. Confirm the list appears on Lists home.
3. Add an item on either phone. Confirm it appears on the other after sync, without a new invite.

**Pass:** matches the `[manual]` scenarios in the share-list spec.

## Notes

- Same iCloud account on both phones only proves private-database sync, not multi-user sharing.
- CloudKit Development schema is usually created on first successful use of `NSPersistentCloudKitContainer`; Account Holder or Admin can also inspect the container in CloudKit Console.
- Enrollment activation can take time after payment; Checkpoint 1 will not pass until the paid team appears in Xcode.
- Current repo may be on local SwiftData lists-home without iCloud until Checkpoint 2 work is applied. Lists-home still builds on a free Personal Team.
