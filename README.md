# wifyradar

A shared lists app for iPhone — grocery lists, todos, and anything else you want to keep in sync between a small group.

Built with Swift and SwiftUI. Not intended for App Store distribution; install to personal devices via Xcode (or TestFlight if you have an Apple Developer membership).

## Prerequisites

### Command Line Tools

If `git`, `clang`, or `swift` are missing, install Apple’s Command Line Tools:

```bash
xcode-select --install
```

Accept the dialog and wait for the install to finish. Confirm with:

```bash
xcode-select -p
```

This should print `/Library/Developer/CommandLineTools` (or an Xcode path if Xcode is already installed and selected).

### Xcode

iOS development requires the full Xcode app, not only Command Line Tools.

1. Install **Xcode** from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835).
2. Open Xcode once, accept the license, and let it finish installing additional components.
3. Point the active developer directory at Xcode:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

4. Confirm the toolchain:

```bash
xcodebuild -version
```

5. In Xcode → **Settings** → **Accounts**, sign in with an Apple ID. A free account is enough to run the app on your own iPhones. Free provisioning profiles expire about every 7 days, so you will need to re-install or refresh periodically. A paid [Apple Developer Program](https://developer.apple.com/programs/) membership enables longer-lived installs and optional TestFlight distribution.

### iOS Simulator

The iOS SDK and the Simulator **runtime** are separate. Building for a physical iPhone needs the iOS platform; running in Simulator needs a downloaded runtime.

1. In Xcode → **Settings** → **Platforms** (or **Components**), download **one** iOS Simulator runtime matching the installed SDK (for example iOS 27.1). Do not also download older or nearby runtimes unless you intentionally need them for older-OS Simulator testing.
2. Or from the terminal:

```bash
xcodebuild -downloadPlatform iOS
```

3. Confirm devices appear:

```bash
xcrun simctl list devices available
```

You should see at least one iPhone simulator under an iOS runtime. An empty device list usually means the runtime is still missing or still downloading.

Toolchain upgrade notes (Xcode 27.1): [`docs/system-upgrade-27.1.md`](docs/system-upgrade-27.1.md).

### Verify

```bash
swift --version
xcodebuild -version
xcrun simctl list devices available
```

You should see Swift 6.4, Xcode 27.1, and at least one available iPhone simulator. If `xcodebuild` or `simctl` report that only Command Line Tools are selected, re-run the `xcode-select` step above.

## Run

1. Open `WifyRadar.xcodeproj` in Xcode.
2. Next to **▶**, click the phone name after **WifyRadar ›** and choose a Simulator or your plugged-in iPhone.
3. For a real iPhone: left sidebar → blue **WifyRadar** project → **TARGETS → WifyRadar** → **Signing & Capabilities** → check **Automatically manage signing** → set **Team**.
4. Press **▶**.

More detail: [`docs/build.md`](docs/build.md) (first install and rebuild).

Two-phone iCloud sharing needs a paid Apple Developer Program membership (free Personal Team cannot use iCloud). Plan: [`docs/icloud-sharing-plan.md`](docs/icloud-sharing-plan.md).

Contacts access is optional: the owner can pick an invite email from Contacts or type an Apple ID email. Contacts stay on-device; only the selected email is used for the CloudKit invite. Opening your own invite link opens the existing list and notes that you are already the owner. After iCloud sync, remove/stop sharing updates the other person’s Lists home without requiring an app relaunch.

### Behavioral specs

| Spec | Description |
|------|-------------|
| [Branded scaffold](openspec/specs/branded-scaffold/spec.md) | Minimal branded app; Simulator build and personal iPhone install |
| [Lists home](openspec/specs/lists-home/spec.md) | Launch to lists, create/open lists, add items |
| [Share list](openspec/specs/share-list/spec.md) | Invite another person to a list and keep items in sync |
| [Invite from contacts](openspec/specs/invite-from-contacts/spec.md) | Optional Contacts pick for share-invite email; permission and privacy rules |

## Agent skills

These [agent skills](https://skills.sh/) help Cursor (and similar agents) write better Swift/SwiftUI code for this project. Install them into the repo (project-local under `.agents/skills/`):

### Recommended

```bash
npx skills add emilkowalski/skills@write-swift -y
npx skills add avdlee/swiftui-agent-skill@swiftui-expert-skill -y
npx skills add twostraws/swiftdata-agent-skill@swiftdata-pro -y
```

| Skill | Purpose |
|-------|---------|
| [write-swift](https://skills.sh/emilkowalski/skills/write-swift) | Modern Swift 6 style and concurrency |
| [swiftui-expert-skill](https://skills.sh/avdlee/swiftui-agent-skill/swiftui-expert-skill) | SwiftUI UI patterns, state, lists, accessibility |
| [swiftdata-pro](https://skills.sh/twostraws/swiftdata-agent-skill/swiftdata-pro) | SwiftData persistence, including CloudKit constraints |

### Nice to have

```bash
npx skills add https://uizze.sh/ -y
rm -rf .agents/skills/ui-taste
```

That source ships **ios-design** and **ui-taste** together; remove `ui-taste` afterward if you only want iOS design guidance.

| Skill | Purpose |
|-------|---------|
| [ios-design](https://skills.sh/uizze.sh/ios-design) | iOS UI/UX design and review (SwiftUI / HIG) |

Browse more at [skills.sh](https://skills.sh/).
