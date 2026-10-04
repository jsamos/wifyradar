# Proposal: Branded scaffold

## Intent

Prove the wifyradar toolchain end-to-end: a minimal branded iPhone app that builds, runs in the Simulator, and installs on two personal iPhones via Xcode (no App Store).

## Scope

- Create a SwiftUI iOS app project named WifyRadar in this repo
- Show a single branded launch screen (product name **wifyradar** as the primary visual identity)
- Build and run on the iOS Simulator
- Install and launch on two physical iPhones using Automatic Signing

## Out of scope

- Lists, todos, or any list CRUD
- Sync, CloudKit, accounts, or sharing
- App Store / TestFlight distribution
- Custom icon set beyond Xcode defaults (MAY add a simple asset later)
- macOS / iPad-optimized layouts beyond default iPhone target
