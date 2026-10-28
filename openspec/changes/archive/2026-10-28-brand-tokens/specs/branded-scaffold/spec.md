# Branded scaffold (change: brand tokens)

Only the requirements and scenarios introduced by this change. Canonical: [`openspec/specs/branded-scaffold/spec.md`](../../../../specs/branded-scaffold/spec.md).

## Requirements

### Requirement: Brand color tokens

The app SHALL define brand colors in the asset catalog that match the app icon palette (pink gradient + white on-brand). `AccentColor` SHALL use the same primary pink as `BrandPrimary`. A Swift `Brand` API SHALL expose those colors, an icon-matching gradient (light → deep, top-leading → bottom-trailing), and shared corner radii.

#### Scenario: Accent matches brand primary [tested]

- GIVEN the asset catalog defines `AccentColor` and `BrandPrimary`
- WHEN their color components are read
- THEN they match each other
- AND they match the frozen icon primary sample `#FB2682`
- **Test:** `accentColorMatchesBrandPrimary()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Brand catalog matches icon samples [tested]

- GIVEN the brand named colors in the asset catalog
- WHEN their components are read
- THEN `BrandLight` matches `#FD99BF`
- AND `BrandMid` matches `#FC57A4`
- AND `BrandDeep` matches `#F90C77`
- AND `BrandOnBrand` matches `#FFFFFF`
- **Test:** `brandCatalogMatchesIconSamples()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Brand gradient uses icon stops [tested]

- GIVEN the `Brand.gradient` API
- WHEN its stop colors are inspected
- THEN they use brand light, mid, and deep (in that order)
- **Test:** `brandGradientUsesIconStops()` — [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift)

#### Scenario: Branded UI readable in light and dark [manual]

- GIVEN the app runs in light appearance and in dark appearance
- WHEN the user views Lists home and a tinted control (for example Create or a checked item)
- THEN brand accent remains visible
- AND primary content remains readable
