# App Privacy questionnaire (wifyradar)

Fill the **App Privacy** nutrition label in [App Store Connect](https://appstoreconnect.apple.com) for **wifyradar**. Completing this doc checks off the App Privacy questionnaire item in [`app-store-checklist.md`](app-store-checklist.md) §3.

Apple reference: [App privacy details](https://developer.apple.com/app-store/app-privacy-details/).

Set the **Privacy Policy URL** first if needed ([`github-pages.md`](github-pages.md)). That field is on the same App Privacy page; this doc covers the data-collection answers only.

---

## 1. Open Data Types

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **App Privacy**.
3. Scroll to **Data Types** → **Edit**.

**Done when:** the **Data Collection** modal asks whether data is collected.

---

## 2. Data collection and tracking

1. **Do you or your third-party partners collect data from this app?** → **Yes, we collect data from this app**.
2. Save / continue.
3. **Tracking** (if asked): **No**.

**Done when:** the modal shows the scrollable list of data-type checkboxes.

---

## 3. Check only these

Stop only on these three headings. Check the named box. Leave every other box unchecked.

| Heading | Check |
|---------|--------|
| **Contact Info** | **Email Address** |
| **User Content** | **Other User Content** |
| **Identifiers** | **User ID** |

Click **Continue**.

App Store Connect shows **Additional Setup Required**: “To update your app's product page with new data types, you need to finish setting them up on the following page.” Click **OK**.

**Done when:** back on the App Privacy page. Under **Data Types**, each selected type shows a yellow warning and a button:

- **Set Up Email Address**
- **Set Up Other User Content**
- **Set Up User ID**

---

## 4. Set Up Email Address

1. Click **Set Up Email Address**.
2. Purpose: check **App Functionality** only → **Next**.
3. **Are the email addresses collected from this app linked to the user’s identity?** → **Yes, email addresses collected from this app are linked to the user’s identity** → **Next**.
4. Definitions screen (“Let's define two important terms…” — Tracking / Third-Party Data) → **Next**.
5. Tracking examples screen (“To help put tracking into context…”) → **Next**.
6. **Do you or your third-party partners use email addresses for tracking purposes?** → **No** → finish until the yellow warning on Email Address is gone.

**Done when:** Email Address no longer shows **Set Up Email Address**.

---

## 5. Set Up Other User Content

1. Click **Set Up Other User Content**.
2. Purpose: check **App Functionality** only → **Next**.
3. Linked to the user’s identity → **Yes** (same pattern as Email Address) → **Next**.
4. Definitions screen (Tracking / Third-Party Data) → **Next**.
5. Tracking examples screen → **Next**.
6. Used for tracking → **No** → finish until the yellow warning on Other User Content is gone.

**Done when:** Other User Content no longer shows **Set Up Other User Content**.

---

## 6. Set Up User ID

1. Click **Set Up User ID**.
2. Purpose: check **App Functionality** only → **Next**.
3. Linked to the user’s identity → **Yes** (same pattern as Email Address) → **Next**.
4. Definitions screen (Tracking / Third-Party Data) → **Next**.
5. Tracking examples screen → **Next**.
6. Used for tracking → **No** → finish until the yellow warning on User ID is gone.

**Done when:** User ID no longer shows **Set Up User ID**, and no yellow warnings remain under **Data Types**. Check off the item in [`app-store-checklist.md`](app-store-checklist.md) §3.

---

## 7. Later changes

When Contacts, sharing, analytics, or CloudKit practices change, update this questionnaire and [`docs/site/privacy.html`](site/privacy.html), then republish App Privacy.
