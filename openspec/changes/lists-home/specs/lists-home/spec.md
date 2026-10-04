# Lists home

Launch into a Lists home, create and open lists, and add items on one device.

## Requirements

### Requirement: Lists home on launch

On launch, the app SHALL open a **Lists** home screen as the root experience. The branded splash-only screen SHALL NOT remain the sole destination after this change.

The Lists home SHALL show the user’s lists when any exist. The product name **wifyradar** MAY appear in navigation chrome (for example as the title).

#### Scenario: App launches to Lists home [manual]

- GIVEN the app is installed on an iPhone
- WHEN the user launches the app
- THEN the first interactive screen is the Lists home

#### Scenario: Empty Lists home offers create [manual]

- GIVEN the user has no lists yet
- WHEN the Lists home is shown
- THEN the user sees an empty state and a control that starts creating a list

### Requirement: Create a list

The app SHALL let the user create a list with a non-empty name. The list SHALL still be available after the user leaves the screen and after relaunching the app.

#### Scenario: User creates a named list [manual]

- GIVEN the app is running
- WHEN the user creates a list with a name
- THEN that list appears in the Lists home after save

#### Scenario: List is available after relaunch [manual]

- GIVEN the user has created a list
- WHEN the user leaves the app and launches it again
- THEN that list still appears in the Lists home

### Requirement: Open a list

The app SHALL let the user open a list from Lists home to view that list’s items.

#### Scenario: User opens a list detail [manual]

- GIVEN the user has at least one list on Lists home
- WHEN the user selects that list
- THEN the app shows that list’s detail (name and items area)

### Requirement: Add an item

The app SHALL let the user add a text item to a list and show it on that list’s detail screen.

#### Scenario: User adds an item [manual]

- GIVEN the user is viewing a list detail
- WHEN the user adds a text item
- THEN the item appears in that list’s items
