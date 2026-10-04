# Build

How to install **WifyRadar** from Xcode onto the Simulator and personal iPhones.

## First build

Goal: get the app onto two real iPhones for the first time.

### The control you need

At the top of Xcode, find the **▶** (play) button.

Just to the right of ▶ you will see text like:

`WifyRadar  >  iPhone 17 Pro`

That second name (`iPhone 17 Pro` in this example) is a button. **Click that second name.** A dropdown list of phones appears.

- Soft names like **iPhone 17 Pro**, **iPhone 17** under simulators = fake phones on your Mac.
- Your real phone appears with **your iPhone’s name** (the name from Settings) once it is plugged in and trusted.

### Put the app on the Simulator (fake phone)

1. Double-click `WifyRadar.xcodeproj` to open it in Xcode (if it is not already open).
2. Click the second name after `WifyRadar  >` (for example click **iPhone 17 Pro**).
3. In the dropdown, click any iPhone under the simulators section.
4. Click **▶**.
5. Confirm the app launches (Lists home titled **wifyradar**).

### Put the app on your real iPhone

#### A. Connect the phone

1. Plug the iPhone into the Mac with a cable.
2. Unlock the iPhone.
3. On the iPhone, if a popup says **Trust This Computer?**, tap **Trust**, then enter the passcode.
4. Wait ~30 seconds.

#### B. Turn on Developer Mode (on the iPhone)

Do this **on each iPhone** you will install to. It is an iPhone setting, not a Mac setting.

1. On the iPhone: **Settings → Privacy & Security → Developer Mode**.
2. Turn **Developer Mode** on.
3. Restart the iPhone if prompted, then confirm you want Developer Mode enabled.
4. Unlock the phone again after restart.

If **Developer Mode** is missing from Privacy & Security, plug the phone into the Mac, select it in Xcode once (section C), then check Settings again — the toggle often appears after the first connection to Xcode.

#### C. Choose your real phone in Xcode

1. At the top of Xcode, click the second name after `WifyRadar  >`.
2. In the dropdown, find and click **your iPhone’s name** (the name from the phone’s Settings → General → About).
3. Check the top bar: it should now show `WifyRadar  >  <your iPhone’s name>`.

If your phone is missing from the list: unplug/replug, unlock the phone, confirm Trust, quit and reopen Xcode.

#### D. Signing (one-time setup for real phones)

1. In Xcode’s **left** sidebar, click the blue folder/project icon labeled **WifyRadar** at the top of the file list.
2. In the center area, under **TARGETS**, click **WifyRadar**.
3. Click the **Signing & Capabilities** tab.
4. Turn on the checkbox **Automatically manage signing**.
5. Open the **Team** menu and pick your Apple ID (Personal Team is fine).

#### E. Install on the phone

1. Click **▶**.
2. Wait for Xcode to finish. The first time can take a few minutes.
3. **Trust the Developer App certificate on the iPhone** (required the first time). Xcode may show: *The application could not be launched because the Developer App Certificate is not trusted.*
   1. On the iPhone: **Settings → General → VPN & Device Management**.
   2. Tap your Apple ID / developer entry under Developer App.
   3. Tap **Trust** and confirm.
4. In Xcode, click **▶** again (or open the app from the Home Screen).
5. Confirm the app launches on the phone.

### Second iPhone

1. Unplug the first phone (optional).
2. Plug in the second phone, unlock it, tap **Trust** if asked.
3. On the second iPhone, turn on **Developer Mode** (section B) — each phone needs its own setting.
4. Click the second name after `WifyRadar  >` and click the second phone’s name.
5. Click **▶**.
6. On the second iPhone, trust the Developer App certificate the same way as section E step 3.
7. Click **▶** again if needed.

### Notes

- Free Apple ID works. Installs may stop working after ~7 days until you click **▶** again from Xcode.
- Simulator success does not set up real-phone signing. Signing happens in section D + first real-phone **▶**.
- No App Store needed for this.

## Rebuild

Use this after code changes. You do not repeat Developer Mode, Trust This Computer, or certificate trust unless something was reset on the phone.

### Simulator

1. Open `WifyRadar.xcodeproj` in Xcode (or bring Xcode to the front if it is already open).
2. Click the second name after `WifyRadar  >` and pick a simulator if needed.
3. Click **▶**.
4. Wait for the build to finish; the Simulator updates to the new build.

### Real iPhone

1. Plug in the iPhone (or use the same wireless debugging setup as before).
2. Unlock the phone.
3. Click the second name after `WifyRadar  >` and select that iPhone.
4. Click **▶**.
5. Wait for Xcode to finish installing. Open the app if it does not come to the foreground.

### Second iPhone

1. Select the other phone after `WifyRadar  >`.
2. Click **▶**.
3. Repeat for each phone that should get the new build.

### Fresh start (wipe app data)

A normal rebuild keeps existing lists. To clear stored data and install clean:

**Simulator**

1. On the Simulator Home Screen, click and hold the **wifyradar** app icon (same as a long-press on a phone).
2. Choose **Remove App** → **Delete App**.
3. In Xcode, click **▶** to install again.

**Real iPhone**

1. On the Home Screen, long-press the **wifyradar** app icon.
2. Tap **Remove App** → **Delete App**.
3. In Xcode, select that iPhone after `WifyRadar  >`, then click **▶**.

Repeat on each phone or simulator that should start empty.

### If the rebuild fails

- Confirm **Signing & Capabilities** still has **Automatically manage signing** and a **Team**.
- If the free provisioning profile expired (~7 days), click **▶** again after fixing any signing warnings in Xcode.
- If the phone does not appear in the dropdown, reconnect the cable, unlock the phone, and reopen Xcode.
