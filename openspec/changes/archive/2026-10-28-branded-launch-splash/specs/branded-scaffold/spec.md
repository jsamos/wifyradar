# Branded scaffold (change: branded launch splash)

Only requirements introduced or modified by this change. Canonical: [`openspec/specs/branded-scaffold/spec.md`](../../../../specs/branded-scaffold/spec.md).

## Requirements

### Requirement: Branded launch UI

On launch, the app SHALL show a branded splash whose dominant marks are a large **W** and the product name **wifyradar**, on a black background, with the tagline **Stay synced. Stay happy**. The splash SHALL appear on cold start before Lists home is interactive. Lists home remains the first interactive screen after the splash (see lists-home).

#### Scenario: Branded splash appears on launch

- GIVEN the app is installed on a simulator or device
- WHEN the user cold-starts the app
- THEN a black splash appears with a branded **W**, **wifyradar**, and **Stay synced. Stay happy**

#### Scenario: Lists home follows splash

- GIVEN the user cold-starts the app
- WHEN the splash finishes
- THEN Lists home is the first interactive screen
