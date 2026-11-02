# TestFlight (wifyradar)

Install **WifyRadar** on real iPhones through [TestFlight](https://developer.apple.com/testflight/). TestFlight builds use **Production** CloudKit. Xcode ▶ installs use **Development**. Completing this doc checks off the TestFlight item in [`app-store-checklist.md`](app-store-checklist.md) §2.

**Identifiers**

| Item | Value |
|------|--------|
| Bundle ID | `com.wifyradar.app` |
| Scheme | `WifyRadar` |
| Marketing version / build (starting point) | `1.0` / `1` |
| SKU | `wifyradar` |

Do the path below **in order**. Deploy the CloudKit Production schema before this path (checklist §2).

---

## 1. App Store Connect app record

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps**.
2. **+** → **New App**.
3. Platforms: **iOS**.
4. Name, primary language, Bundle ID **`com.wifyradar.app`**.
5. **SKU:** `wifyradar` (internal only; not shown on the App Store).
6. **User Access:** **Full Access** (or Limited if you intentionally restrict the team).
7. Create the app.

**Done when:** the app appears under Apps and shows an empty or ready iOS version you can attach builds to.

---

## 2. Archive and upload

Create a **local** archive on this Mac, then upload it from Organizer. This is not **Xcode Cloud** (hosted CI from a git remote). If Xcode asks to connect **GitHub**, grant **git** / repo access for Cloud, or shows **Xcode Cloud** setup (“Setup Complete”, **Start First Build**): cancel or **Close**.

Confirm **Signing & Capabilities** uses the paid team and Automatic Signing before archiving.

### Create the archive (pick one)

**A. Xcode menu**

1. Open `WifyRadar.xcodeproj` in Xcode.
2. Next to ▶, scheme **WifyRadar**, destination **Any iOS Device (arm64)** (Archive is unavailable with a Simulator selected).
3. Mac menu bar: **Product → Archive**. Wait until the archive finishes.

**B. Command line**

From the repo root:

```bash
xcodebuild -scheme WifyRadar -destination 'generic/platform=iOS' -archivePath /tmp/WifyRadar.xcarchive archive 2>&1 | tee /tmp/wifyradar-archive.log
```

Confirm the log ends with `ARCHIVE SUCCEEDED`, then place the archive where Organizer lists it:

```bash
ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)"
mkdir -p "$ARCHIVE_DIR"
cp -R /tmp/WifyRadar.xcarchive "$ARCHIVE_DIR/WifyRadar $(date '+%b %-d, %Y at %-I.%M %p').xcarchive"
```

### Upload

1. **Window → Organizer** → **Archives**. Select the new **WifyRadar** archive (reopen Organizer if it was already open and the list looks empty).
2. **Distribute App** → **App Store Connect** → **Upload** (defaults are fine for a first upload).
3. Wait until **Processing** finishes. Check: [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar** → **TestFlight** (iOS builds, for example **1.0 (1)**). Apple may also email when processing finishes.
4. If the build then shows **Missing Compliance**, answer the export / encryption questions on that build (required before TestFlight can use it). Then continue with §3.
5. Confirm build status is **Ready to Submit**.

**Done when:** the build is **Ready to Submit**.

---

## 3. Internal testing

Internal testers are people on the App Store Connect team (Account Holder, Admin, App Manager, Developer, Marketing). No Beta App Review for internal groups.

1. Each tester: install **TestFlight** from the App Store on their iPhone.
2. For **Internal** testers: invite each person under **Users and Access** (top menu bar) with at least a **Developer** or **Marketing** role before adding them to a TestFlight group; otherwise they will not appear as tester options.
3. In App Store Connect → the **wifyradar** app → **TestFlight**.
4. Select the build from §2 (**Ready to Submit**).
5. Create a group before assigning the build. The TestFlight page may show **Internal Testing** and **External Testing** in the left sidebar (**+** on either), or a prompt to create your first group if none exist yet.
6. Open the group, add the build, then add testers with one of these paths:
   - **A. Internal:** Add team members from **Users and Access** to the **Internal Testing** group.
   - **B. External:** Create a public link for the group and share it; testers join themselves and no per-person invite is needed. The build must pass **Beta App Review** before external testers can install.
7. Each tester: sign in with their Apple ID, accept the invite or open the public link, install **wifyradar**.

**Done when:** both phones that will verify sharing have the TestFlight build installed and launch.

---

## 4. Verify Production CloudKit sharing

On two physical devices, **different** iCloud accounts, both online, with free iCloud storage:

1. Create a list → add an item.
2. Share → invite the other Apple ID → accept on the other phone.
3. Add or check an item on each side; confirm sync.
4. Remove / leave / delete as you care about for release.

**Done when:** that flow works on the TestFlight build. Check off the TestFlight item in [`app-store-checklist.md`](app-store-checklist.md) §2.

---

## 5. Later builds

1. Bump **Build** (`CURRENT_PROJECT_VERSION`) for every new upload; bump Marketing version when you mean a new store version.
2. Archive → Upload again.
3. Add the new build to the internal (or external) TestFlight group.

External testing (people outside the team) needs a Beta App Review pass and is optional for the first Production CloudKit check.
