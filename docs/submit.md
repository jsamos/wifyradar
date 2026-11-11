# Submit for App Review (wifyradar)

Attach a build and submit version **1.0** for App Review. Completing this doc checks off the items in [`app-store-checklist.md`](app-store-checklist.md) §6.

Archive and upload (if you need a new binary) are in [`testflight.md`](testflight.md) §2. TestFlight and App Store Connect share the same processed builds. Pricing is [`pricing.md`](pricing.md) (checklist §5). Content Rights is [`product-page.md`](product-page.md) §10.

---

## 1. Attach the build

Use a build that already finished processing (status **Ready to Submit** under TestFlight is fine).

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **1.0 Prepare for Submission**.
3. On the version page, find the **Build** section (below Product Page Information / next to the version metadata — scroll if needed).
4. Click **Add Build** (or the **+** / build picker if no build is selected yet).
5. Select the build you verified on TestFlight (for example **1.0 (1)**).
6. Confirm export compliance / encryption answers if App Store Connect prompts on this build (same questions as TestFlight).
7. **Save**.

**Done when:** the **Build** section shows that build number (not empty / “Select a build”).

If the picker is empty: the upload is still processing, failed compliance, or you need a new archive/upload per [`testflight.md`](testflight.md) §2.

---

## 2. App Review Information

Still on **1.0 Prepare for Submission**, open **App Review Information**.

### Contact

Fill First Name, Last Name, Phone, Email for someone who can answer App Review.

### Sign-in required

**Sign-in required** → **No**. That field is for apps with their **own** username/password login where App Review needs a provided account. wifyradar is not that — people sign in with their Apple ID / iCloud. Do not create a throwaway “demo” login for reviewers.

### Notes

Paste notes that match the product:

```
wifyradar requires iCloud (signed-in Apple ID) for lists and CloudKit sharing.

To verify sharing: create a list on one Apple ID, use Share / invite with a second Apple ID email, accept on a second device or account, then add or check an item and confirm sync.

Contacts access is optional and only used on-device to pick an invite email; the address book is not uploaded. No separate demo account is provided.
```

**Done when:** contact fields are filled and notes are saved.

---

## 3. Version release

On **1.0 Prepare for Submission**, under **App Store Version Release** (wording may vary):

- **Manually release this version**, or
- **Automatically release this version** after approval

Pick one, then **Save**.

**Done when:** a release option is selected.

---

## 4. Submit

1. Click **Add for Review** / **Submit for Review** (button label varies).
2. Confirm any final questionnaires, then submit.

**Done when:** version status is **Waiting for Review** (then **In Review**). Check off §6 in [`app-store-checklist.md`](app-store-checklist.md).

Monitor **Resolution Center** if App Review asks questions. After approval, release manually if you chose manual release.
