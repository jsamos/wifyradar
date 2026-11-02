# App Store checklist (wifyradar)

Example runbook to ship **wifyradar** through [App Store Connect](https://appstoreconnect.apple.com). Follow sections **in order**. TestFlight detail: [`testflight.md`](testflight.md). Privacy / Support HTTPS pages: [`github-pages.md`](github-pages.md). Local Xcode installs: [`build.md`](build.md). iCloud enrollment: [`icloud-sharing-plan.md`](icloud-sharing-plan.md).

**Identifiers**

| Item | Value |
|------|--------|
| Display name | wifyradar |
| Bundle ID | `com.wifyradar.app` |
| iCloud container | `iCloud.com.wifyradar.app` |
| Xcode project / scheme | `WifyRadar` |
| SKU | `wifyradar` |

Apple: [Submitting](https://developer.apple.com/app-store/submitting/), [App privacy details](https://developer.apple.com/app-store/app-privacy-details/).

---

## 1. Accounts and team

- [x] Active paid [Apple Developer Program](https://developer.apple.com/programs/) membership.
- [x] Xcode → **Settings → Accounts**: ADP team selected (not only Personal Team).
- [x] Target **WifyRadar** → **Signing & Capabilities**: **Automatically manage signing**, Team = paid team, Bundle Identifier = `com.wifyradar.app`.
- [x] Capabilities: **iCloud** (CloudKit) with container `iCloud.com.wifyradar.app`; **Background Modes** → remote notifications (`Config/Info.plist`).

---

## 2. CloudKit Production

- [x] Deploy CloudKit schema to Production:
  1. Open [CloudKit Console](https://icloud.developer.apple.com/).
  2. Choose **CloudKit Database**.
  3. In the top breadcrumb, set the container to **`iCloud.com.wifyradar.app`** (chevron next to the container name).
  4. Use the deploy control in the **bottom left**. In **Confirm Deployment**, review the listed schema changes, then click **Deploy**.
- [x] Complete [`docs/testflight.md`](testflight.md): Internal Testing group, add build, install on phones, verify Production sharing.

---

## 3. Privacy and store questionnaires

- [ ] Host a public **Privacy Policy** URL (HTTPS). Follow [`github-pages.md`](github-pages.md).
- [ ] Policy covers at least:
  - List and item content in the user’s **iCloud** via **CloudKit**.
  - Optional **Contacts** access: on-device invite email pick only; address book not uploaded.
  - Invite email / participant identity for CloudKit sharing.
  - How to stop sharing / leave / delete (in-app + iCloud account controls).
- [ ] Paste the URL into App Store Connect (**Privacy Policy URL**).
- [ ] App Privacy nutrition label: user content via CloudKit; invite email; account-linked identifiers; purpose App Functionality; linked-to-user answers that match CloudKit. Guide: [App privacy details](https://developer.apple.com/app-store/app-privacy-details/).
- [x] `NSContactsUsageDescription` in `Config/Info.plist` remains accurate.
- [ ] Complete the **age rating** questionnaire.
- [ ] Fill **Accessibility** nutrition fields if publishing them.

---

## 4. Product page assets

- [ ] Subtitle, description, keywords, **Support URL** (from [`github-pages.md`](github-pages.md)), marketing URL (optional).
- [ ] Category (for example Productivity).
- [x] **App icon** — opaque 1024×1024 in `Assets.xcassets` / AppIcon (no alpha channel).
- [ ] **Screenshots** for required iPhone sizes. Suggested: Lists home, list detail, Share / Manage Sharing.
- [ ] App Preview video optional.
- [ ] “What’s New” text for version 1.0.

---

## 5. Submit for review

- [ ] Attach the build to the iOS version.
- [ ] Review notes: requires **iCloud**; sharing needs a second Apple ID; Contacts optional for invite email; no separate demo account.
- [ ] Contact info for App Review.
- [ ] Submit.

After approval: choose release (manual or automatic). Monitor Resolution Center.

---

## 6. Common rejection risks

| Risk | Mitigation |
|------|------------|
| Share / sync fails in review | [`testflight.md`](testflight.md) verified; review notes explain two Apple IDs |
| Privacy label incomplete | Declare CloudKit user content and invite email |
| Missing privacy policy | Public HTTPS policy before submit |
| Contacts purpose unclear | Info.plist string aligned with policy |
| Broken launch / blank UI | Smoke-test a Release install on a device |

---

## 7. After 1.0

- [ ] Bump build (and version when appropriate) for each upload.
- [ ] After schema changes: deploy to Production, then re-verify sharing on a TestFlight build.
- [ ] Update privacy answers and policy if Contacts / sharing / analytics change.
- [ ] Keep Xcode / SDK current with [App Store submission requirements](https://developer.apple.com/app-store/submitting/).
