# Design: Brand tokens

Canonical requirements land in [`branded-scaffold`](../../specs/branded-scaffold/spec.md). Palette preview: [`docs/brand-palette-preview.html`](../../../docs/brand-palette-preview.html).

## Palette (from AppIcon)

| Token | Hex | Role |
|-------|-----|------|
| BrandLight | `#FD99BF` | Gradient start |
| BrandMid | `#FC57A4` | Gradient mid |
| BrandPrimary / AccentColor | `#FB2682` | Tint, accent |
| BrandDeep | `#F90C77` | Gradient end |
| BrandOnBrand | `#FFFFFF` | On pink fills |

## Intended behavior

1. Named colors live in `Assets.xcassets` (Any + slightly lifted Dark where useful).
2. `AccentColor` uses the same components as `BrandPrimary`.
3. `Brand.swift` reads those named colors; `Brand.gradient` is light → mid → deep, `topLeading` → `bottomTrailing`.
4. Existing `Color.accentColor` / `.tint` / `.borderedProminent` call sites pick up pink without per-screen rewrites.
5. Catalog unit tests parse colorset JSON and assert RGB matches the frozen hex table.

### Files

| Path | Role |
|------|------|
| `WifyRadar/Assets.xcassets/AccentColor.colorset/` | Remap to brand primary |
| `WifyRadar/Assets.xcassets/Brand*.colorset/` | Named brand colors |
| `WifyRadar/Brand/Brand.swift` | Swift API |
| `WifyRadarTests/BrandCatalogTests.swift` | Hex/component assertions |
| `docs/brand-palette-preview.html` | Human review of swatches |

### Existing accent call sites (auto-retint)

- `ShareInviteLoadingView` — `Color.accentColor`
- `ListDetailView` — checked item `Color.accentColor`
- Lists home Create — `.borderedProminent` uses accent tint

## Documentation

### README.md

- Note brand colors come from the app icon; optional link to `docs/brand-palette-preview.html`.

### Spec scenario tags

- Canonical: [`openspec/specs/branded-scaffold/spec.md`](../../specs/branded-scaffold/spec.md)
- Change: [`openspec/changes/brand-tokens/specs/branded-scaffold/spec.md`](specs/branded-scaffold/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| Accent matches brand primary | `accentColorMatchesBrandPrimary()` | [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift) |
| Brand catalog matches icon samples | `brandCatalogMatchesIconSamples()` | [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift) |
| Brand gradient uses icon stops | `brandGradientUsesIconStops()` | [`WifyRadarTests/BrandCatalogTests.swift`](../../../../WifyRadarTests/BrandCatalogTests.swift) |
| Branded UI readable in light and dark | *(manual)* | — |
