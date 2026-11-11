# App Store checklist (wifyradar)

Example runbook to ship **wifyradar** through [App Store Connect](https://appstoreconnect.apple.com). Follow sections **in order**. TestFlight detail: [`testflight.md`](testflight.md). Privacy / Support HTTPS pages: [`github-pages.md`](github-pages.md). App Privacy questionnaire: [`app-privacy.md`](app-privacy.md). Age rating: [`age-rating.md`](age-rating.md). Accessibility: [`accessibility.md`](accessibility.md). Product page text: [`product-page.md`](product-page.md). Screenshots: [`screenshots.md`](screenshots.md). Pricing: [`pricing.md`](pricing.md). Submit for review: [`submit.md`](submit.md). Local Xcode installs: [`build.md`](build.md). iCloud enrollment: [`icloud-sharing-plan.md`](icloud-sharing-plan.md).

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

- [x] Host a public **Privacy Policy** URL (HTTPS). Follow [`github-pages.md`](github-pages.md). Live: https://chipinhead.github.io/wifyradar-site/privacy.html
- [x] Policy covers at least:
  - List and item content in the user’s **iCloud** via **CloudKit**.
  - Optional **Contacts** access: on-device invite email pick only; address book not uploaded.
  - Invite email / participant identity for CloudKit sharing.
  - How to stop sharing / leave / delete (in-app + iCloud account controls).
- [x] Paste the URL into App Store Connect (**Privacy Policy URL**).
- [x] App Privacy questionnaire: [`app-privacy.md`](app-privacy.md).
- [x] `NSContactsUsageDescription` in `Config/Info.plist` remains accurate.
- [x] Age rating questionnaire: [`age-rating.md`](age-rating.md).
- [x] Accessibility Nutrition Labels: [`accessibility.md`](accessibility.md).

---

## 4. Product page assets

- [x] Version page text (Description, Keywords, Support URL, Marketing URL, Version, Copyright): [`product-page.md`](product-page.md) §§1–9.
- [x] **Support URL** (from [`github-pages.md`](github-pages.md)): https://chipinhead.github.io/wifyradar-site/
- [x] App Information — Subtitle and Category (Primary **Productivity**): [`product-page.md`](product-page.md) §10.
- [x] App Information — Content Rights ([`product-page.md`](product-page.md) §10).
- [x] **App icon** — opaque 1024×1024 in `Assets.xcassets` / AppIcon (no alpha channel).
- [x] Screenshots: [`screenshots.md`](screenshots.md).
- [x] App Preview video — skipped for 1.0.
- [x] “What’s New” — not available on the first version (required for updates only).

---

## 5. Pricing

- [x] Set price (Free for 1.0, or a paid tier): [`pricing.md`](pricing.md).

---

## 6. Submit for review

Follow [`submit.md`](submit.md) in order:

- [ ] Attach the TestFlight-processed build to **1.0** ([`submit.md`](submit.md) §1).
- [ ] App Review contact + notes ([`submit.md`](submit.md) §2).
- [ ] Version release option ([`submit.md`](submit.md) §3).
- [ ] Submit for Review ([`submit.md`](submit.md) §4).

After approval: release if you chose manual. Monitor Resolution Center.

---

## 7. Common rejection risks

| Risk | Mitigation |
|------|------------|
| Share / sync fails in review | [`testflight.md`](testflight.md) verified; review notes explain two Apple IDs |
| Privacy label incomplete | Declare CloudKit user content and invite email |
| Missing privacy policy | Public HTTPS policy before submit |
| Contacts purpose unclear | Info.plist string aligned with policy |
| Broken launch / blank UI | Smoke-test a Release install on a device |

---

## 8. After 1.0

- [ ] Bump build (and version when appropriate) for each upload.
- [ ] After schema changes: deploy to Production, then re-verify sharing on a TestFlight build.
- [ ] Update privacy answers and policy if Contacts / sharing / analytics change.
- [ ] Keep Xcode / SDK current with [App Store submission requirements](https://developer.apple.com/app-store/submitting/).
