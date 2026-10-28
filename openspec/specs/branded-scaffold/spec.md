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

### Requirement: Brand color tokens

The app SHALL define brand colors in the asset catalog that match the app icon palette (pink gradient + white on-brand). `AccentColor` SHALL use the same primary pink as `BrandPrimary`. A Swift `Brand` API SHALL expose those colors, an icon-matching gradient (light → deep, top-leading → bottom-trailing), and shared corner radii.

#### Scenario: Accent matches brand primary [tested]

- GIVEN the asset catalog defines `AccentColor` and `BrandPrimary`
- WHEN their color components are read
- THEN they match each other
- AND they match the frozen icon primary sample `#FB2682`
- **Test:** `accentColorMatchesBrandPrimary()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Brand catalog matches icon samples [tested]

- GIVEN the brand named colors in the asset catalog
- WHEN their components are read
- THEN `BrandLight` matches `#FD99BF`
- AND `BrandMid` matches `#FC57A4`
- AND `BrandDeep` matches `#F90C77`
- AND `BrandOnBrand` matches `#FFFFFF`
- **Test:** `brandCatalogMatchesIconSamples()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Brand gradient uses icon stops [tested]

- GIVEN the `Brand.gradient` API
- WHEN its stop colors are inspected
- THEN they use brand light, mid, and deep (in that order)
- **Test:** `brandGradientUsesIconStops()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Branded UI readable in light and dark [manual]

- GIVEN the app runs in light appearance and in dark appearance
- WHEN the user views Lists home and a tinted control (for example Create or a checked item)
- THEN brand accent remains visible
- AND primary content remains readable
