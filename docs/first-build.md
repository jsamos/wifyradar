# First build: branded scaffold

The first milestone is a minimal **WifyRadar** SwiftUI app: one screen with **wifyradar** as the brand. No lists or sync yet. Goal: prove the app builds and installs on two personal iPhones.

## After the scaffold code lands

### Simulator

1. Open `WifyRadar.xcodeproj` in Xcode.
2. Choose an iPhone simulator as the run destination.
3. Press Run (▶).
4. Confirm the branded **wifyradar** screen appears.

### Personal iPhone

1. Connect the iPhone (cable or wireless debugging).
2. Unlock the phone and trust the computer if prompted.
3. In Xcode, open the WifyRadar target → **Signing & Capabilities**.
4. Enable **Automatically manage signing** and select a Team (Apple ID).
5. Choose the iPhone as the run destination and press Run.
6. On the phone, if prompted: **Settings → General → VPN & Device Management** → trust the developer certificate.
7. Confirm the app launches and shows the branded screen.

### Second iPhone

Repeat the personal iPhone steps with the other device connected. Both phones must trust the same developer certificate.

## Expectations

- A free Apple ID is enough for personal installs. Free provisioning profiles expire about every **7 days**, so re-install or refresh from Xcode periodically.
- The first device run can take several minutes (signing, profile, trust prompts).
- App Store and TestFlight are out of scope for this scaffold.
