# App Store screenshots (wifyradar)

Upload screenshots for the App Store product page. Completing this doc checks off the Screenshots item in [`app-store-checklist.md`](app-store-checklist.md) §4.

Apple: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

App Preview video is a separate checklist item (optional). The binary supports **iPhone and iPad**, so both required wells need screenshots. iPhone Duo screenshots are not required for 1.0.

---

## Required display sizes

| Slot in App Store Connect | Accepted portrait sizes (px) | Simulator to use |
|---------------------------|------------------------------|------------------|
| **iPhone with Dynamic Island (medium display)** | **1206 × 2622** or **1179 × 2556** | **iPhone 17 Pro** |
| **iPad 13″ display** | **2064 × 2752** or **2048 × 2732** | **iPad Pro 13-inch (M5)** |

PNG or JPEG, **no transparency** (Simulator PNGs usually need the strip-alpha step in §3). Up to 10 screenshots per slot. More than half must show the app in use.

Other iPhone / iPad sizes can be left empty when App Store Connect scales from these sets.

---

## 1. Open App Previews and Screenshots

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. Left sidebar → **1.0 Prepare for Submission**.
3. **English (U.S.)**.
4. Product Page Information → tab **App Previews and Screenshots**.

**Done when:** the iPhone medium and iPad 13″ screenshot wells are visible.

---

## 2. Prepare Simulators

Use an **iOS 26.2** Simulator runtime so **iPhone 17 Pro** and **iPad Pro 13-inch (M5)** are available.

### Install a phone / iPad runtime

**Xcode UI**

1. **Xcode → Settings → Platforms** (or **Components**).
2. Download **iOS 26.2** Simulator (or another listed iOS runtime that offers iPhone 17 Pro and iPad Pro 13-inch).

**CLI**

```bash
xcodebuild -downloadPlatform iOS -buildVersion 26.2 -architectureVariant arm64
xcrun simctl runtime list
```

**Done when:** `simctl runtime list` shows **iOS 26.2** (Ready).

### Create or confirm devices

**Xcode UI**

1. **Window → Devices and Simulators → Simulators**.
2. **+** if needed. Create:
   - **iPhone 17 Pro**, OS **iOS 26.2**
   - **iPad Pro 13-inch (M5)**, OS **iOS 26.2**

**CLI** (skip if the names already appear under iOS 26.2)

```bash
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-2
xcrun simctl create 'iPhone 17 Pro' com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro "$RUNTIME"
xcrun simctl create 'iPad Pro 13-inch (M5)' com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB "$RUNTIME"
xcrun simctl list devices available
```

**Done when:** `simctl list devices available` lists **iPhone 17 Pro** and **iPad Pro 13-inch (M5)** under **iOS 26.2**.

---

## 3. Capture shots (Simulator)

Suggested scenes (capture each on **both** devices):

1. **Lists home** — one or more lists visible.
2. **List detail** — items with at least one checked.
3. **Share** — invite sheet (Manage Sharing with a second account is optional).

### Start the app on iPhone 17 Pro

At the top of the Xcode window, find the **▶** (play) button. Just to its right you will see text like:

`WifyRadar  >  iPhone 17 Pro`

That second name is a button (the run destination). If it names a different device, click it and change it.

1. Double-click **`WifyRadar.xcodeproj`** in Finder if Xcode is not already open on this project.
2. Click the second name after `WifyRadar  >`.
3. In the dropdown, under **iOS Simulators**, choose **iPhone 17 Pro** (iOS 26.2).
4. Click **▶**.
5. Wait until the **Simulator** window appears (a fake phone on the Mac). The first boot can take a minute.
6. Wait until **wifyradar** opens on Lists home.
7. If Simulator asks you to sign in to **iCloud** / Apple ID, complete that (needed for Share scenes).
8. Create one or two sample lists and a few items (check at least one) so the three scenes look real.
9. For each suggested scene: open that screen, click the Simulator window so it is frontmost, then **File → Save Screen** (or **Cmd+S**).

### Start the app on iPad Pro 13-inch (M5)

1. In Xcode, click the destination name after `WifyRadar  >` again.
2. Under **iOS Simulators**, choose **iPad Pro 13-inch (M5)** (iOS 26.2).
3. Click **▶**.
4. Wait for the iPad Simulator window and for **wifyradar** to launch.
5. Set up the same kind of demo data if this Simulator is empty.
6. Capture the same three scenes with **File → Save Screen** (or **Cmd+S**).

Screenshots save to the Mac **Desktop** by default (Simulator → **Settings → Screen Shots** to change the folder).

### Strip alpha (required)

Simulator PNGs often include an alpha channel even when every pixel is opaque. App Store Connect rejects images with transparency.

For each screenshot PNG, round-trip through JPEG to drop alpha, then check:

```bash
FILE=~/Desktop/YourScreenshot.png
sips -s format jpeg "$FILE" --out /tmp/asc-shot.jpg
sips -s format png /tmp/asc-shot.jpg --out "$FILE"
rm /tmp/asc-shot.jpg
sips -g pixelWidth -g pixelHeight -g hasAlpha "$FILE"
```

**Done when:** `hasAlpha: no` and sizes match the table below.

| Device | Expected size |
|--------|----------------|
| iPhone 17 Pro | **1206 × 2622** |
| iPad Pro 13-inch (M5) | **2064 × 2752** |

**Done when:** at least one valid, no-alpha screenshot exists for each required slot (three scenes × two devices recommended).

---

## 4. Upload

1. On **App Previews and Screenshots**, open the **iPhone with Dynamic Island (medium display)** well.
2. Drag in the iPhone PNGs (order: Lists home → list detail → sharing).
3. Open the **iPad 13″ display** well.
4. Drag in the iPad PNGs (same order).
5. **Save**.

**Done when:** both required wells have at least one screenshot. Check off the item in [`app-store-checklist.md`](app-store-checklist.md) §4.

---

## 5. Later changes

Replace screenshots when UI changes materially. Update this file if Apple’s required slots or sizes change.
