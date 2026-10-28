# Proposal: Brand tokens

## Intent

Introduce a small brand color token set sampled from the app icon (pink gradient + white glyph), remap `AccentColor` to brand primary so existing tint usage matches the icon, and expose a thin Swift `Brand` API for gradient and radii.

## Scope

Amends **branded-scaffold** (brand presentation). Does not redesign Lists layout or typography.

- Asset catalog named colors: `BrandPrimary`, `BrandLight`, `BrandDeep`, `BrandOnBrand` (and mid stop for the icon gradient)
- Remap `AccentColor` to brand primary (`#FB2682`)
- `Brand` Swift API: colors, icon-matching gradient, control/chip radii
- Unit tests that catalog JSON components match the frozen icon hex samples
- Preview doc: [`docs/brand-palette-preview.html`](../../../docs/brand-palette-preview.html)

## Out of scope

- Full screen redesign / custom display fonts for the W
- New app icon artwork
- Pink full-screen backgrounds on Lists home
- Full type/spacing/shadow token scales
