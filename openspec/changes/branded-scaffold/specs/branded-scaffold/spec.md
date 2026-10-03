# Branded scaffold

Minimal wifyradar iPhone app used to validate build and personal-device install.

## Requirements

### Requirement: Branded launch UI

The app SHALL present a single primary screen whose dominant text is the product name **wifyradar**.

The screen MAY include one short supporting sentence. It SHALL NOT present list, todo, or settings chrome in this scaffold.

#### Scenario: Branded launch screen appears [manual]

- GIVEN the app is installed on a simulator or device
- WHEN the user launches the app
- THEN the first screen shows **wifyradar** as the primary brand signal

### Requirement: Simulator build

The project SHALL build and run on an iOS Simulator using the installed Xcode toolchain.

#### Scenario: App builds for Simulator [manual]

- GIVEN Xcode and an iOS Simulator runtime are installed
- WHEN the WifyRadar scheme is built and run for a Simulator destination
- THEN the app launches without build errors and shows the branded screen

### Requirement: Personal device install

The project SHALL support install to personal iPhones via Xcode Automatic Signing (no App Store distribution required).

#### Scenario: App installs on a personal iPhone [manual]

- GIVEN a development team is selected for Automatic Signing
- WHEN the WifyRadar scheme is run on a connected iPhone
- THEN the app installs and launches on that device showing the branded screen
