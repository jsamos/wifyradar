# Design: Lists home

## Architecture

- SwiftUI navigation: **Lists home** → **list detail**
- SwiftData models for list + item; prefer CloudKit-compatible shapes so **share-list** can enable sync later without a rewrite
- CloudKit sharing UI and multi-user sync are out of scope here
- Product name **wifyradar** MAY be the navigation title on Lists home

## Files to modify / add

| Area | Role |
|------|------|
| SwiftData models | List (name) and Item (text; checked flag optional) |
| Model container | App entry wiring for SwiftData |
| Root UI | Lists home replaces splash-only root |
| Detail UI | Items for one list + add item |
| Create UI | Empty state + create-list flow |

## Auth

None.

## Tests

| Kind | Coverage |
|------|----------|
| Manual | Launch → Lists home; empty create; open detail; add item |
| Automated | Optional model tests if cheap |

## Documentation

### README.md

- Link the lists-home behavioral spec
- Note that launch opens Lists home (not splash-only)

### Spec scenario tags

- Canonical: [`openspec/specs/lists-home/spec.md`](../../specs/lists-home/spec.md)
- Change: [`openspec/changes/lists-home/specs/lists-home/spec.md`](specs/lists-home/spec.md)

| Scenario | Test title (at ship) | Test file |
|----------|----------------------|-----------|
| App launches to Lists home | *(manual)* | — |
| Empty Lists home offers create | *(manual)* | — |
| User creates a named list | *(manual)* | — |
| List is available after relaunch | *(manual)* | — |
| User opens a list detail | *(manual)* | — |
| User adds an item | *(manual)* | — |
