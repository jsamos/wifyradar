# App Store screenshots (wifyradar)

Upload screenshots for the App Store product page. Completing this doc checks off the Screenshots item in [`app-store-checklist.md`](app-store-checklist.md) §4.

Apple: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

App Preview video is a separate checklist item (optional). wifyradar is **iPhone-only**.

---

## Required display size

| Slot in App Store Connect | Accepted portrait sizes (px) |
|---------------------------|------------------------------|
| **iPhone with Dynamic Island (medium display)** | **1206 × 2622** or **1179 × 2556** |

PNG or JPEG, no transparency. Up to 10 screenshots. More than half must show the app in use.

Other iPhone sizes can be left empty when App Store Connect scales from this set.

---

## 1. Open App Previews and Screenshots

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **1.0 Prepare for Submission**.
3. **English (U.S.)**.
4. Product Page Information → tab **App Previews and Screenshots**.

**Done when:** the iPhone screenshot wells are visible.

---

## 2. Capture shots (Simulator)

Suggested scenes:

1. **Lists home** — one or more lists visible.
2. **List detail** — items with at least one checked.
3. **Share / Manage Sharing** — invite or people-with-access UI.

1. Xcode → scheme **WifyRadar** → destination an iPhone that matches medium Dynamic Island sizes (for example **iPhone 16 Pro** or **iPhone 17** / Pro as listed in Apple’s table).
2. Run the app, set up demo data, open each scene.
3. **Device** → **Trigger Screenshot** (or `Cmd+S` in Simulator).
4. Confirm pixel size is **1206 × 2622** or **1179 × 2556** (Preview → Tools → Show Inspector, or `sips -g pixelWidth -g pixelHeight`).

**Done when:** at least one valid iPhone medium screenshot exists on disk (three recommended).

---

## 3. Upload

1. On **App Previews and Screenshots**, open the **iPhone with Dynamic Island (medium display)** well.
2. Drag in the iPhone PNGs (order: Lists home → list detail → sharing).
3. **Save**.

**Done when:** the required iPhone well has at least one screenshot. Check off the item in [`app-store-checklist.md`](app-store-checklist.md) §4.

---

## 4. Later changes

Replace screenshots when UI changes materially. Update this file if Apple’s required slots or sizes change.
