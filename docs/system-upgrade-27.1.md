# System upgrade: Xcode 27.1

Record of moving the Mac toolchain from Xcode 26.x to **Xcode 27.1**, and what to verify before building **wifyradar** again.

## Installed toolchain

Run these after opening the new Xcode once (license + first-launch components):

```bash
xcodebuild -version
swift --version
xcodebuild -showsdks
xcrun simctl runtime list
xcrun simctl list devices available
```

| Component | Version |
|-----------|---------|
| Xcode | **27.1** (Build 27A9275) |
| Swift | **6.4** (swiftlang-6.4.0.34.1) |
| iOS SDK | **27.1** (`iphoneos27.1`) |
| iOS Simulator SDK | **27.1** (`iphonesimulator27.1`) |
| macOS SDK | **27.0** (`macosx27.0`) |
| iOS Simulator runtime | **27.1** only |

```bash
xcode-select -p
# /Applications/Xcode.app/Contents/Developer
```

## Keep one Simulator runtime

Simulator runtimes are large (often ~8–15+ GB each). Download and keep **only iOS 27.1** — the runtime that matches this Xcode’s iOS SDK.

Do **not** also install:

- Older runtimes from a previous Xcode (for example iOS 26.5)
- Extra same-major runtimes Xcode may offer after upgrade (for example iOS 27.0)

Those are only useful for deliberate “test on older OS in Simulator” work. Physical iPhones use their own OS; they do not need a matching Simulator runtime on the Mac.

If Xcode starts a second runtime download while 27.1 is already installed, cancel it in **Settings → Platforms**.

The SDK ships with Xcode; the runtime is separate (**Settings → Platforms**, or `xcodebuild -downloadPlatform iOS`).

### Simulator devices

Under iOS 27.1, `simctl` may list only **iPhone Duo** at first. Add other models in **Window → Devices and Simulators** if needed.

```bash
xcrun simctl list devices available
xcodebuild -project WifyRadar.xcodeproj -scheme WifyRadar \
  -destination 'platform=iOS Simulator,name=iPhone Duo' build
```

## Removing leftover runtimes (done on this upgrade)

After installing Xcode 27.1, an **iOS 26.5** runtime from the previous toolchain was still present. It was removed as follows.

### 1. List disk images

```bash
xcrun simctl runtime list
```

Before cleanup that looked like:

```text
== Disk Images ==
-- iOS --
iOS 27.1 (24A94425) - BE606812-0762-48F6-A656-72008763BEF3 (Ready)
iOS 26.5 (23F77) - 667E5A4F-9AFB-40B5-B1BD-36A5CE70E982 (Ready)
```

Copy the UUID of the runtime to delete from a **fresh** `runtime list` (UUIDs differ per machine).

### 2. Delete

```bash
xcrun simctl runtime delete <UUID>
```

Example used here for iOS 26.5:

```bash
xcrun simctl runtime delete 667E5A4F-9AFB-40B5-B1BD-36A5CE70E982
```

Deletion can take several minutes; status may show `Deleting` until finished.

### 3. Confirm

```bash
xcrun simctl runtime list
```

Only **iOS 27.1** should remain.

Same action is available in Xcode → **Settings → Platforms** (select the old runtime → delete). An **iOS 27.0** download that had started was canceled there and never remained installed.

## Repo docs to keep in sync

Keep these aligned with `xcodebuild -version` on this Mac:

- [`AGENTS.md`](../AGENTS.md) — agent toolchain baseline
- [`README.md`](../README.md) — prerequisites / verify examples

## Build / device checklist after upgrade

1. Open Xcode 27.1 once; finish first-launch / license if prompted.
2. Confirm a single Simulator runtime: **iOS 27.1** (`xcrun simctl runtime list`).
3. Confirm `xcodebuild -version` prints **Xcode 27.1**.
4. Rebuild for Simulator or a plugged-in iPhone (**▶**). Free Personal Team installs still expire ~weekly; re-run **▶** to refresh.
5. If a needed device name is missing under 27.1, add it in **Devices and Simulators**.

## Related

- Day-to-day install steps: [`build.md`](build.md)
- Paid ADP + CloudKit sharing gates: [`icloud-sharing-plan.md`](icloud-sharing-plan.md)
