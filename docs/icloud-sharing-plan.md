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

**Done when:** you have a paid ADP team, not only a free Personal Team.

How to tell:

- Xcode → **Settings → Accounts** → open your account → open the **Teams** row. Free tier says **Personal Team**. Paid Individual shows **Developer Team** (or similar) with a role such as Admin / Account Holder — not “Personal Team”.
- On the web: [developer.apple.com/account](https://developer.apple.com/account) → membership shows an active **Apple Developer Program** enrollment.
- What matters for builds is the project **Team** dropdown in Signing & Capabilities (next stage). Accounts can show the paid team while the target is still on Personal Team.

### 2. Prove iCloud signing on one phone

Enrollment is not enough until a device build accepts CloudKit entitlements. A normal lists-home run without iCloud does **not** prove this stage.

1. Open `WifyRadar.xcodeproj` → left sidebar blue **WifyRadar** → **TARGETS → WifyRadar** → **Signing & Capabilities**.
2. Keep **Automatically manage signing** on.
3. Set **Team** to your paid team: your name **without** the suffix **(Personal Team)**. If the dropdown only lists Personal Team, use **Settings → Accounts → Add Account** / sign in again so the paid team appears, then re-open the Team menu.
4. Click **+ Capability** → add **iCloud**.
5. Check **CloudKit** (Key-value storage and iCloud Documents can stay off).
6. Under **iCloud Identifiers**, click **+** and add/select container **`iCloud.com.wifyradar.app`** (the list often starts empty even after CloudKit is checked). Ensure that container is selected.
7. Choose a physical iPhone → **▶**.

**Done when:** the app installs and launches with no iCloud / Personal Team / provisioning-profile errors.

### 3. Restore share code and open Share on one phone

Replace SwiftData lists-home persistence with the share-list stack — see [`openspec/changes/share-list/design.md`](../openspec/changes/share-list/design.md):

- Core Data model + `NSPersistentCloudKitContainer` (private + shared stores)
- Share control on owned lists + accept-share path
- `CKSharingSupported` and **remote-notification** background mode (`Config/Info.plist`)

1. Install on phone A; create a list; add an item.
2. Open that list → **Share**; confirm the system share sheet opens without entitlement errors.

**Done when:** Share UI opens and CloudKit is usable in Development.

### 4. Share between two phones

- App on both phones ([`build.md`](build.md))
- **Different** iCloud accounts on each phone
- Both online

1. Either phone (as owner of a list): **Share** → enter the other person’s **Apple ID email** → **Send Invite** → send the invite link (Messages, etc.). Invite-only (`publicPermission = .none`). Do not use the system **Collaboration** row (it can open empty).
2. Other phone: open the invite while signed into **the invited Apple ID** (app installed); accept. After import (may take a few seconds), the app should open that list’s detail screen (and the list remains on Lists home). Opening the link on the **owner’s** Apple ID will not add a second copy of the list.
3. Add an item on either phone; it appears on the other after sync (no new invite).

Both phones can own lists and invite. Each Apple ID needs free iCloud storage or CloudKit returns Quota Exceeded.

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
