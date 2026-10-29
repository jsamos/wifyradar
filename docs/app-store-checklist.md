# App Store checklist (wifyradar)

Ship the iPhone app through [App Store Connect](https://appstoreconnect.apple.com). Local installs and Simulator builds: [`build.md`](build.md). iCloud enrollment and container setup: [`icloud-sharing-plan.md`](icloud-sharing-plan.md). TestFlight (Production CloudKit installs): [`testflight.md`](testflight.md).

**Identifiers used by this project**

| Item | Value |
|------|--------|
| Display name | wifyradar |
| Bundle ID | `com.wifyradar.app` |
| iCloud container | `iCloud.com.wifyradar.app` |
| Xcode project / scheme | `WifyRadar` |

Apple’s overview: [Submitting](https://developer.apple.com/app-store/submitting/), [App privacy details](https://developer.apple.com/app-store/app-privacy-details/).

---

## 1. Accounts and team

- [x] Active paid [Apple Developer Program](https://developer.apple.com/programs/) membership (required for CloudKit and App Store distribution).
- [x] Xcode → **Settings → Accounts**: ADP team selected (not only Personal Team).
- [x] Target **WifyRadar** → **Signing & Capabilities**: **Automatically manage signing**, Team = paid team, Bundle Identifier = `com.wifyradar.app`.
- [x] Capabilities present: **iCloud** (CloudKit) with container `iCloud.com.wifyradar.app`; **Background Modes** → remote notifications (already in `Config/Info.plist`).

---

## 2. CloudKit Production

Development CloudKit is not what App Store users use. Goal: Production schema is deployed and sharing works there.

- [x] Deploy the schema to **Production**:
  1. Open [CloudKit Console](https://icloud.developer.apple.com/).
  2. Choose **CloudKit Database**.
  3. In the top breadcrumb, set the container to **`iCloud.com.wifyradar.app`** (chevron next to the container name).
  4. In CloudKit Database, use the deploy control in the **bottom left**. In **Confirm Deployment**, review the listed schema changes, then click **Deploy**.
- [ ] On two physical devices signed into **different** iCloud accounts, install a Production build via [`testflight.md`](testflight.md) and verify: create list → invite → accept → item sync → remove/leave.
- [ ] Confirm Production has enough free iCloud storage on both Apple IDs (Quota Exceeded breaks sharing).

Do not submit until Production share flow works.

---

## 3. App Store Connect — app record

- [x] **My Apps** → **+** → New App.
- [x] Platforms: iOS.
- [x] Name, primary language, Bundle ID `com.wifyradar.app`.
- [x] **SKU:** `wifyradar` (internal only; not shown on the App Store).
- [x] User Access (Full Access for a typical solo team).

---

## 4. Privacy and compliance

### Privacy policy (required)

- [ ] Host a public **Privacy Policy** URL (HTTPS).
- [ ] Policy covers at least:
  - List and item content stored in the user’s **iCloud** via **CloudKit** (Apple’s infrastructure; you do not run a separate app server for list data).
  - Optional **Contacts** access: used only on-device to pick an Apple ID email for invites; address book is not uploaded as a contact database.
  - Invite email / participant identity as needed for CloudKit sharing.
  - How to stop sharing / leave a list / delete data (in-app controls + iCloud account controls).
- [ ] Paste the URL into App Store Connect → App Privacy / App Information (**Privacy Policy URL**).

### App Privacy nutrition label (required)

Answer in App Store Connect for data collected by the app (and any third-party SDK code — this project has none beyond Apple frameworks).

Declare types that actually leave the device for longer than servicing a real-time request. Typical areas to review for wifyradar (confirm against current code before submitting):

- [ ] User content (list names, item text, check state) via CloudKit.
- [ ] Contact info (email) when used as a share invitee identifier.
- [ ] Identifiers Apple/CloudKit may associate with the iCloud account for sync and sharing.
- [ ] Purposes: App Functionality (not tracking / not third-party advertising, unless that changes).
- [ ] Linked to user / used for tracking: answer honestly for CloudKit account-linked data; do not claim “not linked” if the data is in the user’s iCloud account.

Keep answers updated if behavior changes. Guide: [App privacy details](https://developer.apple.com/app-store/app-privacy-details/).

### Permissions copy

- [x] `NSContactsUsageDescription` in `Config/Info.plist` remains accurate (Contacts only to pick invite email on device).

### Age rating and other ASC questionnaires

- [ ] Complete the **age rating** questionnaire (shared lists / no objectionable content expected for a utility list app — answer for what the app actually contains).
- [ ] Complete any required **encryption** / export compliance questions for the build (standard HTTPS / Apple frameworks usual path).
- [ ] Fill **Accessibility** nutrition fields if you choose to publish them (optional but recommended when accurate).

---

## 5. Product page assets

- [ ] Subtitle, description, keywords, support URL, marketing URL (optional).
- [ ] Category (for example Productivity).
- [x] **App icon** — already in `Assets.xcassets` / AppIcon; confirm it matches ASC requirements.
- [ ] **Screenshots** for required iPhone sizes (capture from Simulator or device). Suggested shots: splash or Lists home, list detail with items, Share / Manage Sharing.
- [ ] App Preview video optional.
- [ ] “What’s New” text for version 1.0.

---

## 6. Version and build

- [x] Set **Marketing version** and **Build** in Xcode (General) or `agvtool` — e.g. `1.0` / `1`.
- [x] Archive: Xcode scheme **WifyRadar**, destination **Any iOS Device (arm64)**, Product → **Archive**.
- [x] Organizer → **Distribute App** → **App Store Connect** → Upload.
- [ ] Wait until the build finishes processing in App Store Connect.

Before first public submit, use TestFlight ([`testflight.md`](testflight.md)):

- [ ] Enable **TestFlight** for the build (internal group is enough).
- [ ] Internal testers exercise create / share / accept / sync / leave on Production CloudKit.

---

## 7. Submit for review

- [ ] Attach the processed build to the iOS version.
- [ ] Review notes for Apple: app requires **iCloud** sign-in; sharing needs a second Apple ID; Contacts optional for invite email; no separate demo account (use iCloud).
- [ ] Contact info for App Review.
- [ ] Submit.

After approval: choose release (manual or automatic). Monitor for Resolution Center messages.

---

## 8. Common rejection risks for this app

| Risk | Mitigation |
|------|------------|
| Share / sync fails in review | Production CloudKit verified; notes explain two Apple IDs |
| Privacy label incomplete | Declare CloudKit user content and invite email use |
| Missing privacy policy | Public HTTPS policy before submit |
| Contacts purpose unclear | Keep Info.plist string aligned with policy |
| Broken launch / blank UI | Smoke-test Release archive on a device |

---

## 9. After 1.0

- [ ] Bump build (and version when appropriate) for each upload.
- [ ] Re-test Production CloudKit after schema changes; deploy schema before relying on new fields in the store.
- [ ] Update privacy answers and policy if Contacts / sharing / analytics change.
- [ ] Keep Xcode / SDK current with [App Store submission requirements](https://developer.apple.com/app-store/submitting/) for the season.
