# iCloud sharing plan

Two-phone list sharing needs **iCloud CloudKit**. A free Personal Team cannot use that capability; a paid [Apple Developer Program](https://developer.apple.com/programs/) (ADP) membership can. See Apple’s [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios).

Without ADP, Xcode fails with errors such as “Personal development teams do not support the iCloud capability.” A free Apple ID can still install a **non-iCloud** build (see [`build.md`](build.md)).

Do the path below **in order**. Stop if a stage fails.

## Path

### 1. Enroll as an Individual

Join as an **Individual** (personal / indie). One **$99/year** membership covers all your apps.

Use **Organization** only if you need a company as the App Store seller (D‑U‑N‑S, work email, website). Not required just to build more apps.

- Apple Account with **two-factor authentication**, legal age of majority
- Enroll in the [Apple Developer app](https://apps.apple.com/app/apple-developer/id640449983) or on the [web](https://developer.apple.com/programs/enroll/)
- Use your **legal name** (nicknames delay approval)
- Agree to the license and **pay**
- Wait for confirmation (usually within ~**24 hours**). If not, contact Apple with your Enrollment ID ([enrollment help](https://developer.apple.com/support/enrollment/))

**Done when:** the paid team appears in Xcode → **Settings → Accounts** (not only Personal Team).

### 2. Prove iCloud signing on one phone

Enrollment is not enough until a device build accepts CloudKit entitlements.

1. Xcode → **Settings → Accounts** → refresh; select the ADP team.
2. `WifyRadar.xcodeproj` → **TARGETS → WifyRadar → Signing & Capabilities**.
3. **Team** = paid team; **Automatically manage signing** on.
4. Add **iCloud** → enable **CloudKit** → container `iCloud.com.wifyradar.app`.
5. Build and run on one iPhone (**▶**).

**Done when:** install succeeds with no iCloud / provisioning-profile errors.

### 3. Restore share code and open Share on one phone

The repo may still be local SwiftData lists-home until this stage. Re-apply the share-list stack (Core Data + private/shared CloudKit stores, Share control, accept path, entitlements, `CKSharingSupported`) — see [`openspec/changes/share-list/design.md`](../openspec/changes/share-list/design.md).

1. Install on phone A; create a list; add an item.
2. Open that list → **Share**; confirm the system share sheet opens without entitlement errors.

**Done when:** Share UI opens and CloudKit is usable in Development.

### 4. Share between two phones

- App on both phones ([`build.md`](build.md))
- **Different** iCloud accounts on each phone
- Both online

1. Phone A: owned list → **Share** → send invite to phone B.
2. Phone B: accept; list appears on Lists home.
3. Add an item on either phone; it appears on the other after sync (no new invite).

**Done when:** the `[manual]` scenarios in [`openspec/specs/share-list/spec.md`](../openspec/specs/share-list/spec.md) pass.

## Stack (when stage 3 lands)

- **Core Data** + **`NSPersistentCloudKitContainer`**
- Private store (owned lists) + shared store (accepted lists)
- System share UI (`UICloudSharingController`) and `CKShare`
- Container `iCloud.com.wifyradar.app`, bundle `com.wifyradar.app`

SwiftData cannot create multi-user CloudKit shares.

## Notes

- Same iCloud account on both phones only proves private sync, not multi-user sharing.
- CloudKit Development schema is usually created on first successful `NSPersistentCloudKitContainer` use; inspect in CloudKit Console if needed.
