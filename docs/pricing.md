# Pricing (wifyradar)

Set the App Store price before **Add for Review**. Completing this doc checks off the Pricing item in [`app-store-checklist.md`](app-store-checklist.md) §5.

Apple: [Pricing and availability](https://developer.apple.com/help/app-store-connect/manage-app-pricing/set-a-price-and-schedule-price-changes/).

---

## 1. Open Pricing

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **Monetization** → **Pricing and Availability** (or **Pricing**).

**Done when:** the price / availability controls are visible.

---

## 2. Choose Free or paid

### Free (recommended for 1.0)

1. Price → **Free**.
2. Confirm availability countries (default all is fine unless you intentionally restrict).
3. **Save**.

You can change to a paid tier later without a new binary. Update Description / store copy when the app is no longer free.

### Paid (one-time app price)

1. In [Agreements, Tax, and Banking](https://appstoreconnect.apple.com/agreements), accept the **Paid Apps** agreement (Account Holder).
2. Complete **tax** and **banking** (required before a non-free price can pay out / fully clear).
3. On **Pricing**, choose a price (for example **$0.99**).
4. Confirm availability countries.
5. **Save**.
6. Update store copy if it still says the app is free ([`product-page.md`](product-page.md) Description, and App Store Connect to match).

This is a **paid download** of the app. In-app subscriptions or IAPs are a separate setup and out of scope unless you add them later.

**Done when:** a price is chosen and saved. For paid, Paid Apps plus tax and banking are complete.

---

## 3. Tax and banking (paid only)

Required only when the price is not Free. Exact forms depend on account country and entity type.

**US Individual (typical)**

| Area | What Apple asks for |
|------|---------------------|
| Tax | Electronic **W-9**: legal name, address, classification (often Individual/sole proprietor), **SSN** or ITIN. Use an **EIN** only if the taxpayer is a business entity that has one. |
| Banking | Bank country, routing number, account number, account type, account holder name matching the bank account. |

Apple verifies the information. Do not treat this as tax advice; use the IDs that match how you file.

**Done when:** tax and banking show as complete under Agreements / Business for the Paid Apps agreement.

---

## 4. Later price changes

- **Free → paid:** open Pricing, pick a tier, ensure Paid Apps / tax / banking are done, **Save**, update “free” wording in store copy.
- **Paid → free:** also done on Pricing; update store copy.

**Done when:** checklist §5 Pricing is checked off.
