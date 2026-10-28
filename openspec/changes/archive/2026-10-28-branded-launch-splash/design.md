# Design: Branded launch splash

Canonical: [`openspec/specs/branded-scaffold/spec.md`](../../specs/branded-scaffold/spec.md). Mock: [`docs/mocks/launch-splash.html`](../../../docs/mocks/launch-splash.html) option C.

## Intended behavior

1. **System launch screen** — black (`LaunchBackground`) via `UILaunchScreen` so the OS chrome matches the splash while the process starts.
2. **In-app splash** — `LaunchSplashView`: black fill, large **W** with `Brand.gradient`, **wifyradar**, tagline **Stay synced. Stay happy**.
3. After a short hold (~0.8–1.2s) and/or first frame ready, fade to `ListsHomeView` (still first interactive screen).
4. Use `Brand.*` tokens only — no new hex in views.

### Files

| Path | Role |
|------|------|
| `WifyRadar/Brand/LaunchSplashView.swift` | Splash UI (mock C) |
| `WifyRadar/WifyRadarApp.swift` | Show splash then Lists |
| `WifyRadar/Assets.xcassets/LaunchBackground.colorset/` | Black for system launch |
| `Config/Info.plist` | `UILaunchScreen` → LaunchBackground |
| `WifyRadar.xcodeproj/project.pbxproj` | Prefer Info.plist launch over empty generated screen if needed |

## Documentation

### README.md

- Note cold start shows branded splash then Lists home; link mock optional.

### Spec scenario tags

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Branded splash appears on launch | *(manual)* | — |
| Lists home follows splash | *(manual)* | — |
