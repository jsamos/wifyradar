# Accessibility Nutrition Labels (wifyradar)

Optional App Store product-page labels for accessibility support. Completing this doc resolves the Accessibility item in [`app-store-checklist.md`](app-store-checklist.md) §3.

Apple: [Overview of Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/), [Manage Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels).

Claim a feature only if a user can complete **all common tasks** of the app with that feature enabled. For wifyradar, common tasks include: open the app to Lists home, create a list, open a list, add or check items, share / invite, manage sharing, leave or delete a list.

wifyradar is **iPhone-only**.

---

## 1. Open App Accessibility

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **App Accessibility**.
3. **Get Started** (first time).

**Done when:** the **Select Device** dialog is open.

---

## 2. Select devices

| Device | Select |
|--------|--------|
| iPhone | **Yes** |
| iPad | **No** |
| Apple Watch | **No** |

**Save**.

**Done when:** the App Accessibility page shows an iPhone draft card (**Add iPhone Support** or an indicated-support card with **Edit**).

---

## 3. Add iPhone Support

1. Click **Add iPhone Support**.
2. **Does your app support any of the above features on iPhone?** → **No**.
3. Continue until the iPhone card reads that the developer indicated the app doesn’t support certain accessibility features (**Edit** available).

**Done when:** iPhone draft is set to **No** (not “Support Not Yet Indicated”).

### Recorded answers

| Device | Supports any? | Date |
|--------|---------------|------|
| iPhone | **No** | 2026-11-08 |

Check off the item in [`app-store-checklist.md`](app-store-checklist.md) §3 after iPhone is **No**.

---

## 4. Publish later (blocked until App Store release)

**Publish stays disabled** until wifyradar has an app version **released on the App Store**. The iPhone draft can be complete (**No**) while the blue banner still says you can only publish for devices with a released version.

1. Leave **Accessibility URL** blank unless a dedicated accessibility page exists.
2. After the first App Store release, return here → **Publish** (enabled when ASC allows).
3. To claim features later: verify common tasks on device, **Edit** iPhone, change answers, then **Publish** again.

**Done when:** understood that the iPhone draft is enough for the checklist now; **Publish** waits on App Store release.

---

## 5. Later changes

Re-test common tasks after UI changes, update App Accessibility, and refresh the recorded-answers table in §3.
